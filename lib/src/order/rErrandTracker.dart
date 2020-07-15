import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/repository/receipt.dart';
import 'package:pocketshopping/src/review/repository/ReviewRepo.dart';
import 'package:pocketshopping/src/review/repository/reviewObj.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';

import 'repository/order.dart';

class RiderErrandTracker extends StatefulWidget {
  RiderErrandTracker({this.order, this.user,this.isActive=false});

  final String order;
  final User user;
  final bool isActive;

  @override
  State<StatefulWidget> createState() => _RiderErrandTrackerState();
}

class _RiderErrandTrackerState extends State<RiderErrandTracker> {

  GlobalKey<ExpandableBottomSheetState> key = new GlobalKey();
  final scrollController = ScrollController();

  final FirebaseMessaging _fcm = FirebaseMessaging();
  final _review = TextEditingController();
  final rating = ValueNotifier<double>(1.0);
  final expanded = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  void expand() => key.currentState.expand();

  void contract() => key.currentState.contract();

  ExpansionStatus status() => key.currentState.expansionStatus;

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
                return  FutureBuilder(
                  future: UserRepo.getOneUsingUID(order.data.customerID),
                  builder: (context,AsyncSnapshot<User>customer){
                    return FutureBuilder(
                      future: ReviewRepo.getOne(order.data.orderCustomer.customerReview),
                      builder: (context, AsyncSnapshot<Review>review){
                        return order.data.status == 0? ExpandableBottomSheet(
                          key: key,
                          onIsContractedCallback: (){expanded.value=false;},
                          onIsExtendedCallback: (){expanded.value=true;},
                          background: Container(
                            color: Colors.grey.withOpacity(0.2),
                            child: Center(
                              child: Direction(source: LatLng(order.data.errand.source.latitude,order.data.errand.source.longitude),
                                destination: LatLng(order.data.errand.destination.latitude,order.data.errand.destination.longitude),
                                destAddress: order.data.errand.destinationAddress,
                                sourceAddress: order.data.errand.sourceAddress,
                                destName: 'Destination',
                                sourceName: 'Source',
                                destPhoto: PocketShoppingDefaultAvatar,
                                sourcePhoto: PocketShoppingDefaultAvatar,

                              ),
                           // Text('dsds')
                            ),
                          ),
                          persistentHeader: Container(
                            height: MediaQuery.of(context).size.height*0.2,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 0,
                                  child: Center(
                                    child: IconButton(
                                      onPressed: (){
                                        if(status() == ExpansionStatus.expanded)
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
                                      icon: ValueListenableBuilder(
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
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex:0,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 15),
                                          child: Row(
                                            children: [
                                              Text('Destination: ${order.data.errand.destinationAddress}'),
                                            ],
                                          )
                                        )
                                      ),
                                      Expanded(
                                        child:const SizedBox(height: 5,),
                                      ),
                                      Expanded(
                                        flex:0,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 15),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex:0,
                                                child: Text('Reciever: ${order.data.errand.destinationName}'),
                                              ),
                                              Expanded(
                                                  flex: 1,
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
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
                                    ],
                                  ),
                                ),
                                Divider(),
                              ],
                            )
                          ),
                          expandableContent: Container(
                            height: MediaQuery.of(context).size.height*0.6,
                            color: Colors.white,
                            child:  Listener(
                                onPointerUp: (_) {
                                  if (scrollController.offset <= scrollController.position.minScrollExtent &&
                                      !scrollController.position.outOfRange) {

                                    contract();
                                    expanded.value = false;
                                  }
                                },
                                onPointerDown: (_) {

                                },
                              child:

                              ListView(
                                controller: scrollController,
                              children: [
                                ErrandTracker(user: widget.user,order: order,)
                              ],
                            ),
                          ),
                          )
                        ):
                        ListView(
                          children: [
                            ErrandTracker(user: widget.user,order: order,)
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

class ErrandTracker extends StatelessWidget{
  final dynamic order;
  final User user;
  ErrandTracker({this.order,this.user});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
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
                ],
              )
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
                              null,
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
                    'Conclude Errand task',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
        ):Container(),

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
                      MediaQuery.of(context).size.width * 0.02),
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
                      MediaQuery.of(context).size.width * 0.02),
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
                      MediaQuery.of(context).size.width * 0.02),
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
                      MediaQuery.of(context).size.width * 0.02),
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
                      MediaQuery.of(context).size.width * 0.02),
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
                      MediaQuery.of(context).size.width * 0.02),
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
                      MediaQuery.of(context).size.width * 0.02),
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
                      MediaQuery.of(context).size.width * 0.02),
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
                      MediaQuery.of(context).size.width *
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
                      MediaQuery.of(context).size.width *
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
      ],
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
}

