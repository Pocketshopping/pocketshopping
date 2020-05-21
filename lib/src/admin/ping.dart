import 'dart:async';
import 'dart:convert';
import 'package:random_string/random_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class PingWidget extends StatefulWidget {
  PingWidget({this.ndata, this.uid});

  final Map<String, dynamic> ndata;
  final String uid;

  @override
  State<StatefulWidget> createState() => _PingWidgetState();
}

class _PingWidgetState extends State<PingWidget> {
  int counter;
  Stream<LocalNotification> _notificationsStream;
  List<Map<String, dynamic>> data;

  @override
  void initState() {
    //print((jsonDecode(widget.ndata['data']['payload']) as Map<String,dynamic>));
    data = List();
    if (!data.contains(widget.ndata)) {
      data.add((jsonDecode(widget.ndata['data']['payload'])
          as Map<String, dynamic>));
      counter = 1;
    }

    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      if (notification != null) {
        var payload = (jsonDecode(notification.data['data']['payload'])
            as Map<String, dynamic>);
        if (!data.contains(payload)) {
          if (payload['NotificationType'] == 'OrderRequest' ||
              payload['NotificationType'] == 'OrderResolutionResponse' ||
              payload['NotificationType'] == 'NearByAgent') {
            data.add(payload);
            counter += 1;
            if (mounted) setState(() {});
          }
        }
        NotificationsBloc.instance.clearNotification();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _willPopScope,
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0.0,
              centerTitle: true,
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              title: Text(
                'Order Request',
                style: TextStyle(color: PRIMARYCOLOR),
              ),
              automaticallyImplyLeading: false,
            ),
            body: ListView(
              children: cards(),
            )));
  }

  List<Widget> cards() {
    return List<Widget>.generate(data.length, (index) {
      if (data[index]['NotificationType'] == 'OrderRequest')
        return CardWidget(
          ndata: data[index],
          monitor: monitor,
          uid: widget.uid,
        );
      else if (data[index]['NotificationType'] == 'OrderResolutionResponse')
        return Resolution(
          payload: data[index],
          monitor: monitor,
          uid: widget.uid,
        );
      else if (data[index]['NotificationType'] == 'NearByAgent')
        return NearByAgent(
          payload: data[index],
          monitor: monitor,
          uid: widget.uid,
        );
      else
        return Container();
    }).toList();
  }

  Future<bool> _willPopScope() async {
    if (counter > 0)
      return false;
    else
      return true;
  }

  monitor() {
    counter -= 1;
    setState(() {});
    if (counter == 0) Get.back();
  }
}

class CardWidget extends StatefulWidget {
  CardWidget({this.ndata, this.monitor, this.uid});

  final Map<String, dynamic> ndata;
  final Function monitor;
  final String uid;

  @override
  State<StatefulWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  int _start;
  Timer _timer;
  bool expired;

  @override
  void initState() {
    expired = true;
    _start = Utility.setStartCount(
        Timestamp(widget.ndata['time'][0], widget.ndata['time'][1]), 60);
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _start != 0
        ? psHeadlessCard(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                //offset: Offset(1.0, 0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
            child: OrderConfirm(widget.ndata),
          )
        : Container();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => {
        if (mounted)
          {
            setState(
              () {
                if (_start < 1) {
                  widget.monitor();
                  if (expired)
                    Respond(false, '', widget.ndata['fcmToken'])
                        .then((value) => null);
                  timer.cancel();
                } else {
                  _start = _start - 1;
                }
              },
            )
          }
      },
    );
  }

  Widget OrderConfirm(Map<String, dynamic> payload) {
    //print(payload['data']['payload']['deliveryFee']);
    return Padding(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('New Order',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Text('$_start s',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PRIMARYCOLOR)),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Can you execute this ${payload['type']} order',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            children: List<Widget>.generate(
                payload['Items'].length,
                (index) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child:
                              Text('${payload['Items'][index]['productName']}'),
                        ),
                        Expanded(
                          child: Text(
                              '${payload['Items'][index]['productCount']}'),
                        ),
                      ],
                    )).toList(),
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Amount: \u20A6 ${payload['Amount']}'),
          ),
          payload['type'] == 'Delivery'
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text('delivery Fee: \u20A6${payload['deliveryFee']}'))
              : Container(),
          payload['type'] == 'Delivery'
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total Fee: \u20A6${payload['deliveryFee'] + payload['Amount']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ))
              : Container(),
          SizedBox(
            height: 10,
          ),
          payload['type'] == 'Delivery'
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Address: ${payload['Address']}'))
              : Container(),
          payload['type'] == 'Delivery'
              ? Align(
                  alignment: Alignment.centerLeft,
                  child:
                      Text('Distance: ${payload['deliveryDistance'] / 1000}km'))
              : Container(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            FlatButton(
              color: Colors.grey,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Text('No'),
              ),
              onPressed: () async {
                await Respond(false, '', payload['fcmToken']);
                setState(() {
                  _start = 1;
                  expired = false;
                });
                //NotificationsBloc.instance.clearNotification();
                //Get.back();
              },
            ),
            FlatButton(
              color: PRIMARYCOLOR,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Text(
                  'Yes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onPressed: () async {
                await Respond(true, '', payload['fcmToken']);
                if(mounted)
                setState(() {
                  _start = 1;
                  expired = false;
                });
                //NotificationsBloc.instance.clearNotification();
                //Get.back();
              },
            ),
          ])
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    );
  }

  Future<void> Respond(bool yesNo, String response, String fcm) async {
    await _fcm.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
        provisional: false,
      ),
    );
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': yesNo
                ? 'Your order has been confirmed proceed with payment'
                : 'Your order has been decline. ($response)',
            'title': 'Order Confirmation'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'OrderRequestResponse',
              'Response': yesNo,
              'Reason': response,
              'acceptedBy': widget.uid
            }
          },
          'to': fcm,
        }));
  }
}

class Resolution extends StatefulWidget {
  Resolution({this.payload, this.monitor, this.uid});

  final Function monitor;
  final String uid;
  final dynamic payload;

  @override
  State<StatefulWidget> createState() => _ResolutionState();
}

class _ResolutionState extends State<Resolution> {
  Map<String, dynamic> payload;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final _formKey = GlobalKey<FormState>();
  var _delay = TextEditingController();
  var _telephone = TextEditingController();
  int delay;

  @override
  void initState() {
    delay = 5;
    payload = widget.payload as Map<String, dynamic>;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return psHeadlessCard(
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            //offset: Offset(1.0, 0), //(x,y)
            blurRadius: 6.0,
          ),
        ],
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Text('Resolution',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                    'Hello. I have not recieved my package and its already time',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    //mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        children: List<Widget>.generate(
                            payload['Items'].length,
                            (index) => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                            '${payload['Items'][index]['ProductName']}'),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                            '${payload['Items'][index]['count']}'),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                            '\u20A6 ${payload['Items'][index]['ProductPrice']}'),
                                      ),
                                    ),
                                  ],
                                )).toList(),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Amount: \u20A6 ${payload['Amount']}'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Telephone: ${payload['telephone']}')),
                      SizedBox(
                        height: 5,
                      ),
                      payload['type'] == 'Delivery'
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Address: ${payload['Address']}'))
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _delay,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Give reason';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Enter Reason',
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.2),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          maxLines: 5,
                          maxLength: 120,
                          maxLengthEnforced: true,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _telephone,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Delivery Man Telephone';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Delivery Man Telephone',
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.2),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Extend duration by:(min)')),
                        DropdownButtonFormField<int>(
                          value: delay,
                          items: [5, 10, 15]
                              .map((label) => DropdownMenuItem(
                                    child: Text(
                                      '$label',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    value: label,
                                  ))
                              .toList(),
                          hint: Text('How many minute delay'),
                          decoration: InputDecoration(border: InputBorder.none),
                          onChanged: (value) {
                            setState(() {
                              delay = value;
                            });
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                color: PRIMARYCOLOR,
                child: FlatButton(
                  color: PRIMARYCOLOR,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      Respond(delay, _delay.text, payload['fcmToken'],
                              _telephone.text, payload['oID'])
                          .then((value) => null);
                      widget.monitor();
                    }
                  },
                  child: Text(
                    'Reply',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> Respond(int delay, String comment, String fcm, String telephone,
      String oID) async {
    //print('team meeting');
    await _fcm.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': '$comment',
            'title': 'Resolution'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'OrderResolutionMerchantResponse',
              'orderID': oID,
              'delay': delay,
              'comment': comment,
              'deliveryman': telephone,
              'time': [Timestamp.now().seconds, Timestamp.now().nanoseconds],
            }
          },
          'to': fcm,
        }));
  }
}

class NearByAgent extends StatefulWidget {
  NearByAgent({this.payload, this.monitor, this.uid});

  final Function monitor;
  final String uid;
  final dynamic payload;

  @override
  State<StatefulWidget> createState() => _NearByAgentState();
}

class _NearByAgentState extends State<NearByAgent> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final _formKey = GlobalKey<FormState>();
  Stream<LocalNotification> _notificationsStream;
  int _start;
  Timer _timer;
  String reason;
  bool autoval;
  bool expired;
  bool clear;

  @override
  void initState() {
    clear =false;
    expired = true;
    _start = Utility.setStartCount(Timestamp(widget.payload['time'][0], widget.payload['time'][1]), 58);
    startTimer();
    reason = 'Select';
    autoval = false;
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      if (notification != null) {
        var payload = (jsonDecode(notification.data['data']['payload']) as Map<String, dynamic>);
        if (payload['NotificationType'] == 'AgentClearRequest') {
          print('old otp${widget.payload['otp']}') ;
          print('new otp${payload['otp']}') ;
          if (mounted)
              setState(() {
                if(payload['otp'] == widget.payload['otp'])
                  {
                    clear=true;
                    _start = 5;
                  }
              });
          }
        NotificationsBloc.instance.clearNotification();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _start != 0
        ? psHeadlessCard(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                //offset: Offset(1.0, 0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
            child: DeliveryConfirm(widget.payload),
          )
        : Container();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => {
        if (mounted)
          {
            setState(
              () {
                if (_start < 1) {
                  widget.monitor();
                  if (expired)
                    Respond(false, reason, widget.payload['fcmToken'],
                            widget.payload['agentCount'],'')
                        .then((value) => null);
                  timer.cancel();
                } else {
                  _start = _start - 1;
                }
              },
            )
          }
      },
    );
  }

  Widget DeliveryConfirm(Map<String, dynamic> payload) {
    //print(payload['data']['payload']['deliveryFee']);
    return Padding(
      child: !clear?Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Delivery Request',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Text('$_start s',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PRIMARYCOLOR)),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Can you run this delivery order',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            children: List<Widget>.generate(
                payload['Items'].length,
                (index) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child:
                              Text('${payload['Items'][index]['productName']}'),
                        ),
                        Expanded(
                          child: Text(
                              '${payload['Items'][index]['productCount']}'),
                        ),
                      ],
                    )).toList(),
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('From: ${payload['merchant']}'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Address: ${payload['mAddress']}'),
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Text('delivery Fee: \u20A6${payload['deliveryFee']}')),
          SizedBox(
            height: 10,
          ),
          payload['type'] == 'Delivery'
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Customer Address: ${payload['Address']}'))
              : Container(),
          payload['type'] == 'Delivery'
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      'Customer Distance: ${payload['deliveryDistance'] > 1000 ? (payload['deliveryDistance'] / 1000).toString() + ' km' : payload['deliveryDistance'].toString() + ' m'}'))
              : Container(),
          SizedBox(
            height: 10,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Text('If NO, Select Reason:')),
          Form(
            key: _formKey,
            child: DropdownButtonFormField<String>(
              value: reason,
              items: [
                'Select',
                'Logistic Problem',
                'Customer Is Too Far',
                'Package Is Too Heavy}'
              ]
                  .map((label) => DropdownMenuItem(
                        child: Text(
                          '$label',
                          style: TextStyle(color: Colors.black54),
                        ),
                        value: label,
                      ))
                  .toList(),
              hint: Text('select reason'),
              decoration: InputDecoration(border: InputBorder.none),
              onChanged: (value) async {
                if (value != 'Select') {
                  await Respond(false, reason, payload['fcmToken'],
                      payload['agentCount'],'');
                  setState(() {
                    _start = 1;
                  });
                }
              },
              autovalidate: autoval,
              validator: (value) {
                if (value == 'Select') {
                  return 'Select reason';
                }
                return null;
              },
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            FlatButton(
              color: Colors.grey,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Text('No'),
              ),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  await Respond(false, reason, payload['fcmToken'],
                      payload['agentCount'],'');
                  setState(() {
                    _start = 1;
                    expired = false;
                  });
                } else {
                  setState(() {
                    autoval = true;
                  });
                }
                //NotificationsBloc.instance.clearNotification();
                //Get.back();
              },
            ),
            FlatButton(
              color: PRIMARYCOLOR,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Text(
                  'Yes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _start = 1;
                  expired = false;
                });
                String token = await _fcm.getToken();
                List<String> data = List.castFrom(payload['agents']);
                data.remove(token);
                await Respond(true, '', payload['fcmToken'], payload['agentCount'],payload['otp']);
                await FastestFinger(data,payload['otp']);
                //NotificationsBloc.instance.clearNotification();
                //Get.back();
              },
            ),
          ])
        ],
      ):Center(child: Text('Request has been accepted by other agent. Please stay put for new request'),),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    );
  }

  Future<void> Respond(
      bool yesNo, String response, String fcm, int agentCount,String otp) async {
    await _fcm.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
        provisional: false,
      ),
    );
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': yesNo
                ? 'Your order has been confirmed proceed with payment'
                : 'Your order has been decline. ($response)',
            'title': 'Order Confirmed'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'AgentRequestResponse',
              'Response': yesNo,
              'Reason': response,
              'acceptedBy': widget.uid,
              'agentCount': agentCount,
              'otp':yesNo?otp:randomAlphaNumeric(10),

            }
          },
          'to': fcm,
        }));
  }

  Future<void> FastestFinger(List<String> others,String otp) async {
    await _fcm.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
        provisional: false,
      ),
    );
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'Sorry someone else has claimed this delivery request. Stay put for another request',
            'title': 'Request Lost'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'AgentClearRequest',
              'clear': true,
              'otp':otp,
            }
          },
          'registration_ids': others,
        }));
  }
}
