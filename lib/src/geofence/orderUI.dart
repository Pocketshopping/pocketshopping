import 'dart:async';
import 'dart:convert';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:geocoder/geocoder.dart' as geocode;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/channels/repository/channelObj.dart';
import 'package:pocketshopping/src/channels/repository/channelRepo.dart';
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
import 'package:pocketshopping/src/order/timer.dart';
import 'package:pocketshopping/src/order/tracker.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/MyOrder/orderGlobal.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:random_string/random_string.dart';

class OrderUI extends StatefulWidget {
  final Merchant merchant;
  final dynamic payload;
  final User user;
  final double distance;
  final Position initPosition;
  final Function cartOps;

  OrderUI(
      {this.merchant,
      this.payload,
      this.user,
      this.distance,
      this.initPosition,
      this.cartOps});

  @override
  State<StatefulWidget> createState() => _OrderUIState();
}

class _OrderUIState extends State<OrderUI> {
  static const platform = const MethodChannel('fleepage.pocketshopping');
  final FirebaseMessaging _fcm = FirebaseMessaging();
  int OrderCount;
  String stage;
  bool homeDelivery;
  Position position;
  String deliveryAddress;
  StreamSubscription<loc.LocationData> geoStream;
  final TextEditingController _address = TextEditingController();
  final TextEditingController _contact = TextEditingController();
  final TextEditingController _table = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> _tableformKey = GlobalKey<FormState>();
  double dist;
  bool userChange;
  loc.Location location;
  String mode;
  bool contact;
  bool mobile;
  bool table;
  bool paydone;
  double screenHeight;
  String cardNumber;
  String expiryDate;
  String cardHolderName;
  String cvvCode;
  bool isCvvFocused;
  bool scrollable;
  double formHeight;
  int _start = 5;
  Timer _timer;
  Order order;
  Stream<LocalNotification> _notificationsStream;
  double dETA;
  int dCut;
  String eta;
  OrderGlobalState odState;
  Channels channel;
  Stream<Wallet> _walletStream;
  Wallet _wallet;
  String type;

  @override
  void initState() {
    type = 'MotorBike';
    odState = Get.put(OrderGlobalState());
    eta = '';
    dCut = 0;
    dETA = 0.0;
    order = Order(orderMerchant: widget.merchant.mID);
    formHeight = 0.0;
    scrollable = true;
    cardNumber = '';
    expiryDate = '';
    cardHolderName = '';
    cvvCode = '';
    isCvvFocused = false;
    contact = false;
    mobile = false;
    deliveryAddress = '';
    OrderCount = 1;
    screenHeight = 0.8;
    dist = widget.distance * 1000;
    table = false;
    stage = 'ORDERNOW';
    homeDelivery = false;
    mode = '';
    paydone = false;
    position = widget.initPosition;
    location = new loc.Location();
    location.changeSettings(
        accuracy: loc.LocationAccuracy.high, distanceFilter: 10);
    geoStream =
        location.onLocationChanged.listen((loc.LocationData cLoc) async {
      position = Position(
          latitude: cLoc.latitude,
          longitude: cLoc.longitude,
          altitude: cLoc.altitude,
          accuracy: cLoc.accuracy);
      dist = await Geolocator().distanceBetween(
          cLoc.latitude,
          cLoc.longitude,
          widget.merchant.bGeoPoint['geopoint'].latitude,
          widget.merchant.bGeoPoint['geopoint'].longitude);
      if (mounted) setState(() {});
      await address(Position(
          latitude: cLoc.latitude,
          longitude: cLoc.longitude,
          altitude: cLoc.altitude,
          accuracy: cLoc.accuracy));
    });
    userChange = false;
    WalletRepo.getWallet(widget.user.walletId)
        .then((value) => WalletBloc.instance.newWallet(value));
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if (mounted) {
        _wallet = wallet;
        setState(() {});
      }
    });
    //print(_wallet.pocketBalance.toString());
    //_notificationsStream = NotificationsBloc.instance.notificationsStream;
    // _notificationsStream.listen((notification) {});
    //deliveryETA(widget.distance * 1000);
    //deliveryCut(widget.distance * 1000);
    address(widget.initPosition).then((value) => null);
    ChannelRepo.get(widget.merchant.mID).then((value) => channel = value);
    //print('${widget.merchant.bGeoPoint['geopoint']}');
    super.initState();
  }

  Future<void> address(Position position) async {
    final coordinates =
        geocode.Coordinates(position.latitude, position.longitude);
    var address =
        await geocode.Geocoder.local.findAddressesFromCoordinates(coordinates);
    if (mounted)
      setState(() {
        List<String> temp = address.first.addressLine.split(',');
        temp.removeLast();
        deliveryAddress =
            temp.reduce((value, element) => value + ',' + element);
        //print(_contact.text);
        if (deliveryAddress != _address.text && !userChange)
          homeDelivery = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopScope,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: CarouselBottomSheetTemplate(
              scrollable: scrollable,
              height: MediaQuery.of(context).size.height * screenHeight,
              child: stages())),
    );
  }

  Widget CardPage() {
    setState(() {
      scrollable = false;
      screenHeight = 1;
    });
    return Container(
        height: MediaQuery.of(context).size.height,
        child: Column(children: <Widget>[
          //
          Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Column(
                children: <Widget>[
                  //SizedBox(height: MediaQuery.of(context).size.height*0.1,),
                  CreditCardWidget(
                    cardBgColor: PRIMARYCOLOR,
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    showBackView: isCvvFocused,
                  )
                ],
              )),
          Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: ListView(
              children: <Widget>[
                CreditCardForm(
                  themeColor: PRIMARYCOLOR,
                  onCreditCardModelChange: onCreditCardModelChange,
                  formAction: () {
                    setState(() {
                      stage = "PAY";
                    });
                    ProcessPay('CARD');
                  },
                  fieldListner: () {
                    setState(() {
                      formHeight = 0.5;
                    });
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Image.asset('assets/images/paystack.png',
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.1),
                SizedBox(
                  height: MediaQuery.of(context).size.height * formHeight,
                ),
              ],
            ),
          ),
        ]));
  }

  int deliveryCut(double distance) {
    CloudFunctions.instance
        .getHttpsCallable(
      functionName: "DeliveryCut",
    )
        .call({'distance': distance}).then((value) =>

            //print('DeliveryCut ${value.data}')
            mounted
                ? setState(() {
                    dCut = value.data;
                  })
                : null);
    /*int y1 = 50;
    int y2 = 100;
    int c = 300;
    if(distance < 3000)
      return 300;
    else if(distance<500)
      return (((distance/1000) - 3)*y1+c).round();
    else
      return (((distance/1000) - 3)*y2+c).round();*/
  }

  double deliveryETA(
      double distance, String type, double ttc, int server, double top) {
    //print('${distance}');
    /*double eta=0.0;
    eta = (distance/8.33333)+960;

    return eta;*/
    CloudFunctions.instance
        .getHttpsCallable(
      functionName: "ETA",
    )
        .call({
      'distance': distance,
      'type': type,
      'ttc': ttc,
      'server': server,
      'top': top
    }).then((value) =>

                //print('DeliveryETA ${value.data/60}')

                {
                  if (mounted)
                    setState(() {
                      dETA = 12.12; //(value.data as double).toDouble();
                      eta =
                          '0'; //etaDisplay((value.data as double)).toString();
                    })
                }
            // value.data

            );
  }

  Widget DetailMaker() {
    switch (mode) {
      case 'Delivery':
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text('Item Total'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('\u20A6${order.orderAmount}'),
                    ),
                  )
                ],
              ),
              Divider(
                height: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text('Delivery Fee'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('\u20A6${dCut}'),
                    ),
                  )
                ],
              ),
              Divider(
                height: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '\u20A6${dCut + order.orderAmount}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
              Divider(
                height: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text('Mode'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(mode),
                    ),
                  )
                ],
              ),
              Divider(
                height: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text('Mobile Telephone'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(_contact.text),
                    ),
                  )
                ],
              ),
              Divider(
                height: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text('Delivery Address'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(_address.text),
                    ),
                  )
                ],
              ),
              Divider(
                height: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text('Delivery Time'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('~$eta minute'),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
        break;
      case 'Pickup':
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '\u20A6${order.orderAmount}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
              Divider(
                height: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text('Mode'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(mode),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
        break;
      case 'TakeAway':
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '\u20A6${order.orderAmount}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
              Divider(
                height: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text('Mode'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(mode),
                    ),
                  )
                ],
              )
            ],
          ),
        );
        break;
      case 'ServeMe':
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '\u20A6${order.orderAmount}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
              Divider(
                height: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text('Mode'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(mode),
                    ),
                  )
                ],
              ),
              Divider(
                height: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text('Table number'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('${_table.text}'),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
        break;
    }
  }

  @override
  void dispose() {
    geoStream.cancel();
    super.dispose();
  }

  etaDisplay(double second) {
    int minute = 0;
    minute = (second / 60).round();
    return minute + 1;
  }

  Future<http.Response> fetchPaymentDetail(String ref) async {
    final response = await http.get(
      'https://api.paystack.co/transaction/verify/$ref',
      headers: {
        "Accept": "application/json",
        "Authorization":
            "Bearer sk_test_8c0cf47e2e690e41c984c7caca0966e763121968"
      },
    );
    if (response.statusCode == 200) {
      return response;
    } else {
      return null;
    }
  }

  inHouseETA(double distance) {}

  List<Widget> ItemMaker(dynamic payload) {
    if (payload.runtimeType == List<CartItem>().runtimeType) {
      return List<Widget>.generate(
          payload.length,
          (index) => Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                              ' ${payload[index].item.pName} @ ${payload[index].item.pPrice}'),
                        ),
                        Expanded(
                          child: Center(
                            child: Text('${payload[index].count}'),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text('${payload[index].total}'),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )).toList();
    } else {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text(' ${payload.pName} @ ${payload.pPrice}'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('$OrderCount'),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('${payload.pPrice * OrderCount}'),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ];
    }
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  Widget orderRequest() {
    return Container(
      child: Column(
        children: <Widget>[
          Center(
            child: TimerWidget(
              seconds: 120,
              onFinish: (String accepted) {
                if (mode == 'Delivery')
                  order = order.update(
                      orderMode: OrderMode(
                        mode: mode,
                        coordinate:
                            GeoPoint(position.latitude, position.longitude),
                        address: _address.text,
                        acceptedBy: accepted,
                        fee: dCut,
                      ),
                      orderETA: dETA.round());
                order = order.update(
                  orderConfirmation: Confirmation(
                    isConfirmed: false,
                    confirmOTP: randomAlphaNumeric(6),
                  ),
                );
                stage = 'CHECKOUT';
                setState(() {});
              },
              onAgent: mode == 'Delivery' &&
                      widget.merchant.bDelivery == 'Yes, Use pocketLogistics'
                  ? nearByAgent
                  : null,
              onMerchant: queryMerchant,
            ),
          )
        ],
      ),
    );
  }

  Widget payDone() {
    return paydone
        ? Container(
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
                          Text(
                            'Order successfully placed',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.04),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '${_start}s',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.05),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Center(
              child: JumpingDotsProgressIndicator(
                fontSize: MediaQuery.of(context).size.height * 0.12,
                color: PRIMARYCOLOR,
              ),
            ),
          );
  }

  Widget payError() {
    return Center(
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.18,
              child: Icon(
                Icons.close,
                color: Colors.red,
                size: MediaQuery.of(context).size.height * 0.18,
              ),
            ),
            Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Error processing payment. ensure you are entering the correct details',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.025),
                    textAlign: TextAlign.center,
                  )),
            ),
            Center(
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    screenHeight = 0.8;
                    stage = 'CHECKOUT';
                  });
                },
                child: Text('Try Again'),
              ),
            )
          ],
        ),
      ),
    );
  }

  int PickupETA() {
    int eta = 360;
    CloudFunctions.instance
        .getHttpsCallable(
          functionName: "PickupETA",
        )
        .call()
        .then((value) => eta = value.data);
    return eta;
  }

  ProcessPay(dynamic method) async {
    setState(() {
      screenHeight = 1;
    });
    String reference = '';
    reference = await platform.invokeMethod('CardPay');
    if (reference.isNotEmpty) {
      var details = await fetchPaymentDetail(reference);
      //print(json.decode(details.body));
      //await Future.delayed(Duration(seconds: 5),(){
      if (details != null) {
        setState(() {
          screenHeight = 0.8;
          stage = 'UPLOADING';
          paydone = false;
          order = order.update(
            receipt: Receipt(reference: reference, PsStatus: 'PENDING'),
            orderCreatedAt: Timestamp.now(),
            status: 'PROCESSING',
            orderID: '',
            docID: '',
          );
        });
        OrderRepo.save(order).then((value) => setState(() {
              startTimer();
              order = order.update(docID: value);
              paydone = true;
            }));
      } else {
        print('Important!!! $reference');
        if (reference == 'ERROR') {
          setState(() {
            screenHeight = 0.8;
            stage = 'ERROR';
          });
        } else {
          setState(() {
            screenHeight = 0.8;
            stage = 'CHECKOUT';
            //paydone = true;
            //startTimer();
          });
        }
      }
    } else {
      setState(() {
        screenHeight = 0.8;
        stage = 'CHECKOUT';
        //paydone = true;
        //startTimer();
      });
    }

    //});
  }

  Future<void> nearByAgent() {
    LogisticRepo.getNearByAgent(
            Position(
                latitude: widget.merchant.bGeoPoint['geopoint'].latitude,
                longitude: widget.merchant.bGeoPoint['geopoint'].longitude),
            'MotorBike')
        .then((value) {
      print('agent around: $value');
      queryAgent(value);
    });
  }

  Future<void> queryAgent(List<String> nAgent) async {
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
            'body': 'Hi. Can you run this delivery, click for details',
            'title': 'New Delivery'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'NearByAgent',
              'Items':
                  widget.payload.runtimeType == List<CartItem>().runtimeType
                      ? CartItem.toListMap(widget.payload)
                      : [
                          {
                            'productName': widget.payload.pName,
                            'productCount': OrderCount
                          }
                        ],
              'merchant': widget.merchant.bName,
              'mAddress': widget.merchant.bAddress,
              'Amount': order.orderAmount,
              'type': order.orderMode.mode,
              'Address': order.orderMode.mode == 'Delivery'
                  ? order.orderMode.address
                  : '',
              'deliveryFee': order.orderMode.mode == 'Delivery' ? dCut : 0.0,
              'deliveryDistance':
                  order.orderMode.mode == 'Delivery' ? dist : 0.0,
              'time': [Timestamp.now().seconds, Timestamp.now().nanoseconds],
              'fcmToken': widget.user.notificationID,
              'agentCount': nAgent.length,
            }
          },
          'registration_ids': nAgent,
        }));
  }

  Future<void> queryMerchant() async {
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
            'body':
                'Hi. Can you process my order. ${order.orderCustomer.customerName}',
            'title': 'New Order Request'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'OrderRequest',
              'Items':
                  widget.payload.runtimeType == List<CartItem>().runtimeType
                      ? CartItem.toListMap(widget.payload)
                      : [
                          {
                            'productName': widget.payload.pName,
                            'productCount': OrderCount
                          }
                        ],
              'Amount': order.orderAmount,
              'type': order.orderMode.mode,
              'Address': order.orderMode.mode == 'Delivery'
                  ? order.orderMode.address
                  : '',
              'deliveryFee': order.orderMode.mode == 'Delivery' ? dCut : 0.0,
              'deliveryDistance':
                  order.orderMode.mode == 'Delivery' ? dist : 0.0,
              'time': [Timestamp.now().seconds, Timestamp.now().nanoseconds],
              'fcmToken': widget.user.notificationID,
            }
          },
          'registration_ids': channel.dChannels,
        }));
  }

  Widget stageFour() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: IconButton(
                  onPressed: () {
                    stage = 'OVERVIEW';
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
                  'Your order has been confirmed by ${widget.merchant.bName} proceed with payment to complete order',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.025,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Pay With',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.03),
                ),
              ),
              ListTile(
                onTap: () async {
                  if (_wallet.pocketBalance > order.orderAmount) {
                    setState(() {
                      stage = 'PAY';
                    });
                  }
                  Get.defaultDialog(
                      title: 'Confirmation',
                      content: Text('Do you want to TopUp your Pocket'),
                      cancel: FlatButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text('No'),
                      ),
                      confirm: FlatButton(
                        onPressed: () {
                          Get.back();
                          setState(() {
                            stage = 'PAY';
                          });
                        },
                        child: Text('Yes'),
                      ));
                },
                leading: CircleAvatar(
                  child: Image.asset('assets/images/blogo.png'),
                  radius: 30,
                  backgroundColor: Colors.white,
                ),
                title: Text(
                  'Pocketshopping',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.03),
                ),
                subtitle: Column(
                  children: <Widget>[
                    _wallet.pocketBalance > order.orderAmount
                        ? Text(
                            'Choose this if you want your order delivered to you.')
                        : Text('Insufficient Fund. Tap to Topup'),
                  ],
                ),
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.arrow_forward_ios),
                ),
              ),
              Divider(
                height: 2,
                color: Colors.grey,
              ),
              SizedBox(
                height: 5,
              ),
              ListTile(
                onTap: () async {
                  //await ProcessPay('CARD');
                  Get.defaultDialog(
                      title: 'Confirmation',
                      content: Text(
                          'Please Note that ${widget.merchant.bName} will not be credited until you confirm the order. In a case where ${widget.merchant.bName} fails to deliver your pocketshopping account will be credited with the money. This method of payment is recommended'),
                      cancel: FlatButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text('No'),
                      ),
                      confirm: FlatButton(
                        onPressed: () {
                          Get.back();
                          setState(() {
                            screenHeight = 1;
                            stage = 'PAYCARD';
                          });
                        },
                        child: Text('Yes Pay'),
                      ));
                },
                leading: CircleAvatar(
                  child: Image.asset('assets/images/atm.png'),
                  radius: 30,
                  backgroundColor: Colors.white,
                ),
                title: Text(
                  'ATM Card',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.03),
                ),
                subtitle: Text('Choose this if you want to pay with ATM Card.'),
                trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                ),
              ),
              Divider(
                height: 2,
                color: Colors.grey,
              ),
              SizedBox(
                height: 5,
              ),
              ListTile(
                onTap: () async {
                  //await ProcessPay('CASH');
                  Get.defaultDialog(
                      title: 'Confirmation',
                      content: Text(
                          'Do not hand cash over, without getting your order/purchase delivered pocketshopping will not be held responsible in situation like this, this method of payment is not recommended'),
                      cancel: FlatButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text('No'),
                      ),
                      confirm: FlatButton(
                        onPressed: () {
                          Get.back();
                          setState(() {
                            stage = 'PAY';
                          });
                        },
                        child: Text('Yes Pay'),
                      ));
                },
                leading: CircleAvatar(
                  child: Image.asset('assets/images/cash.png'),
                  radius: 30,
                  backgroundColor: Colors.white,
                ),
                title: Text(
                  mode == 'Delivery' ? 'pay on Delivery (Cash only)' : 'Cash',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.03),
                ),
                subtitle: Text(mode == 'Delivery'
                    ? 'Choose this if you want to pay on delivery. (Cash only)'
                    : 'Choose this if you want to pay with cash.'),
                trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
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

  Widget stageOne() {
    setState(() {
      screenHeight = 0.6;
    });
    return Container(
        child: Center(
      child: Column(
        children: <Widget>[
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width,
              child: Carousel(
                images: widget.payload.pPhoto.isNotEmpty
                    ? List<NetworkImage>.generate(widget.payload.pPhoto.length,
                        (int index) {
                        return NetworkImage(widget.payload.pPhoto[index]);
                      }).toList()
                    : [NetworkImage(PocketShoppingDefaultCover)],
              )),
          SizedBox(
            height: 10,
          ),
          Text(
            widget.payload.pName,
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.height * 0.025),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            '@ \u20A6 ${widget.payload.pPrice.toString()}',
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.height * 0.025),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        if (mounted)
                          setState(() {
                            if (OrderCount > 1) OrderCount -= 1;
                          });
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            border: Border.all(
                              width: 1,
                              color: Colors.grey.withOpacity(0.4),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text('-'),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Text(
                          '$OrderCount ${widget.payload.pUnit.toString()}'),
                    ),
                    GestureDetector(
                      onTap: () {
                        OrderCount += 1;
                        setState(() {});
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            border: Border.all(
                              width: 1,
                              color: Colors.grey.withOpacity(0.4),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text('+'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                color: PRIMARYCOLOR,
                child: FlatButton(
                  onPressed: () {
                    setState(() {
                      order = order.update(
                          orderItem: OrderItem.fromCartList([
                            CartItem(
                                count: OrderCount,
                                item: widget.payload,
                                total: widget.payload.pPrice * OrderCount)
                          ]),
                          orderAmount: widget.payload.pPrice * OrderCount);
                      stage = 'FAROPTION';
                      screenHeight = 0.8;
                    });
                  },
                  child: Text(
                    'Next (\u20A6 ${widget.payload.pPrice * OrderCount})',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ))
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    ));
  }

  Widget stageOneOfList() {
    setState(() {
      screenHeight = 0.8;
    });
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
                            Navigator.pop(context);
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
                                    BorderSide(width: 1, color: Colors.grey))),
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
                                  '${widget.payload[index].item.pName} @ \u20A6'
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
                                        '\u20A6 ${widget.payload[index].total}'),
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
                                Navigator.pop(context);
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
                  onPressed: () {
                    setState(() {
                      order = order.update(
                          orderItem: OrderItem.fromCartList(widget.payload),
                          orderAmount: sum(widget.payload));
                      stage = 'FAROPTION';
                    });
                  },
                  child: Text(
                    'Next (\u20A6 ${sum(widget.payload)})',
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

  Widget stages() {
    switch (stage) {
      case 'ORDERNOW':
        return widget.payload.runtimeType == List<CartItem>().runtimeType
            ? stageOneOfList()
            : stageOne();
        break;
      case 'FAROPTION':
        return stageTwo();
        break;
      case 'OVERVIEW':
        return stageThree();
        break;
      case 'CHECKOUT':
        return stageFour();
        break;
      case 'PAY':
        return payDone();
        break;
      case 'PAYCARD':
        return CardPage();
        break;
      case 'REQUEST':
        return orderRequest();
        break;
      case 'ERROR':
        return payError();
        break;
      case 'UPLOADING':
        return UploadingOrder();
        break;

      default:
        return stageOne();
        break;
    }
  }

  Widget stageThree() {
    //print(order.orderMode.address);
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
                    stage = 'FAROPTION';
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
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Text(
              'Preview',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.03),
            ),
          ),
          Container(
              height: MediaQuery.of(context).size.height * 0.55,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 1,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Item(s)',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.025,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Divider(
                      height: 2,
                      color: Colors.grey,
                    ),
                    Column(
                      children: ItemMaker(widget.payload),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Details(s)',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.025,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Divider(
                      height: 2,
                      color: Colors.grey,
                    ),
                    DetailMaker()
                  ],
                ),
              )),
          Expanded(
            child: Container(
                width: MediaQuery.of(context).size.width,
                color: PRIMARYCOLOR,
                child: Center(
                  child: FlatButton(
                    onPressed: () {
                      //sendAndRetrieveMessage();
                      stage = 'REQUEST';
                      //stage = 'CHECKOUT';
                      setState(() {});
                    },
                    child: Text(
                      'Checkout ( ${order.orderAmount} )',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )),
          )
        ],
      ),
    );
  }

  Widget stageTwo() {
    //print(order.orderItem.first.totalAmount);

    setState(() {
      screenHeight = 0.8;
    });
    //

    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: IconButton(
                  onPressed: () {
                    stage = 'ORDERNOW';
                    screenHeight = 0.6;
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
          dist > 100
              ? Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 2))),
                      child: Text(
                        'How do you want it?',
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.03),
                      ),
                    ),
                    Divider(
                      height: 2,
                      color: Colors.grey,
                    ),
                    widget.merchant.bDelivery != 'No'
                        ? ListTile(
                            onTap: () {
                              _address.text = deliveryAddress;
                              _contact.text = widget.user.telephone;
                              homeDelivery = homeDelivery ? false : true;
                              if (mounted) setState(() {});
                              deliveryETA(
                                  dist != null ? dist : widget.distance * 1000,
                                  'Delivery',
                                  0.0,
                                  0,
                                  0.0);
                              deliveryCut(
                                  dist != null ? dist : widget.distance * 1000);
                            },
                            leading: CircleAvatar(
                              child:
                                  Image.asset('assets/images/delivery-man.jpg'),
                              radius: 30,
                              backgroundColor: Colors.white,
                            ),
                            title: Text(
                              'Delivery',
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.03),
                            ),
                            subtitle: Column(
                              children: <Widget>[
                                Text(
                                    'Choose this if you want your order delivered to you.'),
                                homeDelivery
                                    ? true
                                        ? Form(
                                            key: _formKey,
                                            child: Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                TextFormField(
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'Your mobile number';
                                                    } else if (value.length <=
                                                        11) {
                                                      return 'Valid Mobile number please';
                                                    }
                                                    return null;
                                                  },
                                                  controller: _contact,
                                                  decoration: InputDecoration(
                                                    prefixIcon:
                                                        Icon(Icons.call),
                                                    labelText:
                                                        'Contact Telephone',
                                                    filled: true,
                                                    fillColor: Colors.grey
                                                        .withOpacity(0.2),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.3)),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.3)),
                                                    ),
                                                  ),
                                                  autovalidate: mobile,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      mobile = true;
                                                    });
                                                  },
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                TextFormField(
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'Your address';
                                                    }
                                                    return null;
                                                  },
                                                  controller: _address,
                                                  decoration: InputDecoration(
                                                    prefixIcon:
                                                        Icon(Icons.place),
                                                    labelText:
                                                        'Delivery Address',
                                                    filled: true,
                                                    fillColor: Colors.grey
                                                        .withOpacity(0.2),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.3)),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.3)),
                                                    ),
                                                  ),
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  autovalidate: contact,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      userChange = true;
                                                      contact = true;
                                                    });
                                                  },
                                                  maxLines: 3,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                if ((widget.merchant
                                                            .bCategory !=
                                                        'Restuarant') &&
                                                    (widget.merchant
                                                            .bDelivery ==
                                                        'Yes, Use pocketLogistics'))
                                                  Container(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5,
                                                            horizontal: 5),
                                                    child: Column(
                                                      children: <Widget>[
                                                        Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              "Mode",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black54),
                                                            )),
                                                        DropdownButtonFormField<
                                                            String>(
                                                          value: type,
                                                          items: [
                                                            'MotorBike',
                                                            'Car',
                                                            'Van'
                                                          ]
                                                              .map((label) =>
                                                                  DropdownMenuItem(
                                                                    child: Text(
                                                                      label,
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black54),
                                                                    ),
                                                                    value:
                                                                        label,
                                                                  ))
                                                              .toList(),
                                                          isExpanded: true,
                                                          hint: Text('Mode'),
                                                          decoration:
                                                              InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none),
                                                          onChanged: (value) {
                                                            type = value;
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                FlatButton(
                                                    onPressed: () {
                                                      if (_formKey.currentState
                                                          .validate()) {
                                                        stage = 'OVERVIEW';
                                                        mode = 'Delivery';
                                                        order = order.update(
                                                          orderMode: OrderMode(
                                                            mode: mode,
                                                            coordinate: GeoPoint(
                                                                position
                                                                    .latitude,
                                                                position
                                                                    .longitude),
                                                            address:
                                                                _address.text,
                                                          ),
                                                          orderCustomer:
                                                              Customer(
                                                            customerName: widget
                                                                .user.fname,
                                                            customerReview: '',
                                                            customerTelephone:
                                                                _contact.text,
                                                          ),
                                                          customerID:
                                                              widget.user.uid,
                                                        );
                                                        setState(() {});
                                                      }
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10,
                                                              horizontal: 15),
                                                      color: PRIMARYCOLOR,
                                                      child: Text(
                                                        'Submit',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ))
                                              ],
                                            ),
                                          )
                                        : Center(
                                            child: JumpingDotsProgressIndicator(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.12,
                                              color: PRIMARYCOLOR,
                                            ),
                                          )
                                    : Container()
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                homeDelivery = homeDelivery ? false : true;
                                setState(() {});
                              },
                              icon: !homeDelivery
                                  ? Icon(Icons.arrow_forward_ios)
                                  : Icon(Icons.close),
                            ),
                          )
                        : ListTile(
                            leading: CircleAvatar(
                              child: Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              radius: 30,
                              backgroundColor: Colors.white,
                            ),
                            title: Text(
                              'Home delivery',
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.height * 0.03,
                                  color: Colors.grey),
                            ),
                            subtitle: Text(
                              'Sorry! we do not offer home delivery service',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                    Divider(
                      height: 2,
                      color: Colors.grey,
                    ),
                    ListTile(
                      onTap: () {
                        stage = 'OVERVIEW';
                        mode = 'Pickup';
                        order = order.update(
                          orderMode: OrderMode(
                            mode: mode,
                          ),
                          orderCustomer: Customer(
                            customerName: widget.user.fname,
                            customerReview: '',
                            customerTelephone: _contact.text,
                          ),
                          customerID: widget.user.uid,
                          orderETA: PickupETA(),
                        );
                        deliveryETA(0, 'Pickup', 0.0, 0, 0.0);
                        setState(() {});
                      },
                      leading: CircleAvatar(
                        child: Image.asset('assets/images/pickup.jpg'),
                        radius: 30,
                        backgroundColor: Colors.white,
                      ),
                      title: Text(
                        'PickUp',
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.03),
                      ),
                      subtitle:
                          Text('Choose this if you want to pickup your order.'),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                    Divider(
                      height: 2,
                      color: Colors.grey,
                    ),
                  ],
                )
              : ['Restuarant', 'Eatry', 'Bar']
                      .contains(widget.merchant.bCategory)
                  ? Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 2))),
                          child: Text(
                            'How do you want it?',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.03),
                          ),
                        ),
                        Divider(
                          height: 2,
                          color: Colors.grey,
                        ),
                        ListTile(
                          onTap: () {
                            stage = 'OVERVIEW';
                            mode = 'TakeAway';
                            order = order.update(
                              orderMode: OrderMode(
                                mode: mode,
                              ),
                              orderCustomer: Customer(
                                customerName: widget.user.fname,
                                customerReview: '',
                                customerTelephone: _contact.text,
                              ),
                              customerID: widget.user.uid,
                            );
                            deliveryETA(0, 'TakeAway', 120.0, 5, 180.0);
                            setState(() {});
                          },
                          leading: CircleAvatar(
                            child: Image.asset('assets/images/take-away.jpg'),
                            radius: 30,
                            backgroundColor: Colors.white,
                          ),
                          title: Text(
                            'Take Away',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.03),
                          ),
                          subtitle: Text(
                              'Choose this if you do not want to take your order away.'),
                          trailing: IconButton(
                            icon: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                        Divider(
                          height: 2,
                          color: Colors.grey,
                        ),
                        ListTile(
                          onTap: () {
                            if (_tableformKey.currentState.validate()) {
                              stage = 'OVERVIEW';
                              mode = 'ServeMe';
                              order = order.update(
                                orderMode: OrderMode(
                                    mode: mode, tableNumber: _table.text),
                                orderCustomer: Customer(
                                  customerName: widget.user.fname,
                                  customerReview: '',
                                  customerTelephone: _contact.text,
                                ),
                                customerID: widget.user.uid,
                              );
                              deliveryETA(0, 'TakeAway', 120.0, 5, 180.0);
                              setState(() {});
                            }
                          },
                          leading: CircleAvatar(
                            child: Image.asset('assets/images/serve.jpg'),
                            radius: 30,
                            backgroundColor: Colors.white,
                          ),
                          title: Text(
                            'Serve Me',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.03),
                          ),
                          subtitle: Column(
                            children: <Widget>[
                              Text(
                                  'Choose this if you want to have you order here.'),
                              Form(
                                key: _tableformKey,
                                child: TextFormField(
                                  controller: _table,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Your table number';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.fastfood),
                                    hintText: 'Enter Table Number',
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
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  autovalidate: table,
                                  onChanged: (value) {
                                    setState(() {
                                      table = true;
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                        Divider(
                          height: 2,
                          color: Colors.grey,
                        ),
                      ],
                    )
                  : ListTile(
                      onTap: () {
                        stage = 'OVERVIEW';
                        mode = 'Pickup';
                        order = order.update(
                          orderMode: OrderMode(
                            mode: mode,
                          ),
                          orderCustomer: Customer(
                            customerName: widget.user.fname,
                            customerReview: '',
                            customerTelephone: _contact.text,
                          ),
                          customerID: widget.user.uid,
                          orderETA: PickupETA(),
                        );
                        deliveryETA(0, 'Pickup', 0.0, 0, 0.0);
                        setState(() {});
                      },
                      leading: CircleAvatar(
                        child: Image.asset('assets/images/pickup.jpg'),
                        radius: 30,
                        backgroundColor: Colors.white,
                      ),
                      title: Text(
                        'Buy Now',
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.03),
                      ),
                      subtitle:
                          Text('Choose this if you want to buy this item.'),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
        ],
      ),
    );
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
            setState(() {
              stage = 'ORDERNOW';
            });
            Get.off(OrderTrackerWidget(
              order: order,
              user: widget.user,
            ));
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  double sum(List<dynamic> items) {
    double sum = 0;
    items.forEach((element) {
      sum += element.total;
    });
    return sum;
  }

  Widget UploadingOrder() {
    return !paydone
        ? Center(
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.18,
                      child: JumpingDotsProgressIndicator(
                        fontSize: MediaQuery.of(context).size.height * 0.12,
                        color: PRIMARYCOLOR,
                      )),
                  Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Placing Order please wait..',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.025),
                          textAlign: TextAlign.center,
                        )),
                  ),
                ],
              ),
            ),
          )
        : Container(
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
                          Text(
                            'Order successfully placed',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.04),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '${_start}s',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.05),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          );
  }

  Future<bool> _willPopScope() async {
    switch (stage) {
      case 'ORDERNOW':
        Navigator.pop(context);
        return true;
        break;
      case 'FAROPTION':
        setState(() {
          screenHeight = 0.6;
          stage = 'ORDERNOW';
        });
        return false;
        break;
      case 'OVERVIEW':
        setState(() {
          screenHeight = 0.8;
          stage = 'FAROPTION';
        });
        return false;
        break;
      case 'CHECKOUT':
        setState(() {
          screenHeight = 0.8;
          stage = 'OVERVIEW';
        });
        return false;
        break;
      case 'PAY':
        return false;
        break;
      case 'PAYCARD':
        setState(() {
          screenHeight = 0.8;
          stage = 'CHECKOUT';
        });
        return false;
        break;
      case 'ERROR':
        setState(() {
          screenHeight = 0.8;
          stage = 'CHECKOUT';
        });
        return false;
        break;
      case 'TRACKER':
        Navigator.pop(context);
        return true;
        break;

      default:
        return false;
        break;
    }
  }
}
