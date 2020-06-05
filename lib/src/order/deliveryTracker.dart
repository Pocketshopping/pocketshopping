import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/channels/repository/channelObj.dart';
import 'package:pocketshopping/src/channels/repository/channelRepo.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/customer.dart';
import 'package:pocketshopping/src/order/repository/orderItem.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/review/repository/ReviewRepo.dart';
import 'package:pocketshopping/src/review/repository/reviewObj.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/MyOrder/orderGlobal.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'repository/order.dart';

class DeliveryTrackerWidget extends StatefulWidget {
  DeliveryTrackerWidget({this.order, this.user});

  final Order order;
  final User user;

  @override
  State<StatefulWidget> createState() => _DeliveryTrackerWidgetState();
}

class _DeliveryTrackerWidgetState extends State<DeliveryTrackerWidget> {

  String counter;
  int _start;
  Timer _timer;
  Merchant merchant;
  String resolution;
  Stream<LocalNotification> _notificationsStream;
  int moreSec;
  int reply;
  dynamic delayTime;
  bool rating;
  final _review = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  double _rating;
  var _delay = TextEditingController();
  int delay;

  //Session CurrentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  OrderGlobalState odState;
  Order _order;
  bool loading;
  Review review;
  bool _validate;

  @override
  void initState() {
    delay=5;
    _validate = false;
    loading = false;
    _order = widget.order;
    odState = Get.find();
    rating = false;
    _rating = 1.0;
    resolution = isNotEmpty() ? getItem('eResolution') : 'START';
    reply = isNotEmpty() ? getItem('eMoreSec') : 0;
    moreSec = isNotEmpty() ? getItem('eMoreSec') : _order.orderETA;
    delayTime = isNotEmpty() ? getItem('eDelayTime') : null;
    _start = isNotEmpty() ? Utility.setStartCount(getItem('delayTime'), getItem('moreSec')) : Utility.setStartCount(_order.orderCreatedAt, _order.orderETA);
    counter = '${isNotEmpty() ? (Utility.setStartCount(getItem('delayTime'), getItem('moreSec')) / 60).round() : (Utility.setStartCount(_order.orderCreatedAt, _order.orderETA) / 60).round()} min to ${_order.orderMode.mode}';
    startTimer();
    MerchantRepo.getMerchant(_order.orderMerchant).then((value) => setState(() {merchant = value;}));

    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      if (notification != null) {
        if (mounted && notification.data['data']['payload'].toString().isNotEmpty) {
          var payload = jsonDecode(notification.data['data']['payload']);
          switch (payload['NotificationType']) {
            case 'OrderResolutionResponse':
              print('seen');
              //globalStateUpdate();
              NotificationsBloc.instance.clearNotification();
              break;
          }
        }
      }
    });
    setRate();
    super.initState();
  }

  dynamic getItem(String key) {
    return odState.order[_order.docID][key];
  }

  setRate() {
    if (_order.orderCustomer.customerReview.isNotEmpty)
      ReviewRepo.getOne(_order.orderCustomer.customerReview)
          .then((value) => setState(() {
        review = value;
      }));
  }

  void refreshOrder() {
    setState(() {loading = true;});
    OrderRepo.getOne(_order.docID).then((value) => setState(() {
      _order = value;
      loading = false;
    }));
    setRate();
  }

  void globalStateUpdate() {
    odState.adder(_order.docID, {
      'resolution': resolution,
      'reply': reply,
      'moreSec': moreSec,
      'delayTime': delayTime,
    });
    Get.put(odState);
  }

  bool isNotEmpty() {
    return odState.order.containsKey(_order.docID);
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
              Get.back(result: 'Refresh');
            },
          ),
          title: Text(
            'Delivery Tracker',
            style: TextStyle(color: PRIMARYCOLOR),
          ),
          automaticallyImplyLeading: false,
        ),
        body: !loading ?
        ListView(children: [
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Text(
                        'Status: ${_order.orderConfirmation.isConfirmed ? 'Completed' : 'PROCESSING'}',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),

                  //timer/resolution phase
                  _start > 0
                      ? !_order.orderConfirmation.isConfirmed
                        ? Loader(_start, moreSec, counter) : Rating()
                      : _order.orderConfirmation.isConfirmed
                        ? Rating() : Resolution() ,
                  //end of phase

                   psHeadlessCard(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          //offset: Offset(1.0, 0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                      child: Container(
                        color: Colors.green,
                        child: FlatButton(
                          onPressed: () {
                            Get.defaultDialog(
                              title: 'Confirmation',
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Enter Confirmation code:'),
                                  Form(
                                    key: _formKey,
                                    child:
                                  TextFormField(
                                    validator: (value) {
                                      if (value != widget.order.orderConfirmation.confirmOTP) {
                                        return 'Wrong Confirmation Code';
                                      }
                                      return null;
                                    },
                                    controller: null,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.confirmation_number),
                                      hintText: 'Confirmation Code',
                                      filled: true,
                                      fillColor: Colors.grey.withOpacity(0.2),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                      ),
                                    ),
                                    autofocus: true,
                                    enableSuggestions: true,
                                    textInputAction: TextInputAction.done,
                                    autovalidate: _validate,
                                    onChanged: (value) {setState(() {_validate=true;});},
                                  )
                                    ,)
                                ],
                              ),
                              cancel: FlatButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text('No'),
                              ),
                              confirm: FlatButton(
                                onPressed: () {
                                  if(_formKey.currentState.validate())
                                  {
                                    Get.back();
                                    confirm(
                                        _order.docID,
                                        Confirmation(
                                          confirmOTP: _order
                                              .orderConfirmation
                                              .confirmOTP,
                                          confirmedAt: DateTime.now(),
                                          isConfirmed: true,
                                        ));
                                  }
                                  //refreshOrder();
                                },
                                child: Text('Yes Confirm'),
                              ),
                            );
                          },
                          child: Center(
                            child: Text(
                              'Confirm Order',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
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
                                'Customer Details',
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
                                  child: Text('Name:'),
                                ),
                                Expanded(
                                  child: Text(
                                      '${widget.order.orderCustomer.customerName}'),
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
                                  child: Text('Telephone:'),
                                ),
                                Expanded(
                                  child: Text(
                                      '${widget.order.orderCustomer.customerTelephone}'),
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
                                  child: Text('Address:'),
                                ),
                                Expanded(
                                  child: Text(
                                      '${widget.order.orderMode.address}'),
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
                                  child: FlatButton.icon(
                                      onPressed: (){},
                                      color: Colors.green,
                                      icon: Icon(Icons.place,color: Colors.white,),
                                      label: Text('Map',style: TextStyle(color: Colors.white),)),
                                )
                              ],
                            )
                        ),

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
                                'Order Details',
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
                                  child: Text('Merchant Address:'),
                                ),
                                Expanded(
                                  child: Text(
                                      '${merchant != null ? merchant.bAddress : ''}'),
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
                                  child: Text('${_order.orderMode.mode}'),
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
                                      '${Utility.presentDate(DateTime.parse((_order.orderCreatedAt as Timestamp).toDate().toString()))}'),
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
                                  child: Text('${_order.docID}'),
                                )
                              ],
                            )),
                        if(widget.order.orderMode.mode == 'Delivery')
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
                                  child: FlatButton.icon(
                                      onPressed: (){},
                                      color: Colors.green,
                                      icon: Icon(Icons.place,color: Colors.white,),
                                      label: Text('Map',style: TextStyle(color: Colors.white),)),
                                )
                              ],
                            )
                        ),
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
                                _order.orderItem.length,
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
                                        MediaQuery.of(context)
                                            .size
                                            .width *
                                            0.02),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                              '${_order.orderItem[index].ProductName}'),
                                        ),
                                        Expanded(
                                          child: Text(
                                              '${_order.orderItem[index].count}'),
                                        ),
                                        Expanded(
                                          child: Text(
                                              '\u20A6${_order.orderItem[index].totalAmount}'),
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
                                  child: Text('\u20A6${_order.orderAmount}'),
                                )
                              ],
                            )),
                        _order.orderMode.mode == 'Delivery'
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
                                MediaQuery.of(context).size.width *
                                    0.02),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text('Delivery Fee:'),
                                ),
                                Expanded(
                                  child:
                                  Text('\u20A6${_order.orderMode.fee}'),
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
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '\u20A6${_order.orderMode.mode != 'Delivery' ? _order.orderAmount : (_order.orderAmount + _order.orderMode.fee)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
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
                      child:FlatButton.icon(
                        color: Colors.red,
                        onPressed: (){},
                        icon: Icon(Icons.close,color: Colors.white,),
                        label:  Text('Cancel Order',style: TextStyle(color: Colors.white),),
                      )),
                  psHeadlessCard(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          //offset: Offset(1.0, 0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                      child: QrImage(
                        data: _order.docID,
                      ))
                ],
              ),
            ),
          ),
        ])
            : Center(
            child: JumpingDotsProgressIndicator(
              fontSize: MediaQuery.of(context).size.height * 0.12,
              color: PRIMARYCOLOR,
            )),
      ),
    );
  }

  Future<bool> _willPopScope() async {
    Get.back(result: 'Refresh');
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
                  if (default_) countDownFormatter(_start);
                }
              },
            )
          }
      },
    );
  }


  void countDownFormatter(int sec) {
    int minute = 0;
    int second = 0;

    minute = (sec / 60).round();
    second = (sec % 60) * 60;
    if (minute > 0)
      setState(() {
        counter = '$minute min to ${_order.orderMode.mode}';
      });
    else
      setState(() {
        counter = '$_start sec to ${_order.orderMode.mode}';
      });
  }

  void pingingTimer({Function action}) {
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




  Widget Resolution() {
    switch (resolution) {
      case 'START':
        return Container(
          //padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: psHeadlessCard(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    //offset: Offset(1.0, 0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ],
                child: Padding(padding:EdgeInsets.symmetric(vertical: 10,horizontal: 15),child:Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        "Time's up! Customer is waiting.. what is holding you back?",
                        style: TextStyle(fontSize: 18),textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20,),
                    Form(
                      key: _formKey2,
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
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Extend duration by:(min)')),
                          DropdownButtonFormField<int>(
                            value: delay,
                            items: [5, 10, 15]
                                .map((label) => DropdownMenuItem(
                              child: Text(
                                '$label',
                                style: TextStyle(
                                    color: Colors.black54),
                              ),
                              value: label,
                            ))
                                .toList(),
                            //hint: Text('How many minute delay'),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                fillColor: Colors.grey.withOpacity(0.2),
                            filled: true),
                            onChanged: (value) {
                              setState(() {
                                delay = value;
                              });
                            },

                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: FlatButton(
                            onPressed: () {setState(() {resolution="WAIT"; reply=120;});},
                            child: Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: PRIMARYCOLOR,
                          ),
                        )
                      ],
                    )
                  ],
                )
                )
              )
            );
        break;
        case "WAIT":
          pingingTimer(action: () {
            //if (moreSec == 0)
              setState(() {
                resolution = 'START';
              });
          });
          return Loader(reply, 120, 'Waiting.');
        break;
    }
  }

  Widget Rating() {
    if (_order.orderCustomer.customerReview.isNotEmpty) {
      return review != null
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
                  Center(
                    child: Text('Your Review'),
                  ),
                  RatingBar(
                    //onRatingUpdate: (rate){},
                    initialRating: review.reviewRating,
                    minRating: 1,
                    maxRating: 5,
                    itemSize: MediaQuery.of(context).size.width * 0.08,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    ignoreGestures: true,
                    itemCount: 5,
                    //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(review.reviewText)),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Text(
                          '${Utility.presentDate(DateTime.parse((review.reviewedAt).toDate().toString()))}'),
                    ),
                  ),
                ],
              )))
          : Container();
    } else {
      return !rating
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
                  Center(
                    child: Text(
                      'Rate ${merchant != null ? merchant.bName : ''}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      'click star to increase rate',
                    ),
                  ),
                  RatingBar(
                    onRatingUpdate: (rate) {
                      setState(() {
                        _rating = rate;
                      });
                    },
                    initialRating: 1,
                    minRating: 1,
                    maxRating: 5,
                    itemSize: MediaQuery.of(context).size.width * 0.1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  TextFormField(
                    controller: _review,
                    decoration: InputDecoration(
                      labelText: 'Your Review',
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
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          rating = true;
                        });
                        ReviewRepo.save(Review(reviewText: _review.text, reviewRating: _rating, reviewedMerchant: merchant.mID, reviewedAt: Timestamp.now(), customerId: _order.customerID, customerName: _order.orderCustomer.customerName)).then((value) => OrderRepo
                            .review(
                            _order.docID,
                            Customer(
                              customerName:
                              _order.orderCustomer.customerName,
                              customerTelephone: _order
                                  .orderCustomer.customerTelephone,
                              customerReview: value,
                            )).then((value) => setState(() {
                          rating = false;
                          refreshOrder();
                        })));
                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: PRIMARYCOLOR,
                    ),
                  ),
                  Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Text('Your review is very important to us.'),
                  ),
                ],
              )))
          : Center(
        child: JumpingDotsProgressIndicator(
          fontSize: MediaQuery.of(context).size.height * 0.12,
          color: PRIMARYCOLOR,
        ),
      );
    }
  }

  Widget Loader(int current, int total, String message) {
    return Container(
        //width: MediaQuery.of(context).size.width * 0.3,
        //height: MediaQuery.of(context).size.height * 0.18,
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

  bool confirm(String oid, Confirmation confirmation) {
    bool isDone = true;
    OrderRepo.confirm(oid, confirmation).catchError((onError) {
      isDone = false;
    });

    if (isDone) {
      refreshOrder();
      GetBar(
        title: 'Order Confirmed',
        messageText: Text(
          'Take your time to rate this merchant your rating will help us '
              ' improve our service',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 10),
        backgroundColor: PRIMARYCOLOR,
      ).show();
    }

    return isDone;
  }
}
