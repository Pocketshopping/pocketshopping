import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/order/bloc/trackerBloc.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/currentPathLine.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/repository/receipt.dart';
import 'package:pocketshopping/src/order/tracker/delivery/counter.dart';
import 'package:pocketshopping/src/order/tracker/delivery/deliveryDirection.dart';
import 'package:pocketshopping/src/review/repository/ReviewRepo.dart';
import 'package:pocketshopping/src/review/repository/reviewObj.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/ui/shared/direction/bloc/errandDirectionBloc.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:url_launcher/url_launcher.dart';


class RiderDeliveryTracker extends StatefulWidget {
  RiderDeliveryTracker({this.order, this.user,this.isActive=false});

  final String order;
  final User user;
  final bool isActive;

  @override
  State<StatefulWidget> createState() => _RiderDeliveryTrackerState();
}

class _RiderDeliveryTrackerState extends State<RiderDeliveryTracker> {

  final scrollController = ScrollController();
  final slider = new PanelController();

  final FirebaseMessaging _fcm = FirebaseMessaging();
  final _review = TextEditingController();
  final rating = ValueNotifier<double>(1.0);
  final expanded = ValueNotifier<bool>(false);
  Stream<CurrentPathLine> _pathStream;
  final pathLine = ValueNotifier<CurrentPathLine>(null);

  @override
  void initState() {
    _pathStream = ErrandDirectionBloc.instance.currentPath;
    _pathStream.listen((result) {
      pathLine.value  = result;
    });
    super.initState();
  }

  void expand() => slider.open();

  void contract() => slider.close();

  bool status() => slider.isPanelOpen;

  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
          onWillPop: () async {
            return true;


          },child:
      Scaffold(
          appBar: !widget.isActive?AppBar(
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
          ):PreferredSize(preferredSize: Size.zero,child: const SizedBox.shrink(),),
          backgroundColor: Colors.white,
          body:widget.isActive?StreamBuilder<Order>(
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
                  future: MerchantRepo.getMerchant(order.data.orderMerchant),
                  builder: (context, AsyncSnapshot<Merchant>merchant){
                    return FutureBuilder(
                        future: UserRepo.getOneUsingUID(order.data.customerID),
                        builder: (context,AsyncSnapshot<User>customer){
                          return FutureBuilder(
                            future: ReviewRepo.getOne(order.data.orderCustomer.customerReview),
                            builder: (context, AsyncSnapshot<Review>review){
                              return SlidingUpPanel(
                          controller: slider,
                          onPanelClosed: (){expanded.value=false;},
                          onPanelOpened: (){expanded.value=true;},
                          body: Container(
                            color: Colors.grey.withOpacity(0.2),
                            child: Center(
                              child: merchant.data != null ? DeliveryDirection(

                                source: LatLng(
                                  merchant.data.bGeoPoint['geopoint'].latitude,
                                  merchant.data.bGeoPoint['geopoint'].longitude,),
                                destination: LatLng(
                                  order.data.orderMode.coordinate.latitude,
                                  order.data.orderMode.coordinate.longitude,
                                ),

                                destAddress: order.data.orderMode.address,
                                sourceAddress: merchant.data.bAddress,
                                destName: '${order.data.orderCustomer.customerName}',
                                sourceName: '${merchant.data.bName}',
                                user: widget.user,
                              ):
                              JumpingDotsProgressIndicator(
                                fontSize: Get.height * 0.12,
                                color: PRIMARYCOLOR,
                              )
                            ),
                          ),
                          panelBuilder: (ScrollController sc) => ListView(
                            controller: sc,
                            children: [
                              DeliveryTracker(
                                user: widget.user,
                                order: order,
                                merchant: merchant,
                                review: review,
                                customer: customer,

                              )
                            ],
                          ),
                          collapsed: Container(
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                      flex: 0,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: (){
                                            if(status())
                                            {
                                              contract();
                                              expanded.value = false;
                                            }
                                            else
                                            {
                                              expand();
                                              expanded.value = true;
                                            }
                                          },
                                          child: ValueListenableBuilder(
                                            valueListenable: expanded,
                                            builder: (_,bool isExpanded,__){
                                              return !isExpanded?
                                              Icon(Icons.keyboard_arrow_up):
                                              Icon(Icons.keyboard_arrow_down);
                                            },
                                          ),
                                        ),
                                      )
                                  ),
                                  Expanded(
                                      child: ValueListenableBuilder(
                                        valueListenable: pathLine,
                                        builder: (_,CurrentPathLine path,__){
                                          return path != null ?Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              if(path.hasVisitedSource)
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children:[
                                                    Expanded(
                                                      flex:2,
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                                        child: Text('${order.data.orderCustomer.customerName}: (Address: ${order.data.orderMode.address})', textAlign: TextAlign.center,),
                                                      )
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Align(
                                                        child: path.hasVisitedDestination?
                                                        IconButton(
                                                          onPressed: () => launch("tel:${order.data.orderCustomer.customerTelephone}"),
                                                          icon: Icon(Icons.call,size: 40,),
                                                        ):

                                                        Counter(
                                                          id: order.data.receipt.collectionID,
                                                          total: order.data.orderETA,
                                                          start: Utility.setStartCount(order.data.orderCreatedAt, order.data.orderETA),
                                                        ),
                                                        alignment: Alignment.topCenter,
                                                      ),
                                                    )
                                                  ]
                                                ),
                                              if(!path.hasVisitedSource && merchant.data != null)
                                                Row(
                                                  children:[
                                                    Expanded(
                                                      flex:2,
                                                      child: Padding(
                                                        child: Text('${merchant.data.bName}: (Address: ${merchant.data.bAddress})', textAlign: TextAlign.center,),
                                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                                      )
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: path.hasVisitedDestination?
                                                      IconButton(
                                                        onPressed: () => launch("tel:${order.data.orderCustomer.customerTelephone}"),
                                                        icon: Icon(Icons.call,size: 40,),
                                                      ):

                                                      Counter(
                                                        id: order.data.receipt.collectionID,
                                                        total: order.data.orderETA,
                                                        start: Utility.setStartCount(order.data.orderCreatedAt, order.data.orderETA),
                                                      )
                                                      ,
                                                    )
                                                  ]
                                                ),
                                            ],
                                          ):
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex:2,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                                    child: Text('${order.data.orderCustomer.customerName}: (Address: ${order.data.orderMode.address})', textAlign: TextAlign.center,),
                                                  )
                                                )
                                              ),
                                              if(path != null)
                                              Expanded(
                                                flex: 1,
                                                child: path.hasVisitedDestination?
                                                IconButton(
                                                  onPressed: () => launch("tel:${order.data.orderCustomer.customerTelephone}"),
                                                  icon: Icon(Icons.call,size: 40,),
                                                ):

                                                Counter(
                                                  id: order.data.receipt.collectionID,
                                                  total: order.data.orderETA,
                                                  start: Utility.setStartCount(order.data.orderCreatedAt, order.data.orderETA),
                                                )
                                                ,
                                              )
                                            ],
                                          );
                                        },
                                      )
                                  ),
                                ],
                              )
                          ),
                        );
                      },
                    );
                    }
                  );
                  },
                );
              }


            },
          )
              :
          FutureBuilder<Order>(
            future: OrderRepo.getOne(widget.order),
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
                  future: MerchantRepo.getMerchant(order.data.orderMerchant),
                  builder: (context, AsyncSnapshot<Merchant>merchant){
                    return FutureBuilder(
                        future: UserRepo.getOneUsingUID(order.data.customerID),
                        builder: (context,AsyncSnapshot<User>customer){
                          return FutureBuilder(
                            future: ReviewRepo.getOne(order.data.orderCustomer.customerReview),
                            builder: (context, AsyncSnapshot<Review>review){
                              return ListView(
                                children: [
                                  DeliveryTracker(
                                    user: widget.user,
                                    order: order,
                                    merchant: merchant,
                                    review: review,
                                    customer: customer,

                                  )
                                ],
                              );
                            },
                          );
                        }
                    );
                  },
                );
              }


            },
          )

      )
      );
  }
}

class DeliveryTracker extends StatelessWidget{
  final dynamic order;
  final User user;
  final dynamic merchant;
  final dynamic customer;
  final dynamic review;
  DeliveryTracker({this.order,this.user,this.merchant,this.customer,this.review});
  final _formKey = GlobalKey<FormState>();
  final _review = TextEditingController();
  final rating = ValueNotifier<double>(1.0);
  final _formKey3 = GlobalKey<FormState>();
  final reason = ValueNotifier<String>('Select');

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
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
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                            user,
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



                      if(order.data.status == 0)
                        Center(
                          child:
                          Loader(
                            id: order.data.receipt.collectionID,
                            total: order.data.orderETA,
                            start: Utility.setStartCount(order.data.orderCreatedAt, order.data.orderETA),
                            message: order.data.isAssigned ?
                            '${(Utility.setStartCount(order.data.orderCreatedAt, order.data.orderETA) / 60).round()} min to ${order.data.orderMode.mode}':
                            'Confirming Order',
                            order: order.data.docID,

                            customerToken: order.data.customerDevice,
                          ),
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
                                      child: const Text('Review'),
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


                      /*if(order.data.orderCustomer.customerReview.isEmpty && order.data.status == 1 && order.data.receipt.psStatus != 'fail')
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
                                        'Rate ${customer.data != null ? customer.data.fname : ''}',
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
                                          String rid = await ReviewRepo.save(Review(text: _review.text, rating: rating.value, reviewed: customer.data.uid,
                                              reviewedAt: Timestamp.now(), reviewerId: user.uid, reviewerName: user.fname),
                                              rating: Rating(
                                                  id: customer.data.uid,
                                                  rating: rating.value,
                                                  positive: 0,
                                                  neutral: 0,
                                                  negative: 0
                                              )
                                          );
                                          Get.back();

                                          if(rid.isNotEmpty){
                                            Utility.bottomProgressSuccess(title:"Submitting review",body: "Review Submitted successfully. Thank you" );
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
*/
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
                              if(order.data.orderCustomer.customerTelephone.toString().isNotEmpty)
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
                                       child: IconButton(
                                         onPressed: () => launch("tel:${order.data.orderCustomer.customerTelephone}"),
                                         icon: Icon(Icons.call),
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
                                            '${order.data.orderMode.address}'),
                                      )
                                    ],
                                  )),
                            ],
                          ),
                        ),


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
                                      Get.width * 0.02),
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
                                      Get.width * 0.02),
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
                                        Get.width * 0.02),
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
                                      Get.width * 0.02),
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
                                      Get.width * 0.02),
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
                                      Get.width * 0.02),
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
                                      Get.width * 0.02),
                                  child: Row(
                                    children: <Widget>[
                                      const Expanded(
                                        child: const Text('OrderId:'),
                                      ),
                                      Expanded(
                                        child: Text('${order.data.receipt.collectionID}'),
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
                                    Get.width * 0.02),
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
                                      child:  Center(child: Text('Item Price( $CURRENCY ) '),
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
                                    Get.width * 0.02),
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
                                    Get.width *
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
                                    Get.width * 0.02),
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

                      if(order.data.status == 0   && order.data.orderMode.mode=='Delivery')
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
                                              ValueListenableBuilder(
                                                valueListenable: reason,
                                                builder: (_,String reason_,__){
                                                  return DropdownButtonFormField<String>(
                                                    value: reason_,
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
                                                        reason.value = value;
                                                    },
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    validator: (value) {
                                                      if (value == 'Select') {
                                                        return 'Select reason';
                                                      }
                                                      return null;
                                                    },
                                                  );
                                                },
                                              )
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
                                            var result = cancel(order.data.docID,
                                                Receipt.fromMap(order.data.receipt.copyWith(psStatus: "fail",
                                                    pRef: '"${reason.value}" order was cancelled by ${user.fname}(Agent)').toMap()),
                                                user.uid
                                            );
                                            if(result)
                                              await Utility.pushNotifier(fcm: customer.data.notificationID,
                                                  title: 'Order Cancelled',
                                                  body: 'Your order has been cancelled by the agent (reason: ${reason.value}}). ${order.data.receipt.type != 'CASH'?'Please Note. your money has been refunded to your wallet':''}',
                                                  notificationType: 'OrderCancelledResponse'
                                              );

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
  }

  bool confirm(Order _order, Merchant merchant, User agent,String oid, Confirmation confirmation,Receipt receipt) {
    bool isDone = true;
    int unit = (_order.orderMode.fee * 0.1).round();
   double distance =distanceBetween(merchant.bGeoPoint['geopoint'].latitude, merchant.bGeoPoint['geopoint'].longitude,
        _order.orderMode.coordinate.latitude, _order.orderMode.coordinate.longitude)??0;
    OrderRepo.confirm(_order, confirmation,receipt,agent.uid,
        _order.orderMode.fee,distance.round(),unit>100?100:unit).catchError((onError) {
      isDone = false;
    });
    if (isDone) {
      //refreshOrder();
      //confirmNotifier().then((value) => null);
      GetBar(
        title: 'Order Confirmed',
        messageText: const Text(
          'Take your time to rate this user your rating will help us '
              ' improve our service',
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
  final _trackerData = ValueNotifier<Map<String,Timestamp>>({});
  final _formKey = GlobalKey<FormState>();
  final _delay = TextEditingController();
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
        if(dateTime.containsKey('r${widget.id}')){
          _current.value = Utility.setStartCount(dateTime['r${widget.id}'], 120);
          _total.value = 120;
          _message.value='waiting';
          startTimer();
        }

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
                      psHeadlessCard(
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
                                      onPressed: () async{
                                        if(_formKey.currentState.validate()) {
                                          if(_trackerData.value.containsKey('r${widget.id}')){
                                            _trackerData.value.remove('r${widget.id}');
                                            _trackerData.value['r${widget.id}']=Timestamp.now();
                                            TrackerBloc.instance.newDateTime(_trackerData.value);
                                          }
                                          else{
                                            if(_trackerData.value.isEmpty)
                                              TrackerBloc.instance.newDateTime({'r${widget.id}':Timestamp.now()});
                                            else{
                                              _trackerData.value['r${widget.id}']=Timestamp.now();
                                              TrackerBloc.instance.newDateTime(_trackerData.value);
                                            }
                                          }
                                          startTimer();
                                          print(widget.customerToken);
                                          await Utility.pushNotifier(fcm: widget.customerToken,
                                              title: 'Delivery',
                                              body: _delay.text);
                                          await OrderRepo.resolution(widget.order, _delay.text.trim());


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

                            ],
                          )
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