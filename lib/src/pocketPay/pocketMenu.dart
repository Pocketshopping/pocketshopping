import 'dart:async';
import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/payment/topup.dart';
import 'package:pocketshopping/src/pocketPay/tansfer.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';

class PocketMenu extends StatefulWidget {
  final Session user;
  PocketMenu({this.user});
  @override
  _PocketMenuState createState() => new _PocketMenuState();
}

class _PocketMenuState extends State<PocketMenu> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  String barcode = '';
  bool paying;
  Timer _timer;
  int _start;
  Stream<LocalNotification> _notificationsStream;
  bool confirm;
  Stream<Wallet> _walletStream;
  final _walletNotifier = ValueNotifier<Wallet>(null);


  void initState() {
    paying=false;
    confirm = false;
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      if (notification != null) {
        try {
          if (mounted && notification.data['data']['payload'].toString().isNotEmpty) {
            var payload = jsonDecode(notification.data['data']['payload']);
            switch (payload['NotificationType']) {
              case 'paymentInitiatedConfirmResponse':
                setState(() {_start=0;confirm=true;});
                if(payload['isSuccessful']){
                  Utility.infoDialogMaker('Payment Recieved by the merchant.',title: '');
                }
                else{
                  Utility.infoDialogMaker('Error processing payment please try again',title: '');
                }
                NotificationsBloc.instance.clearNotification();
                break;
              case 'RefreshPocketResponse':
                WalletRepo.getWallet(widget.user.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
                break;

              default:
                NotificationsBloc.instance.clearNotification();
                break;
            }



          }
        }
        catch(_){}
      }
    }
    );

    WalletRepo.getWallet(widget.user.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if(mounted) {
        updateWallet(wallet);
      }
    });

    super.initState();
  }

  Future<bool> updateWallet(Wallet wallet){
    _walletNotifier.value=null;
    _walletNotifier.value = wallet;
    return Future.value(true);
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        body: !paying?Column(
          children: [
            const SizedBox(height: 20,),
           Expanded(
             flex: 0,
             child:  Center(child: ValueListenableBuilder(
               valueListenable: _walletNotifier,
              builder: (_,Wallet wallet,__){
                 if(wallet != null)
                   return Text("$CURRENCY${wallet.walletBalance.round()}",style: TextStyle(fontSize: 30),);
                 else
                   return const SizedBox.shrink();
              },
             ),

             ),
           ),
            const SizedBox(height: 20,),
            Expanded(
              child:  ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:GestureDetector(
                          onTap: (){
                            Get.bottomSheet(builder: (context){
                              return Container(
                                color: Colors.white,
                                height: MediaQuery.of(context).size.height*0.3,
                                child: Column(
                                  children: [
                                    ListTile(

                                      title: Text('Scan QR Code'),
                                      subtitle: Text('Scan QR to pay merchant'),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.grey[200],
                                        child: Center(
                                          child: Text('QR',style: TextStyle(color: Colors.black54),),

                                        ),
                                        radius: 25,

                                      ),
                                      onTap: ()async{
                                        if(_walletNotifier.value.walletBalance >0){
                                          Get.back();
                                          await scan();
                                          if(barcode != null){
                                            var data = json.decode(barcode);
                                            if(_walletNotifier.value.walletBalance >= data['amount']){
                                              Get.defaultDialog(
                                                title: 'Payment',
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Center(
                                                      child: Text('Confirm the following pyment request.'),
                                                    ),
                                                    const SizedBox(height: 20,),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text('Merchant'),
                                                        ),
                                                        Expanded(
                                                          child: Text('${data['merchant']}'),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5,),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text('Amount'),
                                                        ),
                                                        Expanded(
                                                          child: Text('$CURRENCY${data['amount']}'),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5,),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text('you are about to pay $CURRENCY${data['amount']} to ${data['merchant']}. Press Yes to continue'),
                                                        ),
                                                      ],
                                                    ),

                                                  ],
                                                ),
                                                cancel: FlatButton(
                                                  onPressed: (){ Get.back();},
                                                  child: Text("No",style: TextStyle(color: Colors.grey[400]),),
                                                ),
                                                confirm: FlatButton(
                                                  onPressed: ()async{

                                                    Get.back();
                                                    setState(() {
                                                      paying =true;
                                                      confirm = false;
                                                    });
                                                    _start=60;
                                                    startTimer();

                                                    paymentNotifier(
                                                      device: data['fcm'],
                                                      paymentId: data['paymentid'],
                                                      customer: widget.user.user.uid,
                                                      name: widget.user.user.fname,
                                                      cWallet: widget.user.user.walletId,
                                                    ).then((value) => null);

                                                  },
                                                  child: Text("Yes"),
                                                ),
                                              );
                                            }
                                            else{
                                              Utility.infoDialogMaker('Insufficient Fund',title: '');
                                            }
                                          }
                                          else{
                                            Utility.infoDialogMaker("Error scanning QR code.",title: '');
                                          }

                                        }
                                        else{
                                          Utility.infoDialogMaker('Insufficient Fund',title: '');
                                          //Get.back();
                                        }
                                      },

                                    ),
                                    const Divider(),
                                    ListTile(

                                      title: Text('Enter Account ID'),
                                      subtitle: Text('enter account id to pay merchant'),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.grey[200],
                                        child: Center(
                                          child: Text('ID',style: TextStyle(color: Colors.black54),),

                                        ),
                                        radius: 25,
                                      ),
                                      enabled: false,
                                    ),
                                  ],
                                ),
                              );
                            }).then((value) => null);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            child: Container(
                              // height: double.infinity,
                              //width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: Offset(0, 1), // changes position of shadow
                                  ),
                                ],
                              ),
                              height: MediaQuery.of(context).size.height*0.2,
                              width: MediaQuery.of(context).size.width*0.2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.credit_card,size: 50,color: PRIMARYCOLOR,),
                                  Text('Pay from Pocket')
                                ],
                              ),
                            ),
                          )
                        )
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            try {
                              if (_walletNotifier.value.walletBalance > 0) {
                                Get.dialog(PocketTransfer(
                                  wallet: widget.user.user.walletId,
                                  user: widget.user.user,
                                  callBackAction: () {
                                    WalletRepo.getWallet(widget.user.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
                                  },));
                              }
                              else {
                                Utility.infoDialogMaker(
                                    'Insufficient Fund', title: '');
                              }
                            }
                            catch(_){}
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            child: Container(
                              height: MediaQuery.of(context).size.height*0.2,
                              width: MediaQuery.of(context).size.width*0.2,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: Offset(0, 1), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.title,size: 50,color: PRIMARYCOLOR,),
                                  Text('Pocket Transfer')
                                ],
                              ),
                            ),
                          )
                        )
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child:GestureDetector(
                              onTap: (){
                                Get.dialog(TopUp(user: widget.user.user,));
                              },
                              child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: Offset(0, 1), // changes position of shadow
                                  ),
                                ],
                              ),
                              height: MediaQuery.of(context).size.height*0.2,
                              width: MediaQuery.of(context).size.width*0.2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,size: 50,color: PRIMARYCOLOR,),
                                  Text('TopUp')
                                ],
                              ),
                            ),
                          )
                          )
                      ),
                      Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            child: Container(
                              height: MediaQuery.of(context).size.height*0.2,
                              width: MediaQuery.of(context).size.width*0.2,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: Offset(0, 1), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.info_outline,size: 50,color: PRIMARYCOLOR,),
                                  Text('Issues')
                                ],
                              ),
                            ),
                          )
                      ),
                    ],
                  ),
                ],
              )
            ),

          ],
        ):Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children:[ Center(
            child: Text('${_start}s',style: TextStyle(fontSize: 50),)
          ),
            Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                  child: Text('Waiting for response from merchant. Please wait',style: TextStyle(fontSize: 18),textAlign: TextAlign.center,)
                )
            ),
              ]
        )
    );
  }


  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = null;
        });
      } else {
        setState(() => this.barcode = null);
      }
    } on FormatException {
      setState(() => this.barcode =null);
    } catch (e) {
      setState(() => this.barcode = null);
    }
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
                  paying = false;
                  if(!confirm){
                    //Utility.finalizePosPay(collectionID: collectionId,isSuccessful: false);
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


  Future<void> paymentNotifier({String device,String customer,String name,String paymentId,String cWallet }) async {
    print('${cWallet}');
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
            'body': 'Hello. A new payment has been initiated by $name',
            'title': 'New Payment'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'paymentInitiatedResponse',
              'customer': customer,
              'name': name,
              'paymentId': paymentId,
              'customerWallet':cWallet,
              'fcm':await _fcm.getToken(),
            }
          },
          'to': device,
        }));
  }



}
