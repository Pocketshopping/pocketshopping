import 'dart:async';

import 'package:ant_icons/ant_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/customerCare/repository/customerCareObj.dart';
import 'package:pocketshopping/src/customerCare/repository/customerCareRepo.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
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

class TrackerWidget extends StatefulWidget {
  TrackerWidget({this.order, this.user});

  final String order;
  final User user;

  @override
  State<StatefulWidget> createState() => _TrackerWidgetState();
}

class _TrackerWidgetState extends State<TrackerWidget> {

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
                  fontSize: MediaQuery.of(context).size.height * 0.12,
                  color: PRIMARYCOLOR,
                ),
              );
            }
            else if(order.hasError){
                return Center(
                  child: Text('Error communicating to server check '
                      'your internet connection and try again',textAlign: TextAlign.center,),
                );
              }
              else{
                return FutureBuilder(
                  future: MerchantRepo.getMerchant(order.data.orderMerchant),
                  builder: (context, AsyncSnapshot<Merchant>merchant){
                    return FutureBuilder(
                      future: UserRepo.getOneUsingUID(order.data.agent),
                      builder: (context,AsyncSnapshot<User>agent){
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

                                              Center(
                                                child:
                                              Loader(
                                                total: order.data.orderETA,
                                                start: Utility.setStartCount(order.data.orderCreatedAt, order.data.orderETA),
                                                message: '${(Utility.setStartCount(order.data.orderCreatedAt, order.data.orderETA) / 60).round()} min to ${order.data.orderMode.mode}',
                                              ),),

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


                                              if(!order.data.isAssigned)
                                                psHeadlessCard(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey,
                                                        //offset: Offset(1.0, 0), //(x,y)
                                                        blurRadius: 6.0,
                                                      ),
                                                    ],
                                                    child: Container(
                                                      color:  PRIMARYCOLOR,
                                                      child: FlatButton.icon(
                                                        onPressed: () {},
                                                        icon: const Icon(AntIcons.clock_circle_outline,color: Colors.white,),
                                                        label: const Center(
                                                          child: const Text(
                                                            'Confirming Order. Please wait',
                                                            style: const TextStyle(color: Colors.white),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                ),

                                              (!order.data.orderConfirmation.isConfirmed && order.data.status == 0 && order.data.isAssigned) ||
                                                  (order.data.orderMode.mode == 'Pickup' && !order.data.orderConfirmation.isConfirmed && order.data.status == 0)
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
                                                                  order.data,
                                                                  merchant.data,
                                                                  agent.data,
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
                                                                child: Text(order.data
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
                                                                child: Text(order.data
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
                                                                    '${order.data.orderConfirmation.confirmedAt == null || order.data.orderConfirmation.confirmedAt=="" ? '-' :Utility.presentDate(DateTime.parse(((order.data.orderConfirmation.confirmedAt as Timestamp).toDate()).toString()))}'),
                                                              )
                                                            ],
                                                          )),
                                                    ],
                                                  )),
                                              if(merchant.hasData)
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
                                                                  '${merchant != null ? merchant.data.bName : ''}'),
                                                            )
                                                          ],
                                                        )),
                                                    if(order.data.orderMode.mode != 'Delivery' && !merchant.data.adminUploaded )
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
                                                                    '${merchant != null ? merchant.data.bTelephone : ''}'),
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
                                                                  '${merchant != null ? merchant.data.bCategory : ''}'),
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
                                                              child: Text('${order.data.orderMode.mode}'),
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
                                                                  '${Utility.presentDate(DateTime.parse((order.data.orderCreatedAt as Timestamp).toDate().toString()))}'),
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
                                                              child: Text('${order.data.receipt.collectionID}'),
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
                                                            order.data.orderItem.length,
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
                                                                            '${order.data.orderItem[index].ProductName}'),
                                                                        )),
                                                                    Expanded(
                                                                        child: Center(child:Text(
                                                                            '${order.data.orderItem[index].count}'),
                                                                        )),
                                                                    Expanded(
                                                                        child: Center(child:Text(
                                                                            '$CURRENCY${order.data.orderItem[index].totalAmount}'),
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
                                                              child: Text('$CURRENCY${order.data.orderAmount}'),
                                                            )
                                                          ],
                                                        )),
                                                    order.data.orderMode.mode == 'Delivery'
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
                                                              Text('$CURRENCY${order.data.orderMode.fee}'),
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
                                                                '$CURRENCY${order.data.orderMode.mode != 'Delivery' ? order.data.orderAmount : (order.data.orderAmount + order.data.orderMode.fee)}',
                                                                style: const TextStyle(
                                                                    fontWeight: FontWeight.bold),
                                                              ),
                                                            )
                                                          ],
                                                        )),
                                                  ])),

                                              FutureBuilder<List<CustomerCareLine>>(
                                                future: CustomerCareRepo.fetchCustomerCareLine((order.data.orderMode.mode=='Delivery'?order.data.orderLogistic:order.data.orderMerchant)),
                                                initialData: null,
                                                builder: (_, AsyncSnapshot<List<CustomerCareLine>> customerCare){
                                                  if(customerCare.hasData){
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
                                                                      'Customer care line',
                                                                      style: const TextStyle(color: Colors.white),
                                                                    ),
                                                                  )
                                                              ),
                                                              Column(
                                                                  children:List<Widget>.generate(customerCare.data.length, (index) {
                                                                    return Container(
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
                                                                            child: Row(
                                                                              children: [
                                                                                Expanded(
                                                                                  child: Text('${customerCare.data[index].name}'),
                                                                                ),
                                                                                Expanded(
                                                                                    child: Text('${customerCare.data[index].number}')
                                                                                )
                                                                              ],
                                                                            )
                                                                        )
                                                                    );
                                                                  }).toList()
                                                              )

                                                            ]
                                                        )
                                                    );
                                                  }
                                                  else{return const SizedBox.shrink();}
                                                },
                                              ),

                                              Center(
                                                child: SizedBox(
                                                  height: 300,
                                                  width: 300,
                                                  child: psHeadlessCard(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey,
                                                          //offset: Offset(1.0, 0), //(x,y)
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                      child:  QrImage(
                                                        data: order.data.docID,
                                                      ))
                                                ),
                                              )



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
      OrderRepo.confirm(oid, confirmation,receipt,agent.uid,
          _order.orderMode.fee,value.round(),unit>100?100:unit).catchError((onError) {
        isDone = false;
      });
    });
    if (isDone) {
      //refreshOrder();
      //confirmNotifier().then((value) => null);
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



class Loader extends StatefulWidget{
  Loader({this.message, this.total,this.start});

  final String message;
  final int total;
  final int start;

  @override
  State<StatefulWidget> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {


  final _current = ValueNotifier<int>(0);
  Timer _timer;
  @override
  void initState() {
    _current.value = widget.start;
    startTimer();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return widget.start>0?ValueListenableBuilder(
        valueListenable: _current,
        builder: (_,int current,__){
          return Container(
            //width: MediaQuery.of(context).size.width * 0.3,
            //height: MediaQuery.of(context).size.height * 0.18,
              color: Colors.white,
              child: CircularStepProgressIndicator(
                totalSteps: widget.total,
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
                    '${(current/60).round()} min to delivery ',
                    textAlign: TextAlign.center,
                  ),
                ),
              ));
        }):const SizedBox.shrink();

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