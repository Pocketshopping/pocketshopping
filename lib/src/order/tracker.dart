import 'dart:async';
import 'dart:convert';

import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/order/repository/orderItem.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/MyOrder/orderGlobal.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'repository/order.dart';

class OrderTrackerWidget extends StatefulWidget {
  OrderTrackerWidget({this.order, this.user});

  final Order order;
  final User user;

  @override
  State<StatefulWidget> createState() => _OrderTrackerWidgetState();
}

class _OrderTrackerWidgetState extends State<OrderTrackerWidget> {
  int _start;
  String counter;
  Timer _timer;
  Merchant merchant;
  String resolution;
  Stream<LocalNotification> _notificationsStream;
  String comment;
  String deliveryman;
  int moreSec;
  int reply;
  List<Widget> bubble;
  dynamic delayTime;

  //Session CurrentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  var scroller = ScrollController();
  bool pingStart;
  OrderGlobalState odState;

  @override
  void initState() {
    odState = Get.find();
    //print('buuble: ${getItem('bubble')}');
    resolution = isNotEmpty() ? getItem('resolution') : 'START';
    comment = isNotEmpty() ? getItem('comment') : '';
    deliveryman = isNotEmpty() ? getItem('deliveryman') : '';
    reply = isNotEmpty() ? getItem('reply') : 0;
    pingStart = isNotEmpty() ? getItem('pingStart') : false;
    bubble = isNotEmpty() ? getItem('bubble') : [];
    _start = isNotEmpty()
        ? setStartCount(getItem('delayTime'), getItem('moreSec'))
        : setStartCount(widget.order.orderCreatedAt, widget.order.orderETA);
    counter =
        '${isNotEmpty() ? (setStartCount(getItem('delayTime'), getItem('moreSec')) / 60).round() : (setStartCount(widget.order.orderCreatedAt, widget.order.orderETA) / 60).round()} min to ${widget.order.orderMode.mode}';
    startTimer();
    MerchantRepo.getMerchant(widget.order.orderMerchant)
        .then((value) => setState(() {
              merchant = value;
            }));
    moreSec = isNotEmpty() ? getItem('moreSec') : widget.order.orderETA;
    delayTime = isNotEmpty() ? getItem('delayTime') : null;
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      if (notification != null) {
        if (mounted &&
            notification.data['data']['payload'].toString().isNotEmpty) {
          var payload = jsonDecode(notification.data['data']['payload']);
          switch (payload['NotificationType']) {
            case 'OrderResolutionMerchantResponse':
              setState(() {
                comment = payload['comment'] as String;
                deliveryman = payload['deliveryman'] as String;
                moreSec = (payload['delay'] as int) * 60;
                resolution = 'START';
                delayTime = Timestamp(payload['time'][0], payload['time'][1]);
                _start = setStartCount(delayTime, moreSec);
                startTimer();
                bubble.add(Bubble(
                  alignment: Alignment.center,
                  color: Color.fromRGBO(212, 234, 244, 1),
                  child: Text(
                    '${merchant != null ? merchant.bName : 'Merchant'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11),
                  ),
                ));
                bubble.add(Bubble(
                  margin: BubbleEdges.only(top: 10),
                  alignment: Alignment.topLeft,
                  nip: BubbleNip.leftTop,
                  color: Color.fromRGBO(212, 234, 244, 1),
                  child: Text('$comment'),
                ));
                bubble.add(Bubble(
                  margin: BubbleEdges.only(top: 2),
                  alignment: Alignment.topLeft,
                  nip: BubbleNip.no,
                  color: Color.fromRGBO(212, 234, 244, 1),
                  child: Text('Delivery Personnel:$deliveryman'),
                ));
                bubble.add(Bubble(
                  margin: BubbleEdges.only(top: 2),
                  alignment: Alignment.topLeft,
                  nip: BubbleNip.no,
                  color: Color.fromRGBO(212, 234, 244, 1),
                  child: Text(
                      'Please wait for ${(payload['delay'] as int)} minute more'),
                ));
              });
              //scroller.animateTo(scroller.position.maxScrollExtent);
              globalStateUpdate();
              NotificationsBloc.instance.clearNotification();
              break;
          }
        }
      }
    });

    super.initState();
  }

  dynamic getItem(String key) {
    return odState.order[widget.order.docID][key];
  }

  void globalStateUpdate() {
    odState.adder(widget.order.docID, {
      'resolution': resolution,
      'comment': comment,
      'deliveryman': deliveryman,
      'reply': reply,
      'pingStart': pingStart,
      'bubble': bubble,
      'moreSec': moreSec,
      'delayTime': delayTime,
    });
    Get.put(odState);
  }

  bool isNotEmpty() {
    return odState.order.containsKey(widget.order.docID);
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
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.grey,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            'Tracker',
            style: TextStyle(color: PRIMARYCOLOR),
          ),
          automaticallyImplyLeading: false,
        ),
        body: ListView(children: [
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text(
                        'Status: ${widget.order.orderConfirmation.isConfirmed ? 'Completed' : 'Processing'}',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  _start > 0
                      ? !widget.order.orderConfirmation.isConfirmed
                          ? Loader(_start, moreSec, counter)
                          : Container()
                      : widget.order.orderMode.mode == 'Delivery'
                          ? Resolution()
                          : widget.order.orderMode.mode == 'Pickup'
                              ? Container(
                                  child: psHeadlessCard(
                                      boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        //offset: Offset(1.0, 0), //(x,y)
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Center(
                                            child: Text(
                                              'Your order is ready for pickup.',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      )))
                              : Container(),
                  pingStart
                      ? psHeadlessCard(
                          boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                //offset: Offset(1.0, 0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.4,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: ListView(
                                controller: scroller,
                                children: bubble.toList() ?? Container(),
                              )))
                      : Container(),
                  !widget.order.orderConfirmation.isConfirmed && _start > 0
                      ? psHeadlessCard(
                          boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                //offset: Offset(1.0, 0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          child: Container(
                            color: PRIMARYCOLOR,
                            child: FlatButton(
                              child: Center(
                                child: Text(
                                  'Confirm Order',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ))
                      : Container(),
                  psHeadlessCard(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          //offset: Offset(1.0, 0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                      child: Column(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    //                   <--- left side
                                    color: Colors.black12,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.02),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text('Confirmed:'),
                                  ),
                                  Expanded(
                                    child: Text(widget
                                            .order.orderConfirmation.isConfirmed
                                        ? "Yes"
                                        : 'No'),
                                  )
                                ],
                              )),
                          Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    //                   <--- left side
                                    color: Colors.black12,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.02),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text('Confirmation code:'),
                                  ),
                                  Expanded(
                                    child: Text(widget
                                        .order.orderConfirmation.confirmOTP),
                                  )
                                ],
                              )),
                          Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    //                   <--- left side
                                    color: Colors.black12,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.02),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text('Confirmation code:'),
                                  ),
                                  Expanded(
                                    child: Text(widget
                                        .order.orderConfirmation.confirmOTP),
                                  )
                                ],
                              )),
                        ],
                      )),
                  psHeadlessCard(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        //offset: Offset(1.0, 0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                    child: Column(
                      children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    //                   <--- left side
                                    color: Colors.black12,
                                    width: 1.0,
                                  ),
                                ),
                                color: PRIMARYCOLOR),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.02),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Order Deatils',
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                        Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  //                   <--- left side
                                  color: Colors.black12,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text('Merchant:'),
                                ),
                                Expanded(
                                  child: Text(
                                      '${merchant != null ? merchant.bName : ''}'),
                                )
                              ],
                            )),
                        Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  //                   <--- left side
                                  color: Colors.black12,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text('Merchant Contact:'),
                                ),
                                Expanded(
                                  child: Text(
                                      '${merchant != null ? merchant.bTelephone : ''}'),
                                )
                              ],
                            )),
                        Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  //                   <--- left side
                                  color: Colors.black12,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text('Category:'),
                                ),
                                Expanded(
                                  child: Text(
                                      '${merchant != null ? merchant.bCategory : ''}'),
                                )
                              ],
                            )),
                        Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  //                   <--- left side
                                  color: Colors.black12,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text('Mode:'),
                                ),
                                Expanded(
                                  child: Text('${widget.order.orderMode.mode}'),
                                )
                              ],
                            )),
                        Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  //                   <--- left side
                                  color: Colors.black12,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text('Placed:'),
                                ),
                                Expanded(
                                  child: Text(
                                      '${presentDate(DateTime.parse((widget.order.orderCreatedAt as Timestamp).toDate().toString()))}'),
                                )
                              ],
                            )),
                        Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  //                   <--- left side
                                  color: Colors.black12,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text('OrderId:'),
                                ),
                                Expanded(
                                  child: Text('${widget.order.docID}'),
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                  psHeadlessCard(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          //offset: Offset(1.0, 0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                      child: Column(children: [
                        Container(
                            decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    //                   <--- left side
                                    color: Colors.black12,
                                    width: 1.0,
                                  ),
                                ),
                                color: PRIMARYCOLOR),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.02),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Order Items',
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                        Column(
                            children: List.generate(
                                widget.order.orderItem.length,
                                (index) => Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          //                   <--- left side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                              '${widget.order.orderItem[index].ProductName}'),
                                        ),
                                        Expanded(
                                          child: Text(
                                              '${widget.order.orderItem[index].count}'),
                                        ),
                                        Expanded(
                                          child: Text(
                                              '${widget.order.orderItem[index].totalAmount}'),
                                        )
                                      ],
                                    ))).toList()),
                        Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  //                   <--- left side
                                  color: Colors.black12,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text('Item Total:'),
                                ),
                                Expanded(
                                  child: Text('${widget.order.orderAmount}'),
                                )
                              ],
                            )),
                        widget.order.orderMode.mode == 'Delivery'
                            ? Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      //                   <--- left side
                                      color: Colors.black12,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * 0.02),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text('Delivery Fee:'),
                                    ),
                                    Expanded(
                                      child:
                                          Text('${widget.order.orderMode.fee}'),
                                    ),
                                  ],
                                ))
                            : Container(),
                        Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  //                   <--- left side
                                  color: Colors.black12,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Total:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${widget.order.orderMode.mode != 'Delivery' ? widget.order.orderAmount : (widget.order.orderAmount + widget.order.orderMode.fee)}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            )),
                      ])),
                  psHeadlessCard(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          //offset: Offset(1.0, 0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                      child: QrImage(
                        data: widget.order.docID,
                      ))
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Future<bool> _willPopScope() async {
    return true;
  }

  void startTimer({bool default_ = true, Function action}) {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => {
        if (mounted)
          {
            setState(
              () {
                if (_start < 1) {
                  timer.cancel();
                  if (action != null) action();
                } else {
                  _start = _start - 1;
                  if (default_) countDownFormater(_start);
                }
              },
            )
          }
      },
    );
  }

  void pingingTimer({bool default_ = true, Function action}) {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => {
        if (mounted)
          {
            setState(
              () {
                if (reply < 1) {
                  timer.cancel();
                  if (action != null) action();
                } else {
                  reply = reply - 1;
                }
              },
            )
          }
      },
    );
  }

  void countDownFormater(int sec) {
    int minute = 0;
    int second = 0;

    minute = (sec / 60).round();
    second = (sec % 60) * 60;
    if (minute > 0)
      setState(() {
        counter = '$minute min to ${widget.order.orderMode.mode}';
      });
    else
      setState(() {
        counter = '$_start sec to ${widget.order.orderMode.mode}';
      });
  }

  int setStartCount(dynamic dtime, int second) {
    print(dtime);
    var otime = DateTime.parse((dtime as Timestamp).toDate().toString())
        .add(Duration(seconds: second));
    int diff = otime.difference(DateTime.now()).inSeconds;
    if (diff > 0)
      return diff;
    else
      return 0;
  }

  dynamic presentDate(dynamic datetime) {
    var result;
    bool yesterday = false;
    bool today = false;
    var date;
    var time;
    //if(DateTime.now().difference(datetime))
    result = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
    yesterday = formatDate(
            DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day - 1),
            [dd, '/', mm, '/', yyyy]) ==
        formatDate(datetime, [dd, '/', mm, '/', yyyy]);
    today = formatDate(DateTime.now(), [dd, '/', mm, '/', yyyy]) ==
        formatDate(datetime, [dd, '/', mm, '/', yyyy]);
    date = formatDate(datetime, [d, ' ', M, ', ', yyyy]);
    time = formatDate(datetime, [HH, ':', nn, ' ', am]);
    if (today)
      return 'Today at $time';
    else if (yesterday)
      return 'Yesterday at $time';
    else
      return '$date at $time';
  }

  Widget Resolution() {
    switch (resolution) {
      case 'START':
        return Container(
            child: psHeadlessCard(
                boxShadow: [
              BoxShadow(
                color: Colors.grey,
                //offset: Offset(1.0, 0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        'Have you recieved your package?',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FlatButton(
                          onPressed: () {},
                          child: Text(
                            'Yes',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: PRIMARYCOLOR,
                        ),
                        FlatButton(
                          onPressed: () {
                            sendMessage();
                            setState(() {
                              resolution = 'PINGING';
                              pingStart = true;
                              moreSec = 0;
                              _start = 0;
                              counter = '';
                              reply = 120;
                              bubble.add(Bubble(
                                margin: BubbleEdges.only(top: 10),
                                alignment: Alignment.topRight,
                                nip: BubbleNip.rightTop,
                                color: Color.fromRGBO(255, 255, 199, 1),
                                child: Text('Pinging ${merchant.bName}'),
                              ));
                            });
                          },
                          child:
                              Text('No', style: TextStyle(color: Colors.white)),
                          color: PRIMARYCOLOR,
                        ),
                      ],
                    )
                  ],
                )));
        break;
      case 'PINGING':
        pingingTimer(action: () {
          if (moreSec == 0)
            setState(() {
              resolution = 'REPING';
            });
        });
        return Loader(reply, 120, 'Pinging Merchant.');
        break;

      case 'REPING':
        return Container(
            child: psHeadlessCard(
                boxShadow: [
              BoxShadow(
                color: Colors.grey,
                //offset: Offset(1.0, 0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        'Waiting for response from ${merchant.bName}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FlatButton(
                          onPressed: () {
                            sendMessage();
                            setState(() {
                              pingStart = true;
                              resolution = 'PINGING';
                              reply = 120;
                              moreSec = 0;
                              _start = 0;
                              counter = '';
                              bubble.add(Bubble(
                                margin: BubbleEdges.only(top: 10),
                                alignment: Alignment.topRight,
                                nip: BubbleNip.rightTop,
                                color: Color.fromRGBO(255, 255, 199, 1),
                                child: Text('Pinging ${merchant.bName}'),
                              ));
                            });
                            //scroller.animateTo(scroller.position.maxScrollExtent);
                          },
                          child: Text('Reping',
                              style: TextStyle(color: Colors.white)),
                          color: PRIMARYCOLOR,
                        ),
                      ],
                    )
                  ],
                )));
        break;
    }
  }

  Widget Loader(int current, int total, String message) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.height * 0.18,
        color: Colors.white,
        child: CircularStepProgressIndicator(
          totalSteps: total,
          currentStep: current,
          stepSize: 10,
          selectedColor: PRIMARYCOLOR,
          unselectedColor: Colors.grey[200],
          padding: 0,
          width: 150,
          height: 150,
          selectedStepSize: 15,
          child: Center(
            child: Text(
              '$message',
              textAlign: TextAlign.center,
            ),
          ),
        ));
  }

  Future<void> sendMessage() async {
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
            'body':
                'Hello. I have not recieved my package and its already time',
            'title': 'Order Resolution'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'OrderResolutionResponse',
              'orderID': widget.order.docID,
              'Items': OrderItem.toListMap(widget.order.orderItem),
              'Amount': widget.order.orderAmount,
              'type': widget.order.orderMode.mode,
              'Address': widget.order.orderMode.mode == 'Delivery'
                  ? widget.order.orderMode.address
                  : '',
              'telephone': widget.order.orderCustomer.customerTelephone,
              'fcmToken': widget.user.notificationID,
            }
          },
          'registration_ids': [
            'fI8U-GHOSEKhEZXU3egwdU:APA91bEl8iZXRSNKsqcxzdfP9MYpwf52Bfht3Zk5e7tLDSgZ-u8yIHoYVVtK6qyl5S3-0BC01CnFBLBj5ZOD3jSVuWC1ni0uFWPQuoRki4HH0bD1Yg_OI8L9OLD4vCU0lIMwoRvA9X6f',
          ],
        }));
  }
}
