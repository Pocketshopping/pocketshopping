import 'dart:async';

import 'package:ant_icons/ant_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/customerCare/repository/customerCareObj.dart';
import 'package:pocketshopping/src/customerCare/repository/customerCareRepo.dart';
import 'package:pocketshopping/src/order/bloc/trackerBloc.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/customer.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/repository/receipt.dart';
import 'package:pocketshopping/src/review/repository/ReviewRepo.dart';
import 'package:pocketshopping/src/review/repository/rating.dart';
import 'package:pocketshopping/src/review/repository/reviewObj.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'repository/order.dart';

class CustomerTracker extends StatefulWidget {
  CustomerTracker({this.order, this.user});

  final String order;
  final User user;

  @override
  State<StatefulWidget> createState() => _CustomerTrackerState();
}

class _CustomerTrackerState extends State<CustomerTracker> {

  final FirebaseMessaging _fcm = FirebaseMessaging();
  final _review = TextEditingController();
  final rating = ValueNotifier<double>(1.0);

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
                  child: Text('Error communicating with server check '
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
                                                      child: Center(
                                                        child: Text(
                                                          'Confirm Order',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                              ):Container(),

                                              if(order.data.status == 0)
                                              Center(
                                                child:
                                              Loader(
                                                total: order.data.orderETA,
                                                start: Utility.setStartCount(order.data.orderCreatedAt, order.data.orderETA),
                                                message: order.data.isAssigned ?
                                                '${(Utility.setStartCount(order.data.orderCreatedAt, order.data.orderETA) / 60).round()} min to ${order.data.orderMode.mode}':
                                                'Confirming Order',
                                                rider: agent.data,
                                                id: order.data.receipt.collectionID,
                                              ),
                                              ),
                                              if(order.data.resolution.isNotEmpty && order.data.status == 0)
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
                                                                'Rider Says:',
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
                                                                '${order.data.resolution}',
                                                                style: const TextStyle(
                                                                    color: Colors.black, fontSize: 18),
                                                              ),
                                                            )
                                                        ),
                                                      ]
                                                  )
                                              ),

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

                                              if(review.data != null)
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
                                                              child: const Text('Your Review'),
                                                            ),
                                                            RatingBar(
                                                              onRatingUpdate: (rate){},
                                                              initialRating: review.data.rating,
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
                                                                  child: Text(review.data.text)),
                                                            ),
                                                            Align(
                                                              alignment: Alignment.centerRight,
                                                              child: Padding(
                                                                padding: EdgeInsets.symmetric(
                                                                    vertical: 10, horizontal: 10),
                                                                child: Text(
                                                                    '${Utility.presentDate(DateTime.parse((review.data.reviewedAt).toDate().toString()))}'),
                                                              ),
                                                            ),
                                                          ],
                                                        )

                                                    )
                                                ),


                                              if(order.data.orderCustomer.customerReview.isEmpty && order.data.status == 1 && order.data.receipt.psStatus != 'fail')
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
                                                                'Rate ${merchant.data != null ? merchant.data.bName : ''}',
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
                                                            ValueListenableBuilder(
                                                            valueListenable: rating,
                                                            builder: (_,double rate,__){
                                                              return RatingBar(
                                                                onRatingUpdate: (rate) {
                                                                rating.value = rate;
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
                                                              );
                                                            }
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
                                                                onPressed: () async{
                                                                  Utility.bottomProgressLoader(title: "Submitting review",body: "Submitting review to server");
                                                                  String rid = await ReviewRepo.save(Review(text: _review.text, rating: rating.value, reviewed: merchant.data.mID,
                                                                      reviewedAt: Timestamp.now(), reviewerId: order.data.customerID, reviewerName: order.data.orderCustomer.customerName),
                                                                  rating: Rating(
                                                                    id: merchant.data.mID,
                                                                    rating: rating.value,
                                                                    positive: 0,
                                                                    neutral: 0,
                                                                    negative: 0
                                                                  )
                                                                  );
                                                                  Get.back();

                                                                  if(rid.isNotEmpty){
                                                                    var result = await OrderRepo
                                                                        .review(
                                                                        order.data.docID,
                                                                        Customer(
                                                                          customerName:
                                                                          order.data.orderCustomer.customerName,
                                                                          customerTelephone: order.data
                                                                              .orderCustomer.customerTelephone,
                                                                          customerReview: rid,
                                                                        ));
                                                                    if(result)
                                                                    Utility.bottomProgressSuccess(title:"Submitting review",body: "Review Submitted successfully. Thank you" );
                                                                    else
                                                                      Utility.bottomProgressFailure(title:"Submitting review",body: "Error Encountered." );
                                                                  }
                                                                  else{
                                                                    Utility.bottomProgressFailure(title:"Submitting review",body: "Error Encountered." );
                                                                  }

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
                                                           Expanded(
                                                              child:  Center(child: Text(
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
      OrderRepo.confirm(_order, confirmation,receipt,agent.uid,
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
  Loader({this.message, this.total,this.start,this.rider,this.id});

  final String message;
  final int total;
  final int start;
  final User rider;
  final String id;

  @override
  State<StatefulWidget> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {


  final _current = ValueNotifier<int>(0);
  final _total = ValueNotifier<int>(0);
  final _message = ValueNotifier<String>('');
  final _resolution = ValueNotifier<bool>(false);
  final _trackerData = ValueNotifier<Map<String,Timestamp>>({});
  Timer _timer;
  Stream<Map<String,Timestamp>> _trackerStream;
  @override
  void initState() {
    _current.value = widget.start;
    _total.value = widget.total;
    _message.value = widget.message=='Confirming Order'?widget.message:'min to delivery';
    startTimer();

    _trackerStream = TrackerBloc.instance.trackerStream;
    _trackerStream.listen((dateTime) {

      if(_current.value == 0){
        _trackerData.value = dateTime;
        _current.value = Utility.setStartCount(dateTime[widget.id], 600);
        _total.value = 600;
        _message.value='min more';
        _resolution.value = true;
        startTimer();
      }

    });
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
              ValueListenableBuilder(
                valueListenable: _resolution,
                builder: (_,bool resolve,__){
                  return resolve?Column(children: [

                  Center(
                    child: Text('Tracing Delivery Issue. please wait'),
                  ),
                    const SizedBox(height: 20,),
                    ]
                  )
                      :const SizedBox.shrink();
                },
              ),
            ],
          ) :
          Column(
            children: [
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
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly,
                            children: [
                              FlatButton(
                                onPressed: () async{
                                  if(_trackerData.value.containsKey(widget.id)){
                                    _trackerData.value.remove(widget.id);
                                    _trackerData.value[widget.id]=Timestamp.now();
                                    TrackerBloc.instance.newDateTime(_trackerData.value);
                                  }
                                  else{
                                    if(_trackerData.value.isEmpty)
                                      TrackerBloc.instance.newDateTime({widget.id:Timestamp.now()});
                                    else{
                                      _trackerData.value[widget.id]=Timestamp.now();
                                      TrackerBloc.instance.newDateTime(_trackerData.value);
                                    }

                                  }

                                  await Utility.pushNotifier(fcm: widget.rider.notificationID,
                                    title: "Delivery",
                                    body: "Hello, What is holding you back I have not recieved my package and it already time.",
                                    notificationType: 'DeliveryConflictResolutionNotifier',
                                  );
                                },
                                child:
                                const Text('No', style: const TextStyle(
                                    color: Colors.white)),
                                color: PRIMARYCOLOR,
                              ),
                            ],
                          )
                        ],
                      )
                  )
              ),
            ],
          ),
            if(widget.rider != null)
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
                              'Rider',
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
                              '${widget.rider.fname}',
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
                            child: Text(
                              '${widget.rider.telephone}',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                          )
                      ),
                    ]
                )
            )
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