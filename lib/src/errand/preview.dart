import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:pocketshopping/src/errand/bloc/errandBloc.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/order/cErrandTracker.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/customer.dart';
import 'package:pocketshopping/src/order/repository/errandObj.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderMode.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/repository/receipt.dart';
import 'package:pocketshopping/src/payment/atmCard.dart';
import 'package:pocketshopping/src/payment/topup.dart';
import 'package:pocketshopping/src/pin/repository/pinRepo.dart';
import 'package:pocketshopping/src/profile/pinSetter.dart';
import 'package:pocketshopping/src/profile/pinTester.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:random_string/random_string.dart';

class Preview extends StatefulWidget {
  final Session user;
  final Position position;
  final LatLng source;
  final LatLng destination;
  final int distance;
  final int fee;
  final int type;
  final String auto;
  final String sourceAddress;
  final String destinationAddress;
  Preview({this.user,this.position,this.source,this.destination,this.distance,this.fee,this.type,this.auto,this.sourceAddress,this.destinationAddress});

  @override
  State<StatefulWidget> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {

  Session currentUser;
  Position position;
  final keyboard = ValueNotifier<bool>(false);
  final autoValidate = ValueNotifier<bool>(false);
  final stage = ValueNotifier<int>(0);
  final fee = ValueNotifier<int>(0);
  final dName = ValueNotifier<String>('');
  final dContact = ValueNotifier<String>('');
  final dComment = ValueNotifier<String>('');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  loc.Location location;
  StreamSubscription<loc.LocationData> locStream;
  Stream<Wallet> _walletStream;
  Stream<List<AgentLocUp>> _agentStream;
  final wallet = ValueNotifier<Wallet>(null);
  final agents = ValueNotifier<List<AgentLocUp>>([]);
  final singleAgent = ValueNotifier<AgentLocUp>(null);
  final payStatus = ValueNotifier<int>(0);
  final payError = ValueNotifier<String>('');




  @override
  void initState() {

    currentUser = widget.user;
    position = widget.position;
    fee.value = widget.fee;
    keyboard.value=false;
    WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((result) {
     wallet.value  = result;
    });

    KeyboardVisibility.onChange.listen((bool visible) {
      keyboard.value = visible;
    });

    _agentStream = ErrandBloc.instance.errandStream;
    _agentStream.listen((result) {
      if(mounted)
      agents.value  = result;
    });


    Utility.locationAccess();
    super.initState();

  }


  @override
  void dispose() {
    locStream?.cancel();
     /*keyboard?.dispose();
     autoValidate?.dispose();
     stage?.dispose();
     fee?.dispose();
     dName?.dispose();
     dContact?.dispose();
     dComment?.dispose();
      _nameController?.dispose();
      _contactController?.dispose();
      _commentController?.dispose();
     wallet?.dispose();
     agents?.dispose();
     singleAgent?.dispose();
     payStatus?.dispose();
     payError?.dispose();*/
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
        onWillPop: () async {
          if(stage.value==0)
          return true;
          else
            {
              stage.value=0;
              return false;
            }

          },
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
                  0.08), // here the desired height
              child: AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: PRIMARYCOLOR,
                  ),
                  onPressed: () {
                    if(stage.value==0)
                     Get.back();
                    else
                    {
                      stage.value=0;
                    }
                  },
                ),
                backgroundColor: Colors.white,
                elevation: 0,
                title: Text("Rider Request",
                  style: TextStyle(color: Colors.black),
                ),
                automaticallyImplyLeading: false,
              ),
            ),
            body: ValueListenableBuilder(
              valueListenable: stage,
              builder: (_,int _stage,__){
                return ValueListenableBuilder(
                    valueListenable: fee,
                    builder: (i,int amount,ii){

                      return ValueListenableBuilder(
                        valueListenable: wallet,
                        builder: (p,Wallet pocket,pp){
                          return ValueListenableBuilder(
                            valueListenable: keyboard,
                            builder: (_,bool keyboard,__){
                              return Column(
                                children: [
                                  if(!keyboard)
                                    Expanded(
                                        flex: 0,
                                        child:
                                        Column(
                                          children: [
                                            if(widget.type == 0)
                                              Image.asset('assets/images/bike.png',fit: BoxFit.fill,),
                                            if(widget.type == 1)
                                              Image.asset('assets/images/car.png',fit: BoxFit.fill),
                                            if(widget.type == 2)
                                              Image.asset('assets/images/van.png',fit: BoxFit.fill),
                                          ],
                                        )
                                    ),
                                  if(_stage == 0)
                                  Expanded(
                                    child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          //border: Border(top: BorderSide(width: 0.5, color: Colors.black54)),
                                          borderRadius: !keyboard?BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20.0)):BorderRadius.zero,
                                          boxShadow: [
                                            !keyboard?BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 6.0,
                                            ):BoxShadow(),
                                          ],
                                        ),

                                        child:
                                        ListView(
                                          children: [
                                            ValueListenableBuilder(
                                              valueListenable: autoValidate,
                                              builder: (_,bool validate,__){
                                                return Form(
                                                  key: _formKey,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(vertical:10,horizontal: 0),
                                                        child: Center(
                                                          child: Text('Enter destination details',style: TextStyle(fontSize: 18),),
                                                        )
                                                        ,),
                                                      Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                                                          child:  TextFormField(
                                                            validator: (value) {
                                                              if (value.isEmpty) {
                                                                return 'Reciever name can not be empty';
                                                              }
                                                              return null;
                                                            },
                                                            controller: _nameController,
                                                            decoration: InputDecoration(
                                                              prefixIcon: Icon(Icons.person),
                                                              labelText: 'Reciever Name',
                                                              filled: true,
                                                              fillColor: Colors.grey.withOpacity(0.2),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                              ),
                                                              enabledBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                              ),
                                                            ),
                                                            autovalidate: validate,
                                                            enableSuggestions: true,
                                                            textInputAction: TextInputAction.done,
                                                            onChanged: (value){},
                                                          )
                                                      ),
                                                      Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                                                          child:  TextFormField(
                                                            validator: (value) {
                                                              if (value.isEmpty) {
                                                                return 'Reciever contact can not be empty';
                                                              }
                                                              if (value.length < 11) {
                                                                return 'Enter a valid Reciever contact';
                                                              }
                                                              return null;
                                                            },
                                                            controller: _contactController,
                                                            decoration: InputDecoration(
                                                              prefixIcon: Icon(Icons.call),
                                                              labelText: 'Reciever Phone',
                                                              filled: true,
                                                              fillColor: Colors.grey.withOpacity(0.2),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                              ),
                                                              enabledBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                              ),
                                                            ),
                                                            autovalidate: validate,
                                                            maxLength: 11,
                                                            enableSuggestions: true,
                                                            keyboardType: TextInputType.phone,
                                                            textInputAction: TextInputAction.done,
                                                            onChanged: (value){},
                                                          )
                                                      ),
                                                      Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                                                          child:  TextFormField(
                                                            validator: (value) {
                                                              if (value.isEmpty) {
                                                                return 'Package description can not be empty';
                                                              }
                                                              return null;
                                                            },
                                                            controller: _commentController,
                                                            decoration: InputDecoration(
                                                              prefixIcon: Icon(Icons.comment),
                                                              labelText: 'Describe Package',
                                                              filled: true,
                                                              fillColor: Colors.grey.withOpacity(0.2),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                              ),
                                                              enabledBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                              ),
                                                            ),
                                                            autovalidate: validate,
                                                            enableSuggestions: true,
                                                            maxLines: 3,
                                                            maxLength: 120,
                                                            maxLengthEnforced: true,
                                                            textInputAction: TextInputAction.done,
                                                            onChanged: (value){},
                                                          )
                                                      ),
                                                      Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                                                          child:  Container(
                                                            color: PRIMARYCOLOR,
                                                            child:
                                                            ValueListenableBuilder(
                                                                valueListenable: agents,
                                                                builder: (_,List<AgentLocUp> agentLocUp,__){
                                                            return FlatButton(
                                                              onPressed: (){
                                                                FocusScope.of(context).requestFocus(FocusNode());
                                                                if(_formKey.currentState.validate()){
                                                                  if(agentLocUp.isNotEmpty){
                                                                    stage.value=1;
                                                                    dComment.value = _commentController.text;
                                                                    dContact.value = _contactController.text;
                                                                    dName.value = _nameController.text;
                                                                    singleAgent.value = agentLocUp.firstWhere((element) => element.agentAutomobile == widget.auto);
                                                                  }
                                                                  else{
                                                                    Get.defaultDialog(
                                                                      title: 'Rider',
                                                                      content: Text('Sorry no available Rider within source region.'),
                                                                      confirm: FlatButton(
                                                                        onPressed: (){
                                                                          Get.back();
                                                                          Get.back();
                                                                        },
                                                                        child: Text('Ok'),
                                                                      )
                                                                    );
                                                                  }
                                                                }
                                                                else{
                                                                  autoValidate.value = true;
                                                                }
                                                              },
                                                              child: Center(
                                                                child: Text('Next',style: TextStyle(color: Colors.white),),
                                                              ),
                                                            );
                                                              }
                                                              )
                                                          )
                                                      ),

                                                    ],
                                                  ),
                                                );
                                              },
                                            )
                                          ],
                                        )
                                    ),
                                  ),
                                  if(_stage == 1)
                                    Expanded(
                                      child:
                                      Container(
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            //border: Border(top: BorderSide(width: 0.5, color: Colors.black54)),
                                            borderRadius: !keyboard?BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20.0)):BorderRadius.zero,
                                            boxShadow: [
                                              !keyboard?BoxShadow(
                                                color: Colors.grey,
                                                offset: Offset(0.0, 1.0), //(x,y)
                                                blurRadius: 6.0,
                                              ):BoxShadow(),
                                            ],
                                          ),

                                          child:
                                                ValueListenableBuilder(
                                                  valueListenable: payStatus,
                                                  builder: (_,int pStatus,__){
                                                    return ValueListenableBuilder(
                                                      valueListenable: payError,
                                                      builder: (_,String pError,__){
                                                        if(pStatus == 0){
                                                          return Column(
                                                            children: <Widget>[
                                                              if(pocket == null)
                                                                Center(
                                                                  child: Text(
                                                                    'Error communicating with server. Check internet and try again',
                                                                    style: TextStyle(
                                                                      fontSize: MediaQuery.of(context).size.height * 0.025,
                                                                    ),
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                ),
                                                              pocket != null?
                                                              Container(
                                                                padding: EdgeInsets.symmetric(vertical: 10),
                                                                child: Text(
                                                                  'Pay With',
                                                                  style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.03),),
                                                              ):const SizedBox.shrink(),
                                                              pocket != null?
                                                              ListTile(
                                                                onTap: () async {
                                                                  if (pocket.walletBalance > widget.fee) {
                                                                    bool set = await PinRepo.isSet(currentUser.user.walletId);
                                                                    if(set)
                                                                      Get.dialog(PinTester(wallet: currentUser.user.walletId,callBackAction: ()async{
                                                                        await processPay('POCKET',{});
                                                                      },));
                                                                    else
                                                                    {
                                                                      Get.defaultDialog(
                                                                          title: 'Pocket PIN',
                                                                          content: Text(
                                                                              'You need to setup pocket PIN before you can proceed with payment'),
                                                                          cancel: FlatButton(
                                                                            onPressed: () {
                                                                              Get.back();
                                                                            },
                                                                            child: Text('Cancel'),
                                                                          ),
                                                                          confirm: FlatButton(
                                                                            onPressed: ()async {
                                                                              Get.back();
                                                                              Get.dialog(PinSetter(user: currentUser.user,callBackAction: ()async{
                                                                                 await processPay('POCKET',{});
                                                                              },
                                                                              ));

                                                                            },
                                                                            child: Text('Setup PIN'),
                                                                          )
                                                                      );
                                                                    }



                                                                  }
                                                                  else{
                                                                    Get.defaultDialog(
                                                                        title: 'TopUp',
                                                                        content: const Text('Do you want to TopUp your Pocket'),
                                                                        cancel: FlatButton(
                                                                          onPressed: () {
                                                                            Get.back();
                                                                          },
                                                                          child: const Text('No'),
                                                                        ),
                                                                        confirm: FlatButton(
                                                                          onPressed: () {
                                                                            Get.back();
                                                                            Get.dialog(TopUp(user: currentUser.user,));
                                                                            //setState(() {
                                                                            // stage = 'PAY';
                                                                            // });
                                                                          },
                                                                          child: Text('Yes'),
                                                                        ));
                                                                  }
                                                                },
                                                                leading: CircleAvatar(
                                                                  child:  Image.asset('assets/images/blogo.png'),
                                                                  radius: 30,
                                                                  backgroundColor: Colors.white,
                                                                ),
                                                                title:  Text(
                                                                  'Pocketshopping',
                                                                  style: TextStyle(
                                                                      fontSize: MediaQuery.of(context).size.height * 0.025),
                                                                ),
                                                                subtitle: Column(
                                                                  children: <Widget>[
                                                                    pocket.walletBalance > (widget.fee)
                                                                        ? Text(
                                                                        'Choose this if you want to pay with pocket.')
                                                                        : Text('Insufficient Fund. Tap to Topup'),
                                                                  ],
                                                                ),
                                                                trailing: IconButton(
                                                                  onPressed: () {},
                                                                  icon: Icon(Icons.arrow_forward_ios),
                                                                ),
                                                              ):const SizedBox.shrink(),

                                                              const Divider(
                                                                height: 2,
                                                                color: Colors.grey,
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              pocket != null?
                                                              ListTile(
                                                                onTap: () async {
                                                                  //await processPay('CARD');
                                                                  Get.defaultDialog(
                                                                      title: 'Confirmation',
                                                                      content: Text(
                                                                          'Please Note that the Rider will not be credited until your package get delivered. In a case where rider fails to deliver your package, your pocketshopping account will be credited with the money.'),
                                                                      cancel: FlatButton(
                                                                        onPressed: () {
                                                                          Get.back();
                                                                        },
                                                                        child: Text('No'),
                                                                      ),
                                                                      confirm: FlatButton(
                                                                        onPressed: () {
                                                                          Get.back();
                                                                          Get.bottomSheet(builder: (context){
                                                                            return Container(
                                                                              //resizeToAvoidBottomInset: true,
                                                                              color: Colors.white,
                                                                              child: ATMCard(
                                                                                  onPressed:(Map<String,dynamic> details) {
                                                                                    Get.back();
                                                                                    processPay('CARD',details);
                                                                                  }
                                                                              ),
                                                                            );
                                                                          },
                                                                              isScrollControlled: true
                                                                          );

                                                                        },
                                                                        child: Text('Yes Pay'),
                                                                      ));
                                                                },
                                                                leading: CircleAvatar(
                                                                  child: Image.asset('assets/images/atm.png'),
                                                                  radius: 30,
                                                                  backgroundColor: Colors.white,
                                                                ),
                                                                title:  Text(
                                                                  'ATM Card',
                                                                  style: TextStyle(
                                                                      fontSize: MediaQuery.of(context).size.height * 0.025),
                                                                ),
                                                                subtitle: const Text('Choose this if you want to pay with ATM Card(instant payment).'),
                                                                trailing: const Icon(Icons.arrow_forward_ios),
                                                              ):const SizedBox.shrink(),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              pocket != null?
                                                              ListTile(
                                                                onTap: () async {
                                                                  //await processPay('CASH');
                                                                  Get.defaultDialog(
                                                                      title: 'Confirmation',
                                                                      content: const Text(
                                                                          'Do not hand cash over, without getting your package delivered pocketshopping will not be held responsible in such situation.'),
                                                                      cancel: FlatButton(
                                                                        onPressed: () {

                                                                          Get.back();


                                                                        },
                                                                        child:const Text('Cancel'),
                                                                      ),
                                                                      confirm: FlatButton(
                                                                        onPressed: ()async {
                                                                          Get.back();
                                                                          await processPay('CASH',{});
                                                                        },
                                                                        child: Text('Ok'),
                                                                      )
                                                                  );
                                                                },
                                                                leading: CircleAvatar(
                                                                  child:  Image.asset('assets/images/cash.png'),
                                                                  radius: 30,
                                                                  backgroundColor: Colors.white,
                                                                ),
                                                                title: Text('Cash',
                                                                  style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.025),
                                                                ),
                                                                subtitle: Text( 'Choose this if you want to pay with cash.'),
                                                                trailing: IconButton(

                                                                  icon: Icon(Icons.arrow_forward_ios), onPressed: () {  },
                                                                ),
                                                              ):const SizedBox.shrink(),
                                                              SizedBox(
                                                                height: 40,
                                                              )
                                                            ],
                                                          );
                                                        }
                                                        else if(pStatus == 1){
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Center(
                                                                child: JumpingDotsProgressIndicator(
                                                                  fontSize: MediaQuery.of(context).size.height * 0.12,
                                                                  color: PRIMARYCOLOR,
                                                                ),
                                                              ),
                                                              Center(
                                                                child: Text('Placing Request...Please wait'),
                                                              )
                                                            ],
                                                          );
                                                        }
                                                        else if(pStatus == 2){
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Center(
                                                                child: Icon(Icons.error,size: 50,),
                                                              ),
                                                              Center(
                                                                child: Text(pError),
                                                              ),
                                                              Center(
                                                                child: FlatButton(
                                                                  onPressed: (){payStatus.value = 0; },

                                                                  child: Text('Try Again',style: TextStyle(color: Colors.white),),
                                                                  color: PRIMARYCOLOR,
                                                                ),
                                                              )
                                                            ],
                                                          );
                                                        }
                                                        else{
                                                          return const SizedBox.shrink();
                                                        }

                                                      },
                                                    );
                                                  },
                                                )



                                      ),
                                    ),

                                ],
                              );
                            },
                          );
                        },
                      );
                    }
                );
              },
            )
        )

    );


  }


  processPay(String method,Map<String,dynamic> details ) async {
    payStatus.value = 1;
    Agent agent = await LogisticRepo.getOneAgent(singleAgent.value.agent);
    Map<String,String> reference;
    details['email']=widget.user.user.email;
    var temp = details['expiry'].toString().split('/');
    Order order = Order(
      orderItem: [],
      orderAmount: 0,
      orderCustomer: Customer(
        customerName: currentUser.user.fname,
        customerReview: '',
        customerTelephone: currentUser.user.telephone,
      ),
      orderMode: OrderMode(
        tableNumber: '',
        coordinate: GeoPoint(position.latitude,position.longitude),
        fee: fee.value,
        deliveryMan: singleAgent.value.agentName,
        address: '',
        acceptedBy: '',
        mode: 'Errand'
      ),
      orderMerchant: '',
      orderCreatedAt: Timestamp.now(),
      orderID: '',
      orderETA: 300,
      status: 0,
      isAssigned: false,
      docID: '',
      customerDevice: await FirebaseMessaging().getToken(),
      resolution: '',
      agent: agent.agent,
      customerID: currentUser.user.uid,
      orderLogistic: '',
      potentials: [singleAgent.value.agent],
      orderConfirmation: Confirmation(
        isConfirmed: false,
        confirmOTP: randomAlphaNumeric(6),
      ),
      errand: ErrandObj(
        source: GeoPoint(widget.source.latitude,widget.source.longitude),
        destination: GeoPoint(widget.destination.latitude,widget.destination.longitude),
        destinationContact: dContact.value,
        destinationName: dName.value,
        comment: dComment.value,
        sourceAddress: widget.sourceAddress,
        destinationAddress: widget.destinationAddress
        ),
      receipt: Receipt(),
    );


    switch(method){
      case 'CARD':
        reference =Map.from(
            await Utility.platform.invokeMethod('CardPay',
                Map.from({
                  "card":(details['card'] as String),
                  "cvv":(details['cvv'] as String),
                  "month":int.parse(temp[0]),
                  "year":int.parse(temp[1]),
                  "amount":fee.value,
                  "email":(details['email'] as String),

                }))
        );
        print(reference);
        if (reference.isNotEmpty) {
          var details = await Utility.fetchPaymentDetail(reference['reference']);
          var status='';
          if(reference['reference'].isNotEmpty)
          status = jsonDecode(details.body)['data']['status'];


          if (status == 'success') {
            var collectId = await Utility.initializePay(
                deliveryFee: order.orderMode.fee.round(),
                channelId: 1,
                referenceID: reference['reference'],
                amount: order.orderAmount.round(),
                from: currentUser.user.walletId,
                state: await Utility.getState(position) );
            if(collectId != null)
                order = order.update(
                  receipt: Receipt(reference: reference['reference'], psStatus: 'PENDING',type: method,collectionID: collectId,),
                  orderCreatedAt: Timestamp.now(),
                  status: 0,
                  orderID: '',
                  docID: '',
                  orderLogistic: '',
                );
            else{
              payStatus.value = 2;
              payError.value = 'Error placing request';
            }

            if(collectId != null) {
              OrderRepo.save(order).then((value) {
                if(value.isNotEmpty){
                  WalletRepo.getWallet(currentUser.user.walletId).
                  then((value) => WalletBloc.instance.newWallet(value));
                  order = order.update(docID: value);
                  //Utility.bottomProgressSuccess(body: 'Request has been sent to Rider',title: 'Request Sent');
                  Utility.pushNotifier(fcm: singleAgent.value.device,body: 'You have a new Errand request. check request bucket for details',title: 'Errand Request',
                      notificationType: 'ErrandRequest',data: {});
                  Get.off(CustomerErrandTracker(user: currentUser.user,order: value,isNew: true,));
                }
                else{
                  payStatus.value = 2;
                  payError.value = 'Error placing request';
                }
              });
            }
          } else {
            if (reference['error'].toString().isNotEmpty) {
                payStatus.value = 2;
                payError.value = reference['error'].toString();
            } else {
              payStatus.value = 2;
              payError.value = 'Error processing payment';
            }
          }
        } else {
          payStatus.value = 2;
          payError.value = 'Error processing payment';
        }
        break;
      case 'CASH':
        var collectId = await Utility.initializePay(
            deliveryFee: order.orderMode.fee.round(),
            channelId: 2,
            referenceID: "",
            amount: order.orderAmount.round(),
            from: currentUser.user.walletId,
            state: await Utility.getState(position)
        );
        if(collectId != null)

            order = order.update(
              receipt: Receipt(reference: '', psStatus: 'PENDING',type: method,collectionID: collectId,),
              orderCreatedAt: Timestamp.now(),
              status: 0,
              orderID: '',
              docID: '',
              orderLogistic: '',
            );

        else
        {
          payStatus.value = 2;
          payError.value = 'Error placing request';
        }
        if(collectId != null) {
          OrderRepo.save(order).then((value) {
            if(value.isNotEmpty){
              WalletRepo.getWallet(currentUser.user.walletId).
              then((value) => WalletBloc.instance.newWallet(value));
              order = order.update(docID: value);
              //Utility.bottomProgressSuccess(body: 'Request has been sent to Rider',title: 'Request Sent');
              Utility.pushNotifier(fcm: singleAgent.value.device,body: 'You have a new Errand request. check request bucket for details',title: 'Errand Request',
                  notificationType: 'ErrandRequest',data: {});
              Get.off(CustomerErrandTracker(user: currentUser.user,order: value,isNew: true,));
            }
            else{
              payStatus.value = 2;
              payError.value = 'Error placing request';
            }
          });
        }
        break;
      case 'POCKET':
        var collectId = await Utility.initializePay(
            deliveryFee: order.orderMode.fee.round(),
            channelId: 3,
            referenceID: "",
            amount: order.orderAmount.round(),
            from: currentUser.user.walletId,
            state: await Utility.getState(position)
        );
        if(collectId != null) {
            order = order.update(
              receipt: Receipt(reference: '',
                psStatus: 'PENDING',
                type: method,
                collectionID: collectId,),
              orderCreatedAt: Timestamp.now(),
              status: 0,
              orderID: '',
              docID: '',
              orderLogistic: '',
            );

        }
        else {
          payStatus.value = 2;
          payError.value = 'Error placing request';
        }
        if(collectId != null) {
          OrderRepo.save(order).then((value) {
            if(value.isNotEmpty){
              WalletRepo.getWallet(currentUser.user.walletId).
              then((value) => WalletBloc.instance.newWallet(value));
              order = order.update(docID: value);
              //Utility.bottomProgressSuccess(body: 'Request has been sent to Rider',title: 'Request Sent');
              Utility.pushNotifier(fcm: singleAgent.value.device,body: 'You have a new Errand request. check request bucket for details',title: 'Errand Request',
                  notificationType: 'ErrandRequest',data: {});
              Get.off(CustomerErrandTracker(user: currentUser.user,order: value,isNew: true,));

            }
            else{
              payStatus.value = 2;
              payError.value = 'Error placing request';
            }
          });
        }
        break;


    }


  }
}