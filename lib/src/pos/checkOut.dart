import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/admin/package_admin.dart' as admin;
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/admin/product/editProduct.dart';
import 'package:pocketshopping/src/logistic/agent/newAgent.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/agentCompany/agentTracker.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/order/repository/cartObj.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/customer.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderItem.dart';
import 'package:pocketshopping/src/order/repository/orderMode.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/repository/receipt.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/agent/myAuto.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string/random_string.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';

class PosCheckOut extends StatefulWidget {

  final dynamic payload;
  final Function cartOps;
  final bool isRestaurant;
  final Session session;


  PosCheckOut({this.payload,this.cartOps,this.isRestaurant=false,this.session});

  @override
  _PosCheckOutState createState() => new _PosCheckOutState();
}

class _PosCheckOutState extends State<PosCheckOut> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  int stage;
  Timer _timer;
  int _start;
  bool transactionExpires;
  String paymentId;
  Stream<LocalNotification> _notificationsStream;
  Order order;
  String errorMessage;


  @override
  void initState() {
    errorMessage='Error completing transaction';
    paymentId = randomAlphaNumeric(8);
    stage = 0;
    transactionExpires = false;
    order = Order(orderMerchant: widget.session.merchant.mID);
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification)async {
      if (notification != null) {
        if (mounted && notification.data['data']['payload'].toString().isNotEmpty) {
          var payload = jsonDecode(notification.data['data']['payload']);
          switch (payload['NotificationType']) {
            case 'paymentInitiatedResponse':
              if(payload['paymentId'] == paymentId){
                setState(() { transactionExpires=true; stage=3;_start=0;});
                print(payload['customerWallet']);
                if(payload['customerWallet'] != null) {
                  Wallet wallet = await WalletRepo.getWallet(
                      payload['customerWallet']);
                  if (wallet.walletBalance < order.orderAmount) {
                    ack(device: payload['fcm'],isSuccessful: false);
                    setState(() {
                      stage = 6;
                      errorMessage =
                      "Customer's fund is insufficient for this transaction.";
                    });
                  }
                  else {
                    ack(device: payload['fcm']);
                    Position position = await Geolocator().getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.best);
                    String currentAddress = await Utility.address(position);
                    String collectionId = await Utility.initializePosPay(
                      from: payload['customerWallet'],
                      to: widget.session.user.walletId,
                      amount: order.orderAmount.round(),
                      agent: widget.session.user.walletId,
                      channelId: 3
                    );
                    if (collectionId != null) {
                      var result = await Utility.finalizePosPay(
                          collectionID: collectionId, isSuccessful: true);
                      if (result != null) {
                        order = order.update(
                            orderMode: OrderMode(
                              fee: 0,
                              tableNumber: '0',
                              mode: 'inHouse',
                              deliveryMan: '',
                              address: currentAddress,
                              acceptedBy: widget.session.user.uid,
                              coordinate: null,
                            ),
                            receipt: Receipt(
                                collectionID: collectionId,
                                psStatus: 'success',
                                pRef: '',
                                type: 'CASH'
                            ),
                            orderCustomer: Customer(
                              customerName: payload['name'],
                              customerReview: '',
                              customerTelephone: '',
                            ),
                            customerID: payload['customer']
                        );
                        setState(() {});
                      }
                    }
                    bool result = await finaliseOrder();
                    setState(() {
                      if (result) {
                        stage = 5;
                        ack(device: payload['fcm'],isSuccessful: false,type: 'RefreshPocketResponse');
                      }
                      else {
                        stage = 6;
                        errorMessage =
                        'Error connecting to server. check you network connection';
                      }
                    });
                  }
                }
                else{
                  setState(() {
                      stage = 6;
                      errorMessage = 'Error decoding customer detail.';

                  });
                  ack(device: payload['fcm'],isSuccessful: false);
                }
                NotificationsBloc.instance.clearNotification();
              }
              break;

            default:
              NotificationsBloc.instance.clearNotification();
              break;
        }



              }
            }
          }
        );


    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     return stages();
  }

  Widget stages(){
    switch(stage){

      case 0:
        return stageOneOfList();
        break;
      case 1:
        return stageTwo();
        break;
      case 2:
        return stageThree();
        break;
      case 3:
        return stageFourCash();
        break;
      case 4:
        return stageFourPocket();
        break;
      case 5:
        return stageFive();
        break;
      case 6:
        return stageSix();
        break;

      default:
        return const SizedBox.shrink();


    }
  }

  Widget stageTwo() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.8,
    child: Column(
    children: <Widget>[

      Expanded(
        flex: 0,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: IconButton(
                  onPressed: () {
                    stage = 0;
                    setState(() {});
                  },
                  icon: Icon(Icons.arrow_back),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        flex: 0,
          child: Center(child: Text('Check Out',style: TextStyle(
            fontSize: 18
          ),),)
      ),
      const Divider(),
      Expanded(
        child: ListView(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 0,
                  child: restaurant(),
                ),
                const SizedBox(height: 10,),
                Expanded(
                    flex: 0,
                    child: Row(
                      children: [
                        Expanded(child: Center(child: Text('Item'),),),
                        Expanded(child: Center(child: Text('Quantity'),),),
                        Expanded(child: Center(child: Text('Price($CURRENCY)'),),),
                      ],
                    )
                ),
                const Divider(),
                Expanded(
                    flex: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: itemMaker(widget.payload),)
                ),
                const SizedBox(height: 20,),
                if(widget.isRestaurant)
                Expanded(
                  flex: 0,
                  child: Row(
                    children: [

                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Text('Total:$CURRENCY${Utility.sum(widget.payload)}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
                        )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),

              ],
            ),
          ],
        )
      ),
      Expanded(
        flex: 0,
        child: Container(
          color: PRIMARYCOLOR,
          child: Center(
            child: FlatButton(
              onPressed: () async{
                setState(() {stage=2;
                order = order.update(
                    orderItem: OrderItem.fromCartList(widget.payload),
                    orderAmount: Utility.sum(widget.payload),
                    orderCustomer: Customer(
                        customerTelephone: '',
                        customerReview: '',
                        customerName: 'customer'
                    ),
                    orderETA:0,
                    receipt:Receipt(),
                    status:1,
                    orderID:'',
                    docID:'',
                    orderConfirmation:Confirmation(
                      confirmedAt: Timestamp.now(),
                      confirmOTP: '',
                      isConfirmed: true,
                    ),
                    customerID:'customer',
                    agent:widget.session.user.uid,
                    orderLogistic:''
                );
                });

                },
              child: Text(
                'Checkout ($CURRENCY ${Utility.sum(widget.payload)})',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    ]

      )
    );


      }


  Widget stageOneOfList() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: <Widget>[

          Expanded(
            flex: 1,
            child: Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: FlatButton(
                          onPressed: () {
                            widget.payload.clear();
                            setState(() {});
                            widget.cartOps();
                            Get.back();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                                border:
                                Border.all(width: 1, color: Colors.grey)),
                            child: Text(
                              'Clear Basket',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        )),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                                border:
                                Border.all(width: 1, color: Colors.grey)),
                            child: Text(
                              'Close Basket',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
          const Divider(thickness: 1,),
          Expanded(
            flex: 7,
            child: Container(
                color: Colors.white,
                child: ListView.builder(
                    itemCount: widget.payload.length,
                    itemBuilder: (context, index) => Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                BorderSide(width: 1, color: Colors.grey[200]))),
                        child: ListTile(
                          leading: Image.network(
                              widget.payload[index].item.pPhoto.isNotEmpty
                                  ? widget.payload[index].item.pPhoto[0]
                                  : PocketShoppingDefaultCover,
                              fit: BoxFit.fill),
                          title: Column(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${widget.payload[index].item.pName} @ $CURRENCY'
                                      '${widget.payload[index].item.pPrice}',
                                  style: TextStyle(
                                      fontSize:
                                      MediaQuery.of(context).size.height *
                                          0.025),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            if (widget.payload[index].count >
                                                1) {
                                              widget.payload[index].count -= 1;
                                              widget.payload[index].total =
                                                  widget.payload[index].count *
                                                      widget.payload[index].item
                                                          .pPrice;
                                              setState(() {});
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 15),
                                            decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey
                                                      .withOpacity(0.4),
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5))),
                                            child: Text('-'),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          child: Text(
                                              '${widget.payload[index].count}'),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            widget.payload[index].count += 1;
                                            widget.payload[index].total =
                                                widget.payload[index].count *
                                                    widget.payload[index].item
                                                        .pPrice;
                                            setState(() {});
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 15),
                                            decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey
                                                      .withOpacity(0.4),
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5))),
                                            child: Text('+'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 0,
                                    child: Text(
                                        '$CURRENCY ${widget.payload[index].total}'),
                                  )
                                ],
                              )
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              widget.payload.remove(widget.payload[index]);
                              setState(() {});
                              widget.cartOps();
                              if (widget.payload.length == 0)
                                Get.back();
                            },
                            icon: Icon(
                              Icons.close,
                            ),
                          ),
                        )))),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: PRIMARYCOLOR,
              child: Center(
                child: FlatButton(
                  onPressed: () {setState(() {stage=1; });},
                  child: Text(
                    'Next ($CURRENCY ${Utility.sum(widget.payload)})',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  List<Widget> itemMaker(List<CartItem> payload) {
    return List<Widget>.generate(
        payload.length,
            (index) =>
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: Text(
                              ' ${payload[index].item.pName} @ $CURRENCY${payload[index]
                                  .item.pPrice}',textAlign: TextAlign.center,),
                        )
                      ),
                      Expanded(
                        child: Center(
                          child: Text('${payload[index].count}',textAlign: TextAlign.center,),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text('$CURRENCY${payload[index].total}',textAlign: TextAlign.center,),
                        ),
                      )
                    ],
                  ),
                  const Divider(),
                ],

              ),
            )).toList();
  }

  Widget restaurant(){

    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: null,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.title),
                    labelText: 'Table Number',
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.2),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
                  autofocus: false,
                  enableSuggestions: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {

                  },
                )
              ),
            ],
          )
        ],
      ),
    );

  }




  Widget stageThree() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: IconButton(
                  onPressed: () {
                    stage = 1;
                    setState(() {});
                  },
                  icon: Icon(Icons.arrow_back),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                margin: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Proceed with payment to complete transaction',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.025,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Pay with',
                  style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.03),),
              ),

              ListTile(
                onTap: () async {
                  setState(() {
                    _start =120;
                    stage=4;

                  });
                  startTimer();
                },
                leading: CircleAvatar(
                  child:  Image.asset('assets/images/blogo.png'),
                  radius: 30,
                  backgroundColor: Colors.white,
                ),
                title:  Text(
                  'Pocket',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.025),
                ),
                subtitle: Column(
                  children: <Widget>[

                         Text(
                        'Choose this if customer want to pay with pocket.')

                  ],
                ),
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.arrow_forward_ios),
                ),
              ),

              const Divider(
                height: 2,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 5,
              ),
              ListTile(
                onTap: () async {
                  setState(() {stage=3;});
                  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
                  String currentAddress = await Utility.address(position);
                  String collectionId= await Utility.initializePosPay(
                    from: widget.session.user.walletId,
                    to: widget.session.user.walletId,
                    amount: order.orderAmount.round(),
                    agent: widget.session.user.walletId,
                  );
                  if(collectionId != null){
                    var result = await Utility.finalizePosPay(collectionID: collectionId,isSuccessful: true);
                    if(result != null){
                      order = order.update(
                        orderMode:OrderMode(
                          fee: 0,
                          tableNumber: '0',
                          mode: 'inHouse',
                          deliveryMan: '',
                          address: currentAddress,
                          acceptedBy: widget.session.user.uid,
                          coordinate: null,
                        ),
                        receipt: Receipt(
                          collectionID: collectionId,
                          psStatus: 'success',
                          pRef: '',
                          type: 'CASH'
                        )

                      );
                      setState(() {});
                    }
                  }
                  bool result = await finaliseOrder();
                  setState(() {
                    if(result)
                      stage = 5;
                    else
                     stage = 6;
                  });
                },
                leading: CircleAvatar(
                  child:  Image.asset('assets/images/cash.png'),
                  radius: 30,
                  backgroundColor: Colors.white,
                ),
                title: Text(
                   'Cash',
                  style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.025),
                ),
                subtitle: Text('Choose this if customer want to pay with cash.'),
                trailing: IconButton(

                  icon: Icon(Icons.arrow_forward_ios), onPressed: () {  },
                ),
              ),
              SizedBox(
                height: 40,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget stageFourCash() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.8,
    child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: JumpingDotsProgressIndicator(
                fontSize: MediaQuery.of(context)
                    .size
                    .height *
                    0.15,
                color: PRIMARYCOLOR,
              ),
            )
          ),
          Expanded(
            flex: 1,
            child: Center(child: Text('Processing transaction..Please wait'),),
          ),
        ],
    )
    );
  }


  Widget stageFourPocket() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Center(child: Text('Transaction expires in ${_start}s'),),
            ),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  child: QrImage(
                    data: json.encode({
                      'merchant':widget.session.merchant.bName,
                      'amount':Utility.sum(widget.payload),
                      'wallet':widget.session.user.role == 'admin'?widget.session.user.walletId:'',
                      'fcm': widget.session.user.notificationID,
                      'paymentid':paymentId
                    }),


                  )
                )
            ),
            Expanded(

              flex: 1,
              child: Center(child: Text('present the QRcode to customer for scanning'),),

            ),

          ],
        )
    );
  }

  Widget stageFive(){
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              child: Image.asset('assets/images/success.gif'),
            ),
          ),
          Expanded(
              flex: 1,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Transaction has completed successfully',
                        style: TextStyle(
                            fontSize:
                            MediaQuery.of(context).size.height * 0.04),textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FlatButton(
                      onPressed: (){Get.back(result: 'clear');},
                        color: PRIMARYCOLOR,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                        child: Text(
                          'Okay',
                          style: TextStyle(
                            color: Colors.white,
                              fontSize:
                              MediaQuery.of(context).size.height * 0.03),
                        )
                      )
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }


  Widget stageSix(){
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              child: Image.asset('assets/images/erro.gif'),
            ),
          ),
          Expanded(
              flex: 1,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Text(
                      '$errorMessage',
                      style: TextStyle(
                          fontSize:
                          MediaQuery.of(context).size.height * 0.04),textAlign: TextAlign.center
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FlatButton(
                        onPressed: (){
                          setState(() {
                            stage=2;
                          });
                        },
                        color: PRIMARYCOLOR,
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                            child: Text(
                              'Try Again',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                  MediaQuery.of(context).size.height * 0.03),
                            )
                        )
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }


  void startTimer() {
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
                  if(!transactionExpires)
                    {
                      Utility.infoDialogMaker('Transaction has expired.',title: '');
                      stage=2;
                    }


                } else {
                  _start = _start - 1;

                }
              },
            )
          }
      },
    );
  }

  Future<void> ack({String device, bool isSuccessful=true,String type='paymentInitiatedConfirmResponse'}) async {
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
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': '$type',
              'isSuccessful':isSuccessful,
            }
          },
          'to': device,
        }));
  }


  Future<bool> finaliseOrder()async{
    try{
      await OrderRepo.save(order);
      WalletRepo.getWallet(widget.session.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
      return true;}
    catch(_){return false;}
  }


}