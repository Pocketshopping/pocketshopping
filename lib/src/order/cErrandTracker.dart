import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/customerCare/repository/customerCareObj.dart';
import 'package:pocketshopping/src/customerCare/repository/customerCareRepo.dart';
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
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'repository/order.dart';

class CustomerErrandTracker extends StatefulWidget {
  CustomerErrandTracker({this.order, this.user,this.isNew=false});

  final String order;
  final User user;
  final bool isNew;

  @override
  State<StatefulWidget> createState() => _CustomerErrandTrackerState();
}

class _CustomerErrandTrackerState extends State<CustomerErrandTracker> {

  final FirebaseMessaging _fcm = FirebaseMessaging();
  final _review = TextEditingController();
  final rating = ValueNotifier<double>(1.0);


  @override
  void initState() {

    SchedulerBinding.instance.addPostFrameCallback((_) async{
      if(widget.isNew)
        Utility.bottomProgressSuccess(body: 'Request has been sent to Rider',title: 'Request Sent');
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
        onWillPop: () async {
          if(widget.isNew)
          {
            int count = 0;
            Navigator.popUntil(context, (route) {
              return count++ == 2;
            });
          }
          else
            Get.back();
        return false;


        },child:
    Scaffold(
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
              if(widget.isNew)
              {
                int count = 0;
                Navigator.popUntil(context, (route) {
                  return count++ == 2;
                });
              }
              else
                Get.back(result: 'Refresh');

            },
          ),
          title: const Text(
            'Errand Tracker',
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
              return  FutureBuilder(
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
                                                child: Row(
                                                  children: [
                                                    if(order.data.isAssigned)
                                                    Expanded(
                                                      flex:1,
                                                      child: Text('${order.data.status != 0 ? order.data.receipt.psStatus=='success'?'Completed':'Cancelled' : 'Processing'}',
                                                        style: TextStyle(fontSize: 20),
                                                      ),
                                                    ),
                                                    if(order.data.status == 0 && !order.data.isAssigned )
                                                      Expanded(
                                                        flex:0,
                                                        child:  IconButton(
                                                          onPressed: (){Get.back();},
                                                          icon: Icon(Icons.arrow_back_ios),
                                                        ),
                                                      ),
                                                    if(order.data.status == 0 && !order.data.isAssigned )
                                                    Expanded(
                                                      child:  Text('Task not yet accepted.',
                                                        style: TextStyle(fontSize: 20),
                                                      ),
                                                    )
                                                  ],
                                                )
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
                                                            'Confirming this errand implies your package has been delivered to the destination.'
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
                                                                null,//merchant.data,
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
                                                        'Confirm Errand Completion',
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            ):Container(),



                                            if(order.data.status == 0 && agent.hasData)
                                              Center(
                                                child:
                                                Loader(
                                                  rider: agent.data,
                                                ),
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
                                                  child: Column(
                                                    children: [
                                                      Center(
                                                        child: Padding(padding: EdgeInsets.symmetric(vertical: 10),child: Text('Waiting For Rider to accept'),),
                                                      ),
                                                      Container(
                                                        child: JumpingDotsProgressIndicator(
                                                          fontSize: Get.height * 0.08,
                                                          color: PRIMARYCOLOR,
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                                                          child: Text('Ensure the rider accepts the task before handing over the package to him/her.'
                                                              ' Without rider accepting the task pocketshopping will not be able to track the errand and in '
                                                              'such case would not be held responsible in any situation.',textAlign: TextAlign.center,),),
                                                      ),
                                                    ],
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
                                                            itemSize: Get.width * 0.08,
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
                                            FutureBuilder(
                                              future: MerchantRepo.getMerchant(order.data.orderLogistic),
                                                builder:(_,AsyncSnapshot<Merchant>merchant){
                                                if(merchant.hasData){
                                                  if(merchant.data != null){
                                                    return
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
                                                                      'Rate the expirience',
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
                                                                          itemSize: Get.width * 0.1,
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
                                                                    width: Get.width,
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
                                                      );
                                                  }
                                                  else{
                                                    return const SizedBox.shrink();
                                                  }
                                                }
                                                else{
                                                  return const SizedBox.shrink();
                                                }
                                                }),

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
                                                    if(order.data.status == 0)
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
                                                              child: const Text('Share the confirmation code with the reciever. The rider will require the code for confimation at the destination. ',textAlign: TextAlign.center,),
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
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: <Widget>[
                                                            const Expanded(
                                                              child:const Text('Completed:'),
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
                                                            Get.width *
                                                                0.02),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: <Widget>[
                                                            const Expanded(
                                                              flex: 0,
                                                              child: const Text('Confirmation code:'),
                                                            ),
                                                            Expanded(
                                                              child: Center(child: Text(order.data.orderConfirmation.confirmOTP),),
                                                            ),
                                                            if(order.data.status == 0)
                                                            Expanded(
                                                                flex: 0,
                                                                child: Padding(
                                                                  padding: EdgeInsets.only(right: 20),
                                                                  child: IconButton(
                                                                    onPressed: () {
                                                                      Share.share('${order.data.orderConfirmation.confirmOTP}');
                                                                    },
                                                                    icon: Icon(Icons.share),
                                                                  ),
                                                                ))
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
                                                              child: const Text('Completed:'),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                  '${order.data.orderConfirmation.confirmedAt == null || order.data.orderConfirmation.confirmedAt=="" ? '-' :Utility.presentDate(DateTime.parse(((order.data.orderConfirmation.confirmedAt as Timestamp).toDate()).toString()))}'),
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
                                                                    Get.width * 0.02),
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
                                                                          Get.width * 0.02),
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
            }


          },
        )

    )
    );
  }

  bool confirm(Order _order, Merchant merchant, User agent,String oid, Confirmation confirmation,Receipt receipt) {
    bool isDone = true;
    int unit = (_order.orderMode.fee * 0.1).round();

    double distance = distanceBetween(_order.errand.source.latitude, _order.errand.source.longitude,
        _order.errand.destination.latitude, _order.errand.destination.longitude)??0;
    OrderRepo.confirm(_order, confirmation,receipt,agent.uid,
        _order.orderMode.fee,distance.round(),unit>100?100:unit).catchError((onError) {
      isDone = false;
    });


    if (isDone) {
      //refreshOrder();
      //confirmNotifier().then((value) => null);
      GetBar(
        title: 'Errand Completed',
        messageText: const Text(
          'Errand has been successfully completed ',
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
          'The request has been cancelled. '
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



class Loader extends StatelessWidget{
  Loader({this.rider});
  final User rider;



  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if(rider != null)
      CircleAvatar(
        radius: Get.width*0.25,
        backgroundColor: Colors.grey.withOpacity(0.2),
        backgroundImage: NetworkImage(rider.profile.isNotEmpty?rider.profile:PocketShoppingDefaultAvatar),
      ),
      if(rider != null)
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
                          '${rider.fname}',
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
                                  '${rider.telephone}',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              )

                            ),
                            Expanded(
                              flex: 0,
                              child: Center(
                                child: IconButton(
                                  onPressed: () => launch("tel:${rider.telephone}"),
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
      const SizedBox.shrink()
    ]
    );

  }

}