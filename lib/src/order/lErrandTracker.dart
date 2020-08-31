import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/repository/receipt.dart';
import 'package:pocketshopping/src/review/repository/ReviewRepo.dart';
import 'package:pocketshopping/src/review/repository/reviewObj.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'repository/order.dart';

class LogisticErrandTracker extends StatefulWidget {
  LogisticErrandTracker({this.order, this.user});

  final String order;
  final User user;

  @override
  State<StatefulWidget> createState() => _LogisticErrandTrackerState();
}

class _LogisticErrandTrackerState extends State<LogisticErrandTracker> {

  final FirebaseMessaging _fcm = FirebaseMessaging();
  final _review = TextEditingController();
  final rating = ValueNotifier<double>(1.0);
  final _formKey = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final reason = ValueNotifier<String>('Select');

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body:StreamBuilder<Order>(
          stream: OrderRepo.getOneSnapshot(widget.order),
          builder: (context,AsyncSnapshot<Order>order){
            if(order.connectionState == ConnectionState.waiting){
              return Center(
                child: JumpingDotsProgressIndicator(
                  fontSize: Get.height * 0.12,
                  color: PRIMARYCOLOR,
                ),
              );
            }
            else if(order.hasError){
              return Center(
                child: Text('Error communicating with server check '
                    'your internet connection and try again',textAlign: TextAlign.center,),
              );
            }
            else{
              return FutureBuilder(
                future: MerchantRepo.getMerchant(order.data.orderLogistic),
                builder: (context, AsyncSnapshot<Merchant>merchant){
                  return FutureBuilder(
                    future: UserRepo.getOneUsingUID(order.data.customerID),
                    builder: (context,AsyncSnapshot<User>customer){
                      return FutureBuilder(
                        future: ReviewRepo.getOne(order.data.orderCustomer.customerReview),
                        builder: (context, AsyncSnapshot<Review>review){
                          return ListView(
                            children: [
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
                                                child: Text('Status: ${order.data.status != 0 ? order.data.receipt.psStatus=='success'?'Completed':'Cancelled' : 'PROCESSING'}',
                                                  style: TextStyle(fontSize: 20),
                                                ),
                                              ),
                                            ),

                                            (!order.data.orderConfirmation.isConfirmed && order.data.status == 0 && order.data.isAssigned) ||
                                                (order.data.orderMode.mode == 'Pickup' && !order.data.orderConfirmation.isConfirmed && order.data.status == 0)
                                                ?
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
                                                                  if (value != order.data.orderConfirmation.confirmOTP) {
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
                                                                autovalidate: true,
                                                                onChanged: (value) {},
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
                                                                  order.data,
                                                                  merchant.data,
                                                                  widget.user,
                                                                  order.data.docID,
                                                                  Confirmation(
                                                                    confirmOTP: order.data
                                                                        .orderConfirmation
                                                                        .confirmOTP,
                                                                    confirmedAt:  DateTime.now(),
                                                                    isConfirmed: true,
                                                                  ),
                                                                  Receipt.fromMap(order.data.receipt.copyWith(psStatus: "success").toMap())
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



                                            /*if(order.data.status == 0)
                                              Center(
                                                child:
                                                Loader(
                                                  total: order.data.orderETA,
                                                  start: Utility.setStartCount(order.data.orderCreatedAt, order.data.orderETA),
                                                  message: order.data.isAssigned ?
                                                  '${(Utility.setStartCount(order.data.orderCreatedAt, order.data.orderETA) / 60).round()} min to ${order.data.orderMode.mode}':
                                                  'Confirming Order',
                                                  order: order.data.docID,
                                                  id: order.data.receipt.collectionID,
                                                  customerToken: order.data.customerDevice,
                                                ),
                                              ),*/

                                            if(order.data.status != 0 && order.data.receipt.psStatus=='fail')
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
                                                          Text(order.data.receipt.pRef,style: TextStyle(fontSize: 16),
                                                            textAlign: TextAlign.start,),
                                                          if(order.data.receipt.type == 'CARD' || order.data.receipt.type == 'POCKET')
                                                            Text('Please note. Yor money has been refunded to your pocket',
                                                              textAlign: TextAlign.start,style: TextStyle(fontSize: 14),),
                                                        ],
                                                      )
                                                  )
                                              ),


                                            FutureBuilder<AgentLocUp>(
                                              future: LogisticRepo.getOneAgentLocationUsingUid((order.data.agent)),
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
                                                                    Get.width * 0.02),
                                                                child:const Align(
                                                                  alignment: Alignment.centerLeft,
                                                                  child: const Text(
                                                                    'Rider',
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
                                                                    Get.width * 0.02),
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
                                                                    Get.width * 0.02),
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
                                                              MediaQuery
                                                                  .of(context)
                                                                  .size
                                                                  .width * 0.02),
                                                          child: const Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: const Text(
                                                              'Reciever Contact',
                                                              style: const TextStyle(
                                                                  color: Colors.white),
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
                                                              MediaQuery
                                                                  .of(context)
                                                                  .size
                                                                  .width * 0.02),
                                                          child: Align(
                                                            alignment: Alignment.center,
                                                            child: Text(
                                                              '${order.data.errand.destinationName}',
                                                              style: const TextStyle(
                                                                  color: Colors.black, fontSize: 18),
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
                                                              MediaQuery
                                                                  .of(context)
                                                                  .size
                                                                  .width * 0.02),
                                                          child: Align(
                                                              alignment: Alignment.center,
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Expanded(
                                                                      child: Center(
                                                                        child: Text(
                                                                          '${order.data.errand.destinationContact}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black, fontSize: 18),
                                                                        ),
                                                                      )

                                                                  ),
                                                                  Expanded(
                                                                      flex: 0,
                                                                      child: Center(
                                                                        child: IconButton(
                                                                          onPressed: () => launch("tel:${order.data.errand.destinationContact}"),
                                                                          icon: Icon(Icons.call),
                                                                        ),
                                                                      )
                                                                  )

                                                                ],
                                                              )
                                                          )
                                                      ),
                                                    ]
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
                                                          Get.width * 0.02),
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
                                                          Get.width * 0.02),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Text('Name:'),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                                '${order.data.orderCustomer.customerName}'),
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
                                                          Get.width * 0.02),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Text('Telephone:'),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                                '${order.data.orderCustomer.customerTelephone}'),
                                                          ),
                                                          Expanded(

                                                              child: Center(
                                                                child: IconButton(
                                                                  onPressed: () => launch("tel:${order.data.orderCustomer.customerTelephone}"),
                                                                  icon: Icon(Icons.call),
                                                                ),
                                                              )
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
                                                          Get.width * 0.02),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Text('Address:'),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                                '${order.data.errand.sourceAddress}'),
                                                          )
                                                        ],
                                                      )),
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
                                                          Get.width * 0.02),
                                                      child: const Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: const Text(
                                                          'Errand Details',
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
                                                          Get.width * 0.02),
                                                      child: Row(
                                                        children: <Widget>[
                                                          const Expanded(
                                                            child: const Text('Source:'),
                                                          ),
                                                          Expanded(
                                                            child: Text('${order.data.errand.sourceAddress}'),
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
                                                          Get.width * 0.02),
                                                      child: Row(
                                                        children: <Widget>[
                                                          const Expanded(
                                                            child: const Text('Destination:'),
                                                          ),
                                                          Expanded(
                                                            child: Text('${order.data.errand.destinationAddress}'),
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
                                                          Get.width * 0.02),
                                                      child: Row(
                                                        children: <Widget>[
                                                          const Expanded(
                                                            child: const Text('Reciever:'),
                                                          ),
                                                          Expanded(
                                                            child: Text('${order.data.errand.destinationName}'),
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
                                                          Get.width * 0.02),
                                                      child: Row(
                                                        children: <Widget>[
                                                          const Expanded(
                                                            child: const Text('Reciever Contact:'),
                                                          ),
                                                          Expanded(
                                                            child: Text('${order.data.errand.destinationContact}',textAlign: TextAlign.center,),
                                                          ),
                                                          Expanded(
                                                              flex: 0,
                                                              child: Center(
                                                                child: IconButton(
                                                                  onPressed: () => launch("tel:${order.data.errand.destinationContact}"),
                                                                  icon: Icon(Icons.call),
                                                                ),
                                                              )
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
                                                          Get.width * 0.02),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Text('${order.data.errand.comment}'),
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
                                                          Get.width *
                                                              0.02),
                                                      child: Row(
                                                        children: <Widget>[
                                                          const Expanded(
                                                            child: const Text('Created At:'),
                                                          ),
                                                          Expanded(
                                                            child:
                                                            Text('${Utility.presentDate(DateTime.parse((order.data.orderCreatedAt as Timestamp).toDate().toString()))}'),
                                                          ),
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
                                                          Get.width *
                                                              0.02),
                                                      child: Row(
                                                        children: <Widget>[
                                                          const Expanded(
                                                            child: const Text('Fee:'),
                                                          ),
                                                          Expanded(
                                                            child:
                                                            Text('$CURRENCY${order.data.orderMode.fee}'),
                                                          ),
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
                                                          Get.width * 0.02),
                                                      child: Row(
                                                        children: <Widget>[
                                                          const Expanded(
                                                            child: const Text(
                                                              'Payment Method:',
                                                              style: const TextStyle(
                                                                  fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              '${order.data.receipt.type}',
                                                              style: const TextStyle(
                                                                  fontWeight: FontWeight.bold),
                                                            ),
                                                          )
                                                        ],
                                                      )),
                                                ])),



                                          ]
                                      )
                                  )
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            }


          },
        )


    );
  }

  bool confirm(Order _order, Merchant merchant, User agent,String oid, Confirmation confirmation,Receipt receipt) {
    bool isDone = true;
    int unit = (_order.orderMode.fee * 0.1).round();
    Geolocator().distanceBetween(merchant.bGeoPoint['geopoint'].latitude, merchant.bGeoPoint['geopoint'].longitude,
        _order.orderMode.coordinate.latitude, _order.orderMode.coordinate.longitude).then((value) {
      OrderRepo.confirm(_order, confirmation,receipt,agent.uid,
          _order.orderMode.fee,value.round(),unit>100?100:unit).catchError((onError) {
        isDone = false;
      });
    });
    if (isDone) {
      //refreshOrder();
      //confirmNotifier().then((value) => null);
      GetBar(
        title: 'Errand Confirmed',
        messageText: const Text(
          'Errand has been confirmed',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 10),
        backgroundColor: PRIMARYCOLOR,
      ).show();

    }
    return isDone;
  }

  bool cancel(String oid,Receipt receipt,String agent) {
    bool isDone = true;
    OrderRepo.cancel(oid,receipt,agent).catchError((onError) {
      isDone = false;
    });

    if (isDone) {
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
    }

    return isDone;
  }


/*Future<void> confirmNotifier({String fcm,}) async {
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
          'to': fcm,
        })).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
  }*/


}



class Loader extends StatefulWidget{
  Loader({this.message, this.total,this.start,this.order,this.id,this.customerToken});

  final String message;
  final int total;
  final int start;
  final String order;
  final String id;
  final String customerToken;

  @override
  State<StatefulWidget> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {


  final _current = ValueNotifier<int>(0);
  final _total = ValueNotifier<int>(0);
  final _message = ValueNotifier<String>('');
  Timer _timer;
  Stream<Map<String,Timestamp>> _trackerStream;
  @override
  void initState() {
    _current.value = widget.start;
    _total.value = widget.total;
    _message.value = widget.message=='Confirming Order'?widget.message:'min to delivery';
    startTimer();
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _total,
        builder: (_,int total,__){
          return ValueListenableBuilder(
              valueListenable: _current,
              builder: (_, int current, __) {
                return Column(children: [
                  current > 0 ? Column(
                    children: [
                      Container(
                        //width: Get.width * 0.3,
                        //height: Get.height * 0.18,
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
                                child: ValueListenableBuilder(
                                  valueListenable: _message,
                                  builder: (_,String message,__){
                                    return Text(
                                      message == 'Confirming Order'
                                          ? '$message'
                                          : '${(current / 60).round()} $message'
                                      ,
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                )
                            ),
                          )
                      ),
                    ],
                  ) :
                  Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Center(
                            child: Text('Order has not been delivered by your agent. Contact your agent to confirm what holding him/her.',
                              textAlign: TextAlign.center,style: TextStyle(fontSize: 16,color: Colors.red),),
                          )
                      )
                    ],
                  ),

                ]
                );
              }
          );
        }
    );

  }


  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_current.value < 1) {
          timer.cancel();}
        else {
          _current.value = _current.value - 1;
        }

      },
    );
  }
}