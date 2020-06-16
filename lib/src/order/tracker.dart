import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/channels/repository/channelRepo.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/customer.dart';
import 'package:pocketshopping/src/order/repository/orderItem.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/repository/receipt.dart';
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

  String counter;
  int _start;
  Timer _timer;
  Merchant merchant;
  String resolution;
  Stream<LocalNotification> _notificationsStream;
  String comment;
  int moreSec;
  int reply;
  List<String> bubble;
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
  String channel;
  User agent;
  bool agentTime;

  @override
  void initState() {
    //clear notification stream
    //NotificationsBloc.instance.clearNotification();

    loading = false;
    _order = widget.order;
    odState = Get.find();
    rating = false;
    _rating = 1.0;
    agentTime = isNotEmpty() ? getItem('agentTime') :false;
    resolution = isNotEmpty() ? getItem('resolution') : 'START';
    comment = isNotEmpty() ? getItem('comment') : '';
    reply = isNotEmpty() ? getItem('reply') : 0;
    pingStart = isNotEmpty() ? getItem('pingStart') : false;
    bubble = isNotEmpty() ? getItem('bubble') : [];
    _start = isNotEmpty()
        ? Utility.setStartCount(getItem('delayTime'), getItem('moreSec'))
        : Utility.setStartCount(_order.orderCreatedAt, _order.orderETA);
    counter =
        '${isNotEmpty() ? (Utility.setStartCount(getItem('delayTime'), getItem('moreSec')) / 60).round() : (Utility.setStartCount(_order.orderCreatedAt, _order.orderETA) / 60).round()} min to ${_order.orderMode.mode}';
    startTimer();
    UserRepo.getOneUsingUID(_order.agent).then((value){if(mounted)setState((){agent=value;});} );
    MerchantRepo.getMerchant(_order.orderMerchant).then((value){if(mounted) setState(() {merchant = value;});});
    moreSec = isNotEmpty() ? getItem('moreSec') : _order.orderETA;
    delayTime = isNotEmpty() ? getItem('delayTime') : null;
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      if (notification != null) {
        if (mounted && notification.data['data']['payload'].toString().isNotEmpty) {
          var payload = jsonDecode(notification.data['data']['payload']);
          switch (payload['NotificationType']) {
            case 'OrderResolutionMerchantResponse':
              if(payload['orderID'] == _order.docID) {
                setState(() {
                  bubble.clear();
                  comment = payload['comment'] as String;
                  moreSec = (payload['delay'] as int) * 60;
                  resolution = 'START';
                  delayTime = Timestamp(payload['time'][0], payload['time'][1]);
                  _start = Utility.setStartCount(delayTime, moreSec);
                  bubble.add(payload['comment']);
                  bubble.add('${payload['delay']}');
                  startTimer();
                });
                globalStateUpdate();
                NotificationsBloc.instance.clearNotification();
              }
              break;
            case 'OrderCancelledResponse':
              if(_order.docID == payload['orderID']) {
                Get.defaultDialog(

                  title: 'Cancelled',
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(
                        child: const Icon(Icons.close,color: Colors.red,size: 100,),
                      ),
                      Center(
                        child: Text(
                            'Your order has been cancelled '
                                'by the agent (reason: ${payload['reason']}). ${_order
                                .receipt.type != 'CASH'
                                ? 'Please Note. your money has been refunded to your wallet'
                                : ''}'
                        ),
                      )
                    ],
                  ),
                  confirm: FlatButton(
                    onPressed: () {
                      Get.back();
                      refreshOrder();
                    },
                    child: const Text('OK'),
                  ),
                );
                NotificationsBloc.instance.clearNotification();
              }
              break;
            case 'OrderConfirmationAgentResponse':
              if(payload['orderID'] == _order.docID){
                Get.defaultDialog(title:
                "Confirmation",
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(
                        child: const Icon(Icons.check,color: Colors.green,size: 100,),
                      ),
                      Center(
                        child: Text('This Order(${payload['orderID']}) has been confirmed by the agent(${agent.fname}). This is possible because you gave him/her your confirmation code. Thanks'),
                      )
                    ],
                  ),
                  confirm: FlatButton(
                    onPressed: () {
                      Get.back();
                      refreshOrder();
                    },
                    child: const Text('OK'),
                  ),
                );
                NotificationsBloc.instance.clearNotification();
              }

              break;
          }
        }
      }
    });
    ChannelRepo.getAgentChannel(_order.agent).then((value) => channel = value);
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
      'reply': reply,
      'pingStart': pingStart,
      'bubble': bubble,
      'moreSec': moreSec,
      'delayTime': delayTime,
      'agentTime':true,
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
          title: const Text(
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
                            child: Text('Status: ${_order.status != 0 ? _order.receipt.psStatus=='success'?'Completed':'Cancelled' : 'PROCESSING'}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        if(_order.status != 0 && _order.receipt.psStatus=='fail')
                          psCard(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  //offset: Offset(1.0, 0), //(x,y)
                                  blurRadius: 6.0,
                                ),
                              ],
                              color: PRIMARYCOLOR,
                              title: "Reason for concellation.",
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Column(
                                    children: [
                                      Text(_order.receipt.pRef,style: TextStyle(fontSize: 16),
                                        textAlign: TextAlign.start,),
                                      if(_order.receipt.type == 'CARD' || _order.receipt.type == 'POCKET')
                                      Text('Please note. Yor money has been refunded to your pocket',
                                        textAlign: TextAlign.start,style: TextStyle(fontSize: 14),),
                                    ],
                                  )
                              )
                          ),

                        _start > 0
                            ? !_order.orderConfirmation.isConfirmed && _order.status == 0
                                ? Loader(_start, moreSec, counter)
                                : Rating()
                            : _order.orderConfirmation.isConfirmed
                                ? Rating()
                                :_order.status == 0?
                                  _order.orderMode.mode == 'Delivery'
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
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    const Center(
                                                      child: const Text(
                                                        'Your order is ready for pickup.',
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                  ],
                                                )))
                                        : const SizedBox.shrink(): Rating(),

                        if (pingStart)
                             if(bubble.isNotEmpty)
                        psHeadlessCard(
                                boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      //offset: Offset(1.0, 0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    child: Column(
                                      children: [
                                        Text(bubble.first,style: TextStyle(fontSize: 16),
                                        textAlign: TextAlign.start,),
                                        Text('Please wait for ${bubble.last} min',
                                          textAlign: TextAlign.start,style: TextStyle(fontSize: 16),),
                                      ],
                                    )
                                )
                        ),
                        if(agentTime && _order.orderMode.mode == 'Delivery' && agent != null)
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
                                        child:const Align(
                                          alignment: Alignment.centerLeft,
                                          child: const Text(
                                            'Delivery Personel',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        )
                                    ),
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
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${agent.fname}',
                                            style: const TextStyle(color: Colors.black,fontSize: 18),
                                          ),
                                        )
                                    ),
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
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${agent.telephone}',
                                            style: const TextStyle(color: Colors.black,fontSize: 18),
                                          ),
                                        )
                                    ),
                                  ]
                              )
                          ),
                        (!_order.orderConfirmation.isConfirmed && _start > 0 && _order.status == 0) ||
                                (_order.orderMode.mode == 'Pickup' && !_order.orderConfirmation.isConfirmed && _order.status == 0)
                            ? psHeadlessCard(
                                boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      //offset: Offset(1.0, 0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                child: Container(
                                  color:  Colors.green,
                                  child: FlatButton.icon(
                                    onPressed: () {
                                      Get.defaultDialog(
                                        title: 'Confirmation',
                                        content: const Text(
                                            'Confirming this order implies you have recieved your package.'
                                            ' please note this action can not be undone.'),
                                        cancel: FlatButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: const Text('No'),
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
                                                  confirmedAt:  DateTime.now(),
                                                  isConfirmed: true,
                                                ),
                                                Receipt.fromMap(_order.receipt.copyWith(psStatus: "success").toMap())
                                            );
                                            //refreshOrder();
                                          },
                                          child: const Text('Yes Confirm'),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.check,color: Colors.white,),
                                    label: const Center(
                                      child: const Text(
                                        'Confirm Order',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ))
                            : const SizedBox.shrink(),
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
                                        const Expanded(
                                          child:const Text('Confirmed:'),
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
                                        const Expanded(
                                          child: const Text('Confirmation code:'),
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
                                        const Expanded(
                                          child: const Text('Confirmed:'),
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
                                  child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: const Text(
                                      'Order Deatils',
                                      style:const TextStyle(color: Colors.white),
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
                                      const Expanded(
                                        child: const Text('Merchant:'),
                                      ),
                                      Expanded(
                                        child: Text(
                                            '${merchant != null ? merchant.bName : ''}'),
                                      )
                                    ],
                                  )),
                              if(_order.orderMode.mode != 'Delivery' && !merchant.adminUploaded )
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
                                      const Expanded(
                                        child: const Text('Merchant Contact:'),
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
                                      const Expanded(
                                        child: const Text('Category:'),
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
                                      const Expanded(
                                        child: const Text('Mode:'),
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
                                      const Expanded(
                                        child: const Text('Placed:'),
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
                                      const Expanded(
                                        child: const Text('OrderId:'),
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
                                  child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: const Text(
                                      'Order Items',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  )),
                              SizedBox(height: 10,),
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
                                      MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.02),
                                  child:
                              Row(children: [
                                const Expanded(
                                    child:const Center(child:const Text(
                                        'Item'),
                                    )),
                                const Expanded(
                                    child: const Center(child:const Text(
                                        'Quantity'),
                                    )),
                                const Expanded(
                                    child: const Center(child:const Text(
                                        'Item Price($CURRENCY) '),
                                    ))
                              ],)),
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
                                                child: Center(child:Text(
                                                    '${_order.orderItem[index].ProductName}'),
                                              )),
                                              Expanded(
                                                child: Center(child:Text(
                                                    '${_order.orderItem[index].count}'),
                                              )),
                                              Expanded(
                                                child: Center(child:Text(
                                                    '$CURRENCY${_order.orderItem[index].totalAmount}'),
                                              ))
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
                                      const Expanded(
                                        child: const Text('Item Total:'),
                                      ),
                                       Expanded(
                                        child: Text('$CURRENCY${_order.orderAmount}'),
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
                                          const Expanded(
                                            child: const Text('Delivery Fee:'),
                                          ),
                                          Expanded(
                                            child:
                                                Text('$CURRENCY${_order.orderMode.fee}'),
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
                                      const Expanded(
                                        child: const Text(
                                          'Total:',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '$CURRENCY${_order.orderMode.mode != 'Delivery' ? _order.orderAmount : (_order.orderAmount + _order.orderMode.fee)}',
                                          style: const TextStyle(
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
                            child:  QrImage(
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
                  if(bubble.isNotEmpty){
                    bubble.clear();
                    globalStateUpdate();
                  }
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
        if(_order.orderMode.mode == 'Delivery')setState(() {agentTime=true;});
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
                    const SizedBox(
                      height: 20,
                    ),
                    const Center(
                      child: const Text(
                        'Have you recieved your package?',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FlatButton(
                          onPressed: () {
                            Get.defaultDialog(
                              title: 'Confirmation',
                              content: const Text(
                                  'Confirming this order implies you have recieved your package.'
                                  ' please note this action can not be undone.'),
                              cancel: FlatButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text('No'),
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
                                      ),
                                      Receipt.fromMap(_order.receipt.copyWith(psStatus: "success").toMap())
                                  );
                                  //refreshOrder();
                                },
                                child: const Text('Yes Confirm'),
                              ),
                            );
                          },
                          child: const Text(
                            'Yes',
                            style: const TextStyle(color: Colors.white),
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
                            });
                          },
                          child:
                          const Text('No', style: const TextStyle(color: Colors.white)),
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
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        'Waiting for response from ${merchant.bName}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(
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
                            });
                            //scroller.animateTo(scroller.position.maxScrollExtent);
                          },
                          child: const Text('Reping',
                              style: const TextStyle(color: Colors.white)),
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
                        child: const Text('Your Review'),
                      ),
                      RatingBar(
                        onRatingUpdate: (rate){},
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
                      const SizedBox(
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
                      const SizedBox(
                        height: 10,
                      ),
                      const Center(
                        child: const Text(
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
                      const Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: const Text('Your review is very important to us.'),
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
          'registration_ids': [channel],
        }));
  }

  Future<void> confirmNotifier() async {
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
            'body': 'Hello. ${merchant.bName} Order(${_order.docID}) has been confirmed by the customer(${widget.user.fname}). Your cut has been transferred to the neccessary channel. Thanks',
            'title': 'Order Confirmation'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'OrderConfirmationResponse',
              'orderID': _order.docID,
              'merchant': merchant.bName,
              'fcmToken': widget.user.notificationID,
            }
          },
          'registration_ids': [channel],
        })).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
  }

  bool confirm(String oid, Confirmation confirmation,Receipt receipt) {
    bool isDone = true;
    int unit = (_order.orderMode.fee * 0.1).round();
    Geolocator().distanceBetween(merchant.bGeoPoint['geopoint'].latitude, merchant.bGeoPoint['geopoint'].longitude,
        _order.orderMode.coordinate.latitude, _order.orderMode.coordinate.longitude).then((value) {
      OrderRepo.confirm(oid, confirmation,receipt,agent.uid,
          _order.orderMode.fee,value.round(),unit>100?100:unit).catchError((onError) {
        isDone = false;
      });
    });

    if (isDone) {
      refreshOrder();
      confirmNotifier().then((value) => null);
      GetBar(
        title: 'Order Confirmed',
        messageText: const Text(
          'Take your time to rate this merchant your rating will help us '
          ' improve our service',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 10),
        backgroundColor: PRIMARYCOLOR,
      ).show();

    }

    return isDone;
  }
}
