import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/order/customerMapTracker.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/customer.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/repository/receipt.dart';
import 'package:pocketshopping/src/review/repository/ReviewRepo.dart';
import 'package:pocketshopping/src/review/repository/reviewObj.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
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


  final _review = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _delay = TextEditingController();
  final FirebaseMessaging _fcm = FirebaseMessaging();


  //Session CurrentUser;
  String counter;
  int _start;
  Timer _timer;
  Merchant merchant;
  String resolution;
  Stream<LocalNotification> _notificationsStream;
  int moreSec;
  //int reply;
  dynamic delayTime;
  bool rating;
  Order _order;
  bool loading;
  Review review;
  bool _validate;
  double _rating;
  int delay;
  User customer;
  String reason;
  bool autoval;

  @override
  void initState() {
    autoval =false;
    reason = 'Select';
    delay=5;
    _validate = false;
    loading = false;
    _order = widget.order;
    rating = false;
    _rating = 1.0;
    //print(_order.docID);
    resolution =  'START';
    //reply = isNotEmpty() ? (getItem('eMoreSec')*60) : 0;
    startTimer();
    MerchantRepo.getMerchant(_order.orderMerchant).then((value) { if(mounted)setState(() {merchant = value;});});
    UserRepo.getOneUsingUID(widget.order.customerID).then((value) { if(mounted)setState(() {customer = value;});});

    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      if (notification != null) {
        try {
          if (mounted && notification.data['data']['payload']
              .toString()
              .isNotEmpty) {
            var payload = jsonDecode(notification.data['data']['payload']);
            switch (payload['NotificationType']) {
              case 'OrderConfirmationResponse':
                if (payload['orderID'] == _order.docID) {
                  Get.defaultDialog(title:
                  "Confirmation",
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Icon(
                            Icons.check, color: Colors.green, size: 100,),
                        ),
                        Center(
                          child: Text(
                              'This Order(${payload['orderID']}) has been confirmed by the customer(${customer
                                  .fname}). Your cut has been transferred to the neccessary channel. Thanks'),
                        )
                      ],
                    ),
                    confirm: FlatButton(
                      onPressed: () {
                        Get.back();
                        refreshOrder();
                      },
                      child: Text('OK'),
                    ),
                  );
                  NotificationsBloc.instance.clearNotification();
                }

                break;
            }
          }
        }catch(_){}
      }
    });
    setRate();
    super.initState();
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
                                  const SizedBox(height: 10,),
                                  const Text('Please note. All account has been refunded appropriately.',
                                    textAlign: TextAlign.start,style: TextStyle(fontSize: 14),),
                              ],
                            )
                        )
                    ),

                  //timer/resolution phase
                      _start > 0
                      ? (!_order.orderConfirmation.isConfirmed && _order.status == 0)
                        ? loader(_start, moreSec, counter) : Rating()
                      :_order.orderConfirmation.isConfirmed ? Rating() :
                       _order.status == 0?
                      Resolution() : Rating(),
                  //end of phase

                  !_order.orderConfirmation.isConfirmed && _order.status == 0?
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
                                        ),
                                      Receipt.fromMap(_order.receipt.copyWith(psStatus: "success").toMap())
                                    );
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
                      )
                   ):Container(),
                  if(widget.user.uid != _order.agent)
                  FutureBuilder<AgentLocUp>(
                    future: LogisticRepo.getOneAgentLocationUsingUid((_order.agent)),
                    initialData: null,
                    builder: (_, AsyncSnapshot<AgentLocUp> agent){
                      if(agent.hasData){
                        return psHeadlessCard(
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
                                          'Delivery Agent',
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
                                          '${agent.data.agentName}',
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
                                          '${agent.data.agentTelephone}',
                                          style: const TextStyle(color: Colors.black,fontSize: 18),
                                        ),
                                      )
                                  ),
                                ]
                            )
                        );
                      }
                      else{return const SizedBox.shrink();}
                    },
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
                        if(_order.status == 0 && _order.orderMode.mode=='Delivery')
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
                                      onPressed: (){
                                        Get.to(
                                            (widget.user.uid == _order.agent)?
                                            Direction(
                                              source: LatLng(merchant.bGeoPoint['geopoint']
                                                  .latitude,
                                                  merchant.bGeoPoint['geopoint']
                                                      .longitude
                                              ),
                                              destination: LatLng(
                                                _order.orderMode.coordinate.latitude,
                                                _order.orderMode.coordinate.longitude,
                                              ),
                                              destAddress: _order.orderMode.address,
                                              destName: _order.orderCustomer.customerName,
                                              sourceName: merchant.bName,
                                              sourceAddress: merchant.bAddress,
                                            ):
                                                CustomerMapTracker(
                                                  latLng: LatLng(_order.orderMode.coordinate.latitude,_order.orderMode.coordinate.longitude,),
                                                  customerName: _order.orderCustomer.customerName,
                                                  telephone: _order.orderCustomer.customerTelephone
                                                  ,)
                                        );
                                      },
                                      color: Colors.green,
                                      icon: Icon(Icons.place,color: Colors.white,),
                                      label: Text('Customer Map',style: TextStyle(color: Colors.white),)),
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
                        if(_order.status == 0 && _order.orderMode.mode=='Delivery')
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
                                      onPressed: (){
                                        Get.to(
                                            (widget.user.uid == _order.agent)?
                                            Direction(
                                              source: LatLng(merchant.bGeoPoint['geopoint'].latitude,
                                                  merchant.bGeoPoint['geopoint']
                                                      .longitude
                                              ),
                                              destination: LatLng(
                                                merchant.bGeoPoint['geopoint']
                                                    .latitude,
                                                merchant.bGeoPoint['geopoint']
                                                    .longitude,
                                              ),
                                              destAddress: merchant.bAddress,
                                              destName: merchant.bName,
                                              sourceName: widget.user.fname,
                                              sourceAddress: widget.user.defaultAddress,
                                            ):
                                                CustomerMapTracker(
                                                  latLng: LatLng(merchant.bGeoPoint['geopoint'].latitude,
                                                      merchant.bGeoPoint['geopoint']
                                                          .longitude
                                                  ),
                                                  customerName: merchant.bName,
                                                )

                                        );
                                      },
                                      color: Colors.green,
                                      icon: Icon(Icons.place,color: Colors.white,),
                                      label: Text('Merchant Map',style: TextStyle(color: Colors.white),)),
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
                                              '$CURRENCY${_order.orderItem[index].totalAmount}'),
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
                                Expanded(
                                  child: Text('Delivery Fee:'),
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
                                Expanded(
                                  child: Text(
                                    'Total:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '$CURRENCY${_order.orderMode.mode != 'Delivery' ? _order.orderAmount : (_order.orderAmount + _order.orderMode.fee)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            )),
                      ])),
                    if(_order.status == 0   && _order.orderMode.mode=='Delivery')
                    psHeadlessCard(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          //offset: Offset(1.0, 0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                      child:Container(
                          color: Colors.red,
                          child:
                      FlatButton.icon(
                        color: Colors.red,
                        onPressed: (){
                          Get.defaultDialog(
                            title: 'Confirmation',
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Select Reason for cancelling this order:'),
                                Form(
                                  key: _formKey3,
                                  child:
                                  DropdownButtonFormField<String>(
                                    value: reason,
                                    isExpanded: true,
                                    items: [
                                      'Select',
                                      'Logistic Problem(broken automobile)',
                                      'Item(s) are unavailable',
                                      'Merchant is unavailale'
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
                                      if (value != 'Select')
                                        reason =value;
                                      else autoval = true;

                                      setState(() {});
                                    },
                                    autovalidate: autoval,
                                    validator: (value) {
                                      if (value == 'Select') {
                                        return 'Select reason';
                                      }
                                      return null;
                                    },
                                  ),
                                  )
                              ],
                            ),
                            cancel: FlatButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('No'),
                            ),
                            confirm: FlatButton(
                              onPressed: ()async {

                                if(_formKey3.currentState.validate())
                                {
                                  Get.back();
                                  var result = cancel(_order.docID,
                                      Receipt.fromMap(_order.receipt.copyWith(psStatus: "fail",
                                          pRef: '"$reason" order was cancelled by ${widget.user.fname}(Logistic)').toMap()));
                                  if(result)
                                    await cancelOrder(customer.notificationID, _order.docID, reason);

                                }
                                //refreshOrder();
                              },
                              child: Text('Yes Cancel'),
                            ),
                          );
                        },
                        icon: Icon(Icons.close,color: Colors.white,),
                        label:  Text('Cancel Order',style: TextStyle(color: Colors.white),),
                      )
                        )
                    ),
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

  Widget Resolution() {
    switch (resolution) {
      case 'START':
        return (widget.user.uid == _order.agent) ? Container(
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
                            items: [1,2,3,5, 10, 15]
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
                    customer != null?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: FlatButton(
                            onPressed: () {
                              if(_formKey2.currentState.validate()) {
                                respondResolve(
                                    delay, _delay.text, customer.notificationID,
                                    widget.order.docID).then((value) => null);

                                _start = (delay * 60);
                                moreSec = (delay * 60);
                                setState(() {});
                                startTimer();
                              }
                              },

                            child: Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: PRIMARYCOLOR,
                          ),
                        )
                      ],
                    )
                        :Container()
                  ],
                )
                )
              )
            ):Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Center(
            child: Text('Order has not been delivered by your agent. Contact your agent to confirm what holding him/her.',
              textAlign: TextAlign.center,style: TextStyle(fontSize: 16,color: Colors.red),),
          )
        );
        break;
        case "WAIT":
          startTimer();
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
                    onRatingUpdate: null,
                    initialRating: review.rating,
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
                        child: Text(review.text)),
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
          ?
      (widget.user.uid == _order.agent)?
      Container(
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
                      'Rate ${_order.orderCustomer.customerName}',
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
                        ReviewRepo.save(Review(text: _review.text, rating: _rating, reviewed: merchant.mID, reviewedAt: Timestamp.now(), reviewerId: _order.customerID, reviewerName: _order.orderCustomer.customerName)).then((value) =>
                            OrderRepo
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
              ))):const SizedBox.shrink()
          : Center(
        child: JumpingDotsProgressIndicator(
          fontSize: MediaQuery.of(context).size.height * 0.12,
          color: PRIMARYCOLOR,
        ),
      );
    }
  }

  Widget loader(int current, int total, String message) {
    return Container(
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



  bool cancel(String oid,Receipt receipt) {
    bool isDone = true;
    OrderRepo.cancel(oid,receipt,_order.agent).catchError((onError) {
      isDone = false;
    });

    if (isDone) {
      refreshOrder();
      GetBar(
        title: 'Order Cancelled',
        messageText: Text(
          'Take your time to rate this user your rating will help us '
              ' improve our service',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 10),
        backgroundColor: PRIMARYCOLOR,
      ).show();
      if(widget.user.uid != _order.agent)
      agentCancellationNotifier(_order.agent);
    }

    return isDone;
  }


  bool confirm(String oid, Confirmation confirmation,Receipt receipt){
    bool isDone = true;
    int unit = (_order.orderMode.fee * 0.1).round();
    Geolocator().distanceBetween(merchant.bGeoPoint['geopoint'].latitude, merchant.bGeoPoint['geopoint'].longitude,
        _order.orderMode.coordinate.latitude, _order.orderMode.coordinate.longitude).then((value) {
      OrderRepo.confirm(oid, confirmation,receipt,_order.agent,
        _order.orderMode.fee,value.round(),unit>100?100:unit).catchError((onError) {
        isDone = false;
      });
    });


    if (isDone) {
      refreshOrder();
      confirmNotifier().then((value) => null);
      GetBar(
        title: 'Order Confirmed',
        messageText: Text(
          'Take your time to rate this user your rating will help us '
              ' improve our service',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 10),
        backgroundColor: PRIMARYCOLOR,
      ).show();
    }

    return isDone;
  }


  Future<void> cancelOrder(String fcm, String oID,String reason) async {
    await _fcm.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),

    );
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'Your order has been cancelled by the agent (reason: $reason}). ${_order.receipt.type != 'CASH'?'Please Note. your money has been refunded to your wallet':''}',
            'title': 'Order Cancelled'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'OrderCancelledResponse',
              'orderID': oID,
              'reason': reason,
              'time': [Timestamp.now().seconds, Timestamp.now().nanoseconds],
            }
          },
          'to': fcm,
        }));
  }

  Future<void> agentCancellationNotifier(String agentId) async {
    await _fcm.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),

    );
    var agent = await LogisticRepo.getOneAgentLocationUsingUid(agentId);
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'Order has been Cancelled by the office. Check you dashboard for details',
            'title': 'Order Cancelled'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'agentCancellationNotifier',
              'time': [Timestamp.now().seconds, Timestamp.now().nanoseconds],
            }
          },
          'to': agent.device,
        }));
  }



  Future<void> respondResolve(int delay, String comment, String fcm, String oID) async {
    await _fcm.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),

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
              'time': [Timestamp.now().seconds, Timestamp.now().nanoseconds],
            }
          },
          'to': fcm,
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
            'body': 'Hello. ${merchant.bName} Order(${_order.docID}) has been confirmed by the agent. This is possible because you gave him/her your confirmation code. Thanks',
            'title': 'Order Confirmation'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'OrderConfirmationAgentResponse',
              'orderID': _order.docID,
              'merchant': merchant.bName,
            }
          },
          'to': customer.notificationID,
        }));
  }
}
