import 'dart:async';
import 'dart:convert';

import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  bool rating;
  var _review = TextEditingController();
  double _rating;

  //Session CurrentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  var scroller = ScrollController();
  bool pingStart;
  OrderGlobalState odState;
  Order _order;
  bool loading;
  Review review;
  Channels channel;

  @override
  void initState() {
    loading = false;
    _order = widget.order;
    odState = Get.find();
    rating = false;
    _rating = 1.0;
    resolution = isNotEmpty() ? getItem('resolution') : 'START';
    comment = isNotEmpty() ? getItem('comment') : '';
    deliveryman = isNotEmpty() ? getItem('deliveryman') : '';
    reply = isNotEmpty() ? getItem('reply') : 0;
    pingStart = isNotEmpty() ? getItem('pingStart') : false;
    bubble = isNotEmpty() ? getItem('bubble') : [];
    _start = isNotEmpty()
        ? Utility.setStartCount(getItem('delayTime'), getItem('moreSec'))
        : Utility.setStartCount(_order.orderCreatedAt, _order.orderETA);
    counter =
        '${isNotEmpty() ? (Utility.setStartCount(getItem('delayTime'), getItem('moreSec')) / 60).round() : (Utility.setStartCount(_order.orderCreatedAt, _order.orderETA) / 60).round()} min to ${_order.orderMode.mode}';
    startTimer();
    MerchantRepo.getMerchant(_order.orderMerchant).then((value) => setState(() {
          merchant = value;
        }));
    moreSec = isNotEmpty() ? getItem('moreSec') : _order.orderETA;
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
                _start = Utility.setStartCount(delayTime, moreSec);
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
    ChannelRepo.get(_order.orderMerchant).then((value) => channel = value);
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

  Order refreshOrder() {
    setState(() {
      loading = true;
    });
    OrderRepo.getOne(_order.docID).then((value) => setState(() {
          _order = value;
          loading = false;
        }));
    setRate();
  }

  void globalStateUpdate() {
    odState.adder(_order.docID, {
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
              Get.back();
            },
          ),
          title: Text(
            'Tracker',
            style: TextStyle(color: PRIMARYCOLOR),
          ),
          automaticallyImplyLeading: false,
        ),
        body: !loading
            ? ListView(children: [
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
                              'Status: ${_order.orderConfirmation.isConfirmed ? 'Completed' : 'Processing'}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        _start > 0
                            ? !_order.orderConfirmation.isConfirmed
                                ? Loader(_start, moreSec, counter)
                                : Rating()
                            : _order.orderConfirmation.isConfirmed
                                ? Rating()
                                : _order.orderMode.mode == 'Delivery'
                                    ? Resolution()
                                    : _order.orderMode.mode == 'Pickup'
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
                                                        style: TextStyle(
                                                            fontSize: 18),
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
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    child: ListView(
                                      controller: scroller,
                                      children: bubble.toList() ?? Container(),
                                    )))
                            : Container(),
                        (!_order.orderConfirmation.isConfirmed && _start > 0) ||
                                (_order.orderMode.mode == 'Pickup' &&
                                    !_order.orderConfirmation.isConfirmed)
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
                                    onPressed: () {
                                      Get.defaultDialog(
                                        title: 'Confirmation',
                                        content: Text(
                                            'Confirming this order implies you have recieved your package.'
                                            ' please note this action can not be undone.'),
                                        cancel: FlatButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: Text('No'),
                                        ),
                                        confirm: FlatButton(
                                          onPressed: () {
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
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text('Confirmed:'),
                                        ),
                                        Expanded(
                                          child: Text(widget.order
                                                  .orderConfirmation.isConfirmed
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
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text('Confirmation code:'),
                                        ),
                                        Expanded(
                                          child: Text(widget.order
                                              .orderConfirmation.confirmOTP),
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
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text('Confirmed:'),
                                        ),
                                        Expanded(
                                          child: Text(
                                              '${_order.orderConfirmation.confirmedAt == null ? '-' :Utility.presentDate(DateTime.parse((_order.orderConfirmation.confirmedAt as Timestamp).toDate().toString()))}'),
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
                                                    '${_order.orderItem[index].totalAmount}'),
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
                                        child: Text('${_order.orderAmount}'),
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
                                                Text('${_order.orderMode.fee}'),
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
                                          '${_order.orderMode.mode != 'Delivery' ? _order.orderAmount : (_order.orderAmount + _order.orderMode.fee)}',
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
        counter = '$minute min to ${_order.orderMode.mode}';
      });
    else
      setState(() {
        counter = '$_start sec to ${_order.orderMode.mode}';
      });
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
                          onPressed: () {
                            Get.defaultDialog(
                              title: 'Confirmation',
                              content: Text(
                                  'Confirming this order implies you have recieved your package.'
                                  ' please note this action can not be undone.'),
                              cancel: FlatButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text('No'),
                              ),
                              confirm: FlatButton(
                                onPressed: () {
                                  Get.back();
                                  confirm(
                                      _order.docID,
                                      Confirmation(
                                        confirmOTP:
                                            _order.orderConfirmation.confirmOTP,
                                        confirmedAt: DateTime.now(),
                                        isConfirmed: true,
                                      ));
                                  //refreshOrder();
                                },
                                child: Text('Yes Confirm'),
                              ),
                            );
                          },
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
              'orderID': _order.docID,
              'Items': OrderItem.toListMap(_order.orderItem),
              'Amount': _order.orderAmount,
              'type': _order.orderMode.mode,
              'Address': _order.orderMode.mode == 'Delivery'
                  ? _order.orderMode.address
                  : '',
              'telephone': _order.orderCustomer.customerTelephone,
              'fcmToken': widget.user.notificationID,
            }
          },
          'registration_ids': channel.dChannels,
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
