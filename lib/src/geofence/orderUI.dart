import 'dart:async';
import 'dart:convert';

import 'package:ant_icons/ant_icons.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:geocoder/geocoder.dart' as geocode;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loadmore/loadmore.dart';
import 'package:location/location.dart' as loc;
import 'package:pocketshopping/src/admin/product/product.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/channels/repository/channelObj.dart';
import 'package:pocketshopping/src/channels/repository/channelRepo.dart';
import 'package:pocketshopping/src/geofence/repository/fenceRepo.dart';
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
import 'package:pocketshopping/src/order/tracker/customer/cdTracker.dart';
import 'package:pocketshopping/src/payment/atmCard.dart';
import 'package:pocketshopping/src/payment/topup.dart';
import 'package:pocketshopping/src/pin/repository/pinRepo.dart';
import 'package:pocketshopping/src/profile/pinSetter.dart';
import 'package:pocketshopping/src/profile/pinTester.dart';
import 'package:pocketshopping/src/review/repository/ReviewRepo.dart';
import 'package:pocketshopping/src/review/repository/rating.dart';
import 'package:pocketshopping/src/statistic/agentStatistic/deliveryRequest.dart';
import 'package:pocketshopping/src/statistic/repository.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/fav/repository/favObj.dart';
import 'package:pocketshopping/src/user/fav/repository/favRepo.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
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
  final FirebaseMessaging _fcm = FirebaseMessaging();

  int orderCount;
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
  bool scrollable;
  double formHeight;
  int _start = 5;
  Timer _timer;
  Order order;
  Stream<LocalNotification> _notificationsStream;
  double dETA;
  int dCut;
  //String eta;

  Channels channel;
  Stream<Wallet> _walletStream;
  Wallet _wallet;
  String type;
  bool emptyAgent;
  String payerror;
  String agentDevice;
  final isLogged = ValueNotifier<bool>(false);
  String randomKey;

  List<Merchant> logisticList;
  Favourite favourite;
  List<Merchant> subList;

  @override
  void initState() {
    randomKey = randomAlphaNumeric(10);
    agentDevice = "";
    payerror = "";
    emptyAgent = false;
    type = 'MotorBike';
    dCut = 0;
    dETA = 0.0;
    order = Order(orderMerchant: widget.merchant.mID);
    formHeight = 0.0;
    scrollable = true;
    contact = false;
    mobile = false;
    deliveryAddress = '';
    orderCount = 1;
    screenHeight = 0.8;
    dist = widget.distance * 1000;
    table = false;
    stage = 'ORDERNOW';
    homeDelivery = false;
    mode = '';
    paydone = false;
    position = widget.initPosition;
    userChange = false;
    //Utility.getState(position).then((value) => print(value));
    location = new loc.Location();
    location.changeSettings(
        accuracy: loc.LocationAccuracy.high, interval: 120000);
    geoStream =
        location.onLocationChanged.listen((loc.LocationData cLoc) async {
      position = Position(
          latitude: cLoc.latitude,
          longitude: cLoc.longitude,
          altitude: cLoc.altitude,
          accuracy: cLoc.accuracy);
      dist = distanceBetween(
          cLoc.latitude,
          cLoc.longitude,
          widget.merchant.bGeoPoint['geopoint'].latitude,
          widget.merchant.bGeoPoint['geopoint'].longitude);

      await address(Position(
          latitude: cLoc.latitude,
          longitude: cLoc.longitude,
          altitude: cLoc.altitude,
          accuracy: cLoc.accuracy));
      if (mounted) setState(() {});
    });
    WalletRepo.getWallet(widget.user.walletId)
        .then((value) => WalletBloc.instance.newWallet(value));
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if (mounted) {
        _wallet = wallet;
        setState(() {});
      }
    });
    address(widget.initPosition).then((value) => null);
    if (!widget.merchant.adminUploaded)
      ChannelRepo.get(widget.merchant.mID).then((value) => channel = value);
    FenceRepo.nearByLogistic(
            Position(
                latitude: widget.merchant.bGeoPoint['geopoint'].latitude,
                longitude: widget.merchant.bGeoPoint['geopoint'].longitude),
            null,
            onlyLogistic: false)
        .then((value){
          logisticList = value;
          subList = logisticList.where((element) => (element.vanCount > 0 || element.bikeCount>0 || element.carCount>0)&&(element.bStatus == 1 &&
              Utility.isOperational(
                  element.bOpen,
                  element.bClose))).toList(growable: false);
        });
    FavRepo.getFavourites(widget.user.uid, 'count', category: 'logistic')
        .then((value) => favourite = value);

    super.initState();
  }

  Future<void> address(Position position) async {
    try {
      final coordinates =
          geocode.Coordinates(position.latitude, position.longitude);
      var address = await geocode.Geocoder.local
          .findAddressesFromCoordinates(coordinates);
      List<String> temp = address.first.addressLine.split(',');
      temp.removeLast();
      deliveryAddress = temp.reduce((value, element) => value + ',' + element);
    } catch (_) {
      deliveryAddress = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopScope,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: Container(
              height: Get.height,
              width: Get.width,
              color: Colors.transparent,
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      height: Get.height * screenHeight,
                      width: Get.width,
                      //
                      child: Column(
                        children: [Expanded(child: stages())],
                      ))))),
    );
  }

  Widget cardPage() {
    setState(() {
      scrollable = false;
      screenHeight = 1;
    });
    return ATMCard(onPressed: (Map<String, dynamic> details) {
      setState(() {
        stage = "PAY";
      });
      processPay('CARD', details);
    });
  }

  int deliveryCut(double distance) {
    try {
      CloudFunctions.instance
          .getHttpsCallable(
        functionName: "DeliveryCut",
      )
          .call({'distance': distance}).then((value) => mounted
              ? setState(() {
                  dCut = (value.data +
                      ((order.orderItem.fold(
                              0,
                              (previousValue, element) =>
                                  previousValue + element.count) as int) *
                          50));
                })
              : null);
      return 1;
    } catch (_) {
      return 0;
    }
  }

  double deliveryETA(
      double distance, String type, double ttc, int server, double top) {
    try {
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
      }).then((value) => {
                if (mounted)
                  setState(() {
                    dETA = value.data * 1.0;
                  })
              });
      return 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  Widget detailMaker() {
    switch (mode) {
      case 'Delivery':
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Expanded(
                    child: const Text('Item Total'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('$CURRENCY${order.orderAmount}'),
                    ),
                  )
                ],
              ),
              Divider(
                height: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Expanded(
                    child: const Text('Delivery Fee'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('$CURRENCY$dCut'),
                    ),
                  )
                ],
              ),
              Divider(
                height: 2,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$CURRENCY${dCut + order.orderAmount}',
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
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: const Text('Mode'),
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
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Expanded(
                    child: const Text('Mobile Telephone'),
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
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Expanded(
                    child: const Text('Delivery Address'),
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
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Expanded(
                    child: Text('Delivery Time'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                          '~ ${(((dETA / 60).round()) + 5) < 30 ? 30 : (((dETA / 60).round()) + 5)} minute'),
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
                  const Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$CURRENCY${order.orderAmount}',
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
                  const Expanded(
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
                  const Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$CURRENCY${order.orderAmount}',
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
                  const Expanded(
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
                  const Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$CURRENCY${order.orderAmount}',
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
                  const Expanded(
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
                  const Expanded(
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
      default:
        return const SizedBox.shrink();
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

  inHouseETA(double distance) {}

  List<Widget> itemMaker(dynamic payload) {
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
                              ' ${payload[index].item.pName} @ $CURRENCY${payload[index].item.pPrice}'),
                        ),
                        Expanded(
                          child: Center(
                            child: Text('${payload[index].count}'),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text('$CURRENCY${payload[index].total}'),
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
                    child:
                        Text(' ${payload.pName} @ $CURRENCY${payload.pPrice}'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('$orderCount'),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('$CURRENCY${payload.pPrice * orderCount}'),
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

/*  Widget orderRequest() {
    return Container(
      child: Column(
        children: <Widget>[
          Center(
            child: TimerWidget(
              seconds: (mode == 'Delivery')||(mode == 'Pickup')?60:15,
              onFinish: (String accepted,String device) {
                if (mode == 'Delivery')
                  order = order.update(
                      orderMode: OrderMode(
                        mode: mode,
                        coordinate: GeoPoint(position.latitude, position.longitude),
                        address: _address.text,
                        acceptedBy: accepted,
                        fee: dCut,

                      ),
                      orderETA: dETA.round(),
                      orderConfirmation: Confirmation(
                      isConfirmed: false,
                      confirmOTP: randomAlphaNumeric(6),
                    ),
                    agent:accepted,
                  );
                stage = 'CHECKOUT';
                agentDevice = device;
                setState(() {});
              },
              onAgent: mode == 'Delivery'? nearByAgent : null,
              onMerchant: mode == 'Pickup'?queryMerchant:null,
              mode: mode,
            ),
          )
        ],
      ),
    );
  }*/

  Widget payDone() {
    return paydone
        ? Container(
            height: Get.height * 0.8,
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
                            style: TextStyle(fontSize: Get.height * 0.04),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '${_start}s',
                            style: TextStyle(fontSize: Get.height * 0.05),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          )
        : Container(
            height: Get.height * 0.8,
            child: Center(
              child: JumpingDotsProgressIndicator(
                fontSize: Get.height * 0.12,
                color: PRIMARYCOLOR,
              ),
            ),
          );
  }

  Widget payError() {
    return Center(
      child: Container(
        alignment: Alignment.center,
        width: Get.width,
        height: Get.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: Get.width * 0.3,
              height: Get.height * 0.18,
              child: Icon(
                Icons.close,
                color: Colors.red,
                size: Get.height * 0.18,
              ),
            ),
            Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Text(
                        '$payerror',
                        style: TextStyle(fontSize: Get.height * 0.025),
                        textAlign: TextAlign.center,
                      ))),
            ),
            Center(
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    screenHeight = 0.8;
                    stage = 'CHECKOUT';
                  });
                },
                color: PRIMARYCOLOR,
                child: const Text(
                  'Try Again',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  int pickupETA() {
    int eta = 360;
    CloudFunctions.instance
        .getHttpsCallable(
          functionName: "pickupETA",
        )
        .call()
        .then((value) => eta = value.data);
    return eta;
  }

  processPay(String method, Map<String, dynamic> details) async {
    setState(() {
      screenHeight = 1;
    });
    Map<String, String> reference;
    details['email'] = widget.user.email;
    //Agent agent = await LogisticRepo.getOneAgentByUid(order.agent);
    //User agentAccount = await UserRepo.getOneUsingUID(agent.agent);
    var temp = details['expiry'].toString().split('/');

    switch (method) {
      case 'CARD':
        reference = Map.from(await Utility.platform.invokeMethod(
            'CardPay',
            Map.from({
              "card": (details['card'] as String),
              "cvv": (details['cvv'] as String),
              "month": int.parse(temp[0]),
              "year": int.parse(temp[1]),
              "amount": ((dCut + order.orderAmount).round() +
                  Utility.onePointFive((dCut + order.orderAmount).round())),
              "email": (details['email'] as String),
            })));
        if (reference.isNotEmpty) {
          var details =
              await Utility.fetchPaymentDetail(reference['reference']);
          var status = jsonDecode(details.body)['data']['status'];

          if (status == 'success') {
            setState(() {
              screenHeight = 0.8;
              stage = 'UPLOADING';
              paydone = false;
            });
            var collectId = await Utility.initializePay(
                deliveryFee: order.orderMode.fee.round(),
                channelId: 1,
                referenceID: reference['reference'],
                amount: order.orderAmount.round(),
                from: widget.user.walletId,
                state: await Utility.getState(position));
            if (collectId != null)
              setState(() {
                order = order.update(
                  receipt: Receipt(
                    reference: reference['reference'],
                    psStatus: 'PENDING',
                    type: method,
                    collectionID: collectId,
                  ),
                  orderCreatedAt: Timestamp.now(),
                  status: 0,
                  orderID: '',
                  docID: '',
                );
              });
            else
              setState(() {
                screenHeight = 0.8;
                stage = 'ERROR';
                payerror = "Error encountered while placing Order.";
              });
            if (collectId != null) {
              OrderRepo.save(order).then((value) => setState(() {
                    startTimer();
                    order = order.update(docID: value);
                    paydone = true;
                  }));
              WalletRepo.getWallet(widget.user.walletId)
                  .then((value) => WalletBloc.instance.newWallet(value));

              if (mode == 'Delivery') await queryAgent();
            }
          } else {
            //print('Important!!! $reference');
            if (reference['error'].toString().isNotEmpty) {
              setState(() {
                screenHeight = 0.8;
                stage = 'ERROR';
                payerror = reference['error'].toString();
              });
            } else {
              setState(() {
                screenHeight = 0.8;
                stage = 'CHECKOUT';
              });
            }
          }
        } else {
          setState(() {
            screenHeight = 0.8;
            stage = 'CHECKOUT';
          });
        }
        break;
      case 'CASH':
        setState(() {
          screenHeight = 0.8;
          stage = 'UPLOADING';
          paydone = false;
        });
        var collectId = await Utility.initializePay(
            deliveryFee: order.orderMode.fee.round(),
            channelId: 2,
            referenceID: "",
            amount: order.orderAmount.round(),
            from: widget.user.walletId,
            state: await Utility.getState(position));
        if (collectId != null)
          setState(() {
            order = order.update(
              receipt: Receipt(
                reference: '',
                psStatus: 'PENDING',
                type: method,
                collectionID: collectId,
              ),
              orderCreatedAt: Timestamp.now(),
              status: 0,
              orderID: '',
              docID: '',
              //orderLogistic: '',
            );
          });
        else
          setState(() {
            screenHeight = 0.8;
            stage = 'ERROR';
            payerror = "Error encountered while placing Order.";
          });
        if (collectId != null) {
          OrderRepo.save(order).then((value) => setState(() {
                startTimer();
                order = order.update(docID: value);
                paydone = true;
              }));
          WalletRepo.getWallet(widget.user.walletId)
              .then((value) => WalletBloc.instance.newWallet(value));
          if (mode == 'Delivery') await queryAgent();
        }
        break;
      case 'POCKET':
        setState(() {
          screenHeight = 0.8;
          stage = 'UPLOADING';
          paydone = false;
        });
        var collectId = await Utility.initializePay(
            deliveryFee: order.orderMode.fee.round(),
            channelId: 3,
            referenceID: "",
            amount: order.orderAmount.round(),
            from: widget.user.walletId,
            state: await Utility.getState(position));
        if (collectId != null) {
          setState(() {
            order = order.update(
              receipt: Receipt(
                reference: '',
                psStatus: 'PENDING',
                type: method,
                collectionID: collectId,
              ),
              orderCreatedAt: Timestamp.now(),
              status: 0,
              orderID: '',
              docID: '',
              //orderLogistic: '',
            );
          });
        } else
          setState(() {
            screenHeight = 0.8;
            stage = 'ERROR';
            payerror = "Error encountered while placing Order.";
          });
        if (collectId != null) {
          OrderRepo.save(order).then((value) => setState(() {
                startTimer();
                order = order.update(docID: value);
                paydone = true;
              }));
          WalletRepo.getWallet(widget.user.walletId)
              .then((value) => WalletBloc.instance.newWallet(value));

          if (mode == 'Delivery') await queryAgent();
        }
        break;
    }

    FavRepo.save(widget.user.uid, widget.merchant.mID, 'merchant');
    if (order.orderLogistic.isNotEmpty)
      FavRepo.save(widget.user.uid, order.orderLogistic, 'logistic');
    //});
  }

  Future<List<String>> nearByAgent({bool isDevice = false}) async {
    var nearbyAgent = await LogisticRepo.getNearByAgent(
        Position(
            latitude: widget.merchant.bGeoPoint['geopoint'].latitude,
            longitude: widget.merchant.bGeoPoint['geopoint'].longitude),
        type,
        isDevice: isDevice);
    return nearbyAgent;
  }

  Future<void> queryAgent() async {
    await Utility.pushGroupNotifier(
      fcm: await nearByAgent(isDevice: true),
      body: 'New Delivery Request, view request bucket for details',
      title: 'New Delivery',
      notificationType: 'NewDeliveryRequestInBucket',
    );
  }

  Future<void> queryMerchant() async {
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
                            'productCount': orderCount
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
              if (_wallet == null)
                Center(
                  child: Text(
                    'Error communicating with server. Check internet and try again',
                    style: TextStyle(
                      fontSize: Get.height * 0.025,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              _wallet != null
                  ? Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        'Proceed with method of payment to complete order',
                        style: TextStyle(
                          fontSize: Get.height * 0.025,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink(),
              _wallet != null
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        'Pay With',
                        style: TextStyle(fontSize: Get.height * 0.03),
                      ),
                    )
                  : const SizedBox.shrink(),
              _wallet != null
                  ? ListTile(
                      onTap: () async {
                        if (_wallet.walletBalance >
                            (order.orderAmount + order.orderMode.fee)) {
                          bool set = await PinRepo.isSet(widget.user.walletId);
                          if (set)
                            Get.dialog(PinTester(
                              wallet: widget.user.walletId,
                              callBackAction: () async {
                                setState(() {
                                  stage = 'PAY';
                                });
                                await processPay('POCKET', {});
                              },
                            ));
                          else {
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
                                  onPressed: () async {
                                    Get.back();
                                    Get.dialog(PinSetter(
                                      user: widget.user,
                                      callBackAction: () async {
                                        setState(() {
                                          stage = 'PAY';
                                        });
                                        await processPay('POCKET', {});
                                      },
                                    ));
                                  },
                                  child: Text('Setup PIN'),
                                ));
                          }
                        } else {
                          Get.defaultDialog(
                              title: 'TopUp',
                              content: const Text(
                                  'Do you want to TopUp your Pocket'),
                              cancel: FlatButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text('No'),
                              ),
                              confirm: FlatButton(
                                onPressed: () {
                                  Get.back();
                                  Get.dialog(TopUp(
                                    user: widget.user,
                                  ));
                                  //setState(() {
                                  // stage = 'PAY';
                                  // });
                                },
                                child: Text('Yes'),
                              ));
                        }
                      },
                      leading: CircleAvatar(
                        child: Image.asset('assets/images/blogo.png'),
                        radius: 30,
                        backgroundColor: Colors.white,
                      ),
                      title: Text(
                        'Pocketshopping',
                        style: TextStyle(fontSize: Get.height * 0.025),
                      ),
                      subtitle: Column(
                        children: <Widget>[
                          _wallet.walletBalance >
                                  (order.orderAmount + order.orderMode.fee)
                              ? Text(
                                  'Choose this if you want to pay with pocket.')
                              : Text('Insufficient Fund. Tap to Topup'),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_forward_ios),
                      ),
                    )
                  : const SizedBox.shrink(),
              const Divider(
                height: 2,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 5,
              ),
              _wallet != null
                  ? ListTile(
                      onTap: () async {
                        //await processPay('CARD');
                        Get.defaultDialog(
                            title: 'Confirmation',
                            content: Text(
                                'Please Note that the agent will not be credited until you confirm the order. In a case where agent fails to deliver your pocketshopping account will be credited with the money.'),
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
                        style: TextStyle(fontSize: Get.height * 0.025),
                      ),
                      subtitle: const Text(
                          'Choose this if you want to pay with ATM Card(instant payment).'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    )
                  : const SizedBox.shrink(),
              const Divider(
                height: 2,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 5,
              ),
              _wallet != null
                  ? ListTile(
                      onTap: () async {
                        //await processPay('CASH');
                        Get.defaultDialog(
                            title: 'Confirmation',
                            content: const Text(
                                'Do not hand cash over, without getting your order/purchase delivered pocketshopping will not be held responsible in such situation.'),
                            cancel: FlatButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text('Cancel'),
                            ),
                            confirm: FlatButton(
                              onPressed: () async {
                                Get.back();
                                setState(() {
                                  stage = 'PAY';
                                });
                                await processPay('CASH', {});
                              },
                              child: Text('Ok'),
                            ));
                      },
                      leading: CircleAvatar(
                        child: Image.asset('assets/images/cash.png'),
                        radius: 30,
                        backgroundColor: Colors.white,
                      ),
                      title: Text(
                        mode == 'Delivery' ? 'pay on Delivery' : 'Cash',
                        style: TextStyle(fontSize: Get.height * 0.025),
                      ),
                      subtitle: Text(mode == 'Delivery'
                          ? 'Choose this if you want to pay on delivery.'
                          : 'Choose this if you want to pay with cash.'),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {},
                      ),
                    )
                  : const SizedBox.shrink(),
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
              height: Get.height * 0.4,
              width: Get.width,
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
            style: TextStyle(
                fontSize: Get.height * 0.025, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            '@ $CURRENCY ${widget.payload.pPrice.toString()}',
            style: TextStyle(fontSize: Get.height * 0.025),
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
                            if (orderCount > 1) orderCount -= 1;
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
                          '$orderCount ${widget.payload.pUnit.toString()}'),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if ((widget.payload as Product).isManaging) {
                            if ((widget.payload as Product).pStockCount >
                                orderCount) orderCount += 1;
                          } else {
                            orderCount += 1;
                          }
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
                                count: orderCount,
                                item: widget.payload,
                                total: widget.payload.pPrice * orderCount)
                          ]),
                          orderAmount: widget.payload.pPrice * orderCount);
                      stage = 'FAROPTION';
                      _address.text = deliveryAddress;
                      _contact.text = widget.user.telephone;
                      screenHeight = 0.8;
                    });
                    deliveryETA(dist != null ? dist : widget.distance * 1000,
                        'Delivery', 0.0, 0, 0.0);
                    deliveryCut(dist != null ? dist : widget.distance * 1000);
                  },
                  child: Text(
                    'Next ($CURRENCY ${widget.payload.pPrice * orderCount})',
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
      height: Get.height * 0.8,
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
                                  '${widget.payload[index].item.pName} @ $CURRENCY'
                                  '${widget.payload[index].item.pPrice}',
                                  style:
                                      TextStyle(fontSize: Get.height * 0.025),
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
                                            if ((widget.payload[index].item
                                                    as Product)
                                                .isManaging) {
                                              if ((widget.payload[index].item
                                                          as Product)
                                                      .pStockCount >
                                                  widget.payload[index].count) {
                                                widget.payload[index].count +=
                                                    1;
                                                widget.payload[index].total =
                                                    widget.payload[index]
                                                            .count *
                                                        widget.payload[index]
                                                            .item.pPrice;
                                              }
                                            } else {
                                              widget.payload[index].count += 1;
                                              widget.payload[index].total =
                                                  widget.payload[index].count *
                                                      widget.payload[index].item
                                                          .pPrice;
                                            }
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
                          orderAmount: Utility.sum(widget.payload));
                      stage = 'FAROPTION';
                      _address.text = deliveryAddress;
                      _contact.text = widget.user.telephone;
                      screenHeight = 0.8;
                    });
                    deliveryETA(dist != null ? dist : widget.distance * 1000,
                        'Delivery', 0.0, 0, 0.0);
                    deliveryCut(dist != null ? dist : widget.distance * 1000);
                  },
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
      case 'LOGISTIC':
        return stageLogistic();
        break;
      case 'CHECKOUT':
        return stageFour();
        break;
      case 'PAY':
        return payDone();
        break;
      case 'PAYCARD':
        return cardPage();
        break;
      //case 'REQUEST':
      //return orderRequest();
      //break;
      case 'ERROR':
        return payError();
        break;
      case 'UPLOADING':
        return uploadingOrder();
        break;

      default:
        return stageOne();
        break;
    }
  }

  Widget stageThree() {
    //print(order.orderMode.address);
    return Container(
      height: Get.height * 0.8,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: IconButton(
                  onPressed: () {
                    stage = 'LOGISTIC';
                    screenHeight = 0.9;
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
              style: TextStyle(fontSize: Get.height * 0.03),
            ),
          ),
          Container(
              height: Get.height * 0.55,
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
                              fontSize: Get.height * 0.025,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Divider(
                      height: 2,
                      color: Colors.grey,
                    ),
                    Column(
                      children: itemMaker(widget.payload),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Details(s)',
                          style: TextStyle(
                              fontSize: Get.height * 0.025,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Divider(
                      height: 2,
                      color: Colors.grey,
                    ),
                    detailMaker()
                  ],
                ),
              )),
          Expanded(
            child: Container(
                width: Get.width,
                color: PRIMARYCOLOR,
                child: Center(
                  child: FlatButton(
                    onPressed: () async {
                      order = order.update(
                        orderMode: OrderMode(
                          mode: mode,
                          coordinate:
                              GeoPoint(position.latitude, position.longitude),
                          address: _address.text,
                          acceptedBy: '',
                          fee: dCut,
                          deliveryMan: '',
                          tableNumber: '',
                        ),
                        orderETA: order.orderLogistic.isEmpty
                            ? (dETA.round() + 300) < 1800
                                ? 1800
                                : (dETA.round() + 300)
                            : ((dETA.round() + 300) < 1800
                                ? 1800
                                : (dETA.round() + 300) + 1800),
                        orderConfirmation: Confirmation(
                          isConfirmed: false,
                          confirmOTP: randomAlphaNumeric(6),
                        ),
                        agent: '',
                        resolution: '',
                        isAssigned: false,

                        status: 0,
                        orderID: '',
                        docID: '',
                        //orderLogistic:'',
                      );
                      if (dCut > 250 && dETA > 5) {
                        stage = 'CHECKOUT';
                        setState(() {});
                      }
                    },
                    child: Text(
                      (dCut > 250 && dETA > 5)
                          ? 'Checkout ( $CURRENCY ${order.orderAmount + dCut} )'
                          : 'Please wait...',
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
    //setState(() {
    //screenHeight = 0.8;
    //});
    return Container(
      child: ListView(
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
                    Get.back();
                  },
                  icon: Icon(Icons.close),
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              /*Container(
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 2))),
                      child: Text(
                        'Delivery Details',
                        style: TextStyle(
                            fontSize: Get.height * 0.03),
                      ),
                    ),
                    Divider(
                      height: 2,
                      color: Colors.grey,
                    ),*/
              ListTile(
                onTap: () {
                  /*_address.text = deliveryAddress;
                              _contact.text = widget.user.telephone;

                              if (homeDelivery){
                                  screenHeight = 0.8;
                                  homeDelivery = false;
                              }else{
                                screenHeight = 1;
                                homeDelivery = true;
                              }

                              if (mounted) setState(() {});
                              deliveryETA(dist != null ? dist : widget.distance * 1000, 'Delivery', 0.0, 0, 0.0);
                              deliveryCut(dist != null ? dist : widget.distance * 1000);*/
                },
                leading: CircleAvatar(
                  child: Image.asset('assets/images/delivery-man.jpg'),
                  radius: 30,
                  backgroundColor: Colors.white,
                ),
                title: Text(
                  'Delivery',
                  style: TextStyle(fontSize: Get.height * 0.03),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Your Delivery Details'),
                    /*homeDelivery
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
                                                    labelText: 'Contact Telephone',
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
                                                    enabledBorder: UnderlineInputBorder(
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
                                                    labelText: 'Delivery Address',
                                                    filled: true,
                                                    fillColor: Colors.grey.withOpacity(0.2),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.3)),
                                                    ),
                                                    enabledBorder: UnderlineInputBorder(
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
                                                if (widget.merchant.bCategory != 'Restuarant')
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
                                                          items: ['MotorBike', 'Car', 'Van']
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
                                                            emptyAgent = false;
                                                            setState(() {});
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                SizedBox(height: 10,),
                                                if(emptyAgent != null)
                                                if(emptyAgent)
                                                const Center(
                                                  child: Text('No rider within reach... try again later',textAlign: TextAlign.center,style: TextStyle(color: Colors.red),),
                                                ),
                                                SizedBox(height: 10,),
                                                FlatButton(
                                                    onPressed: ()  {
                                                      if (_formKey.currentState
                                                          .validate()) {
                                                        setState(() {emptyAgent=null;});
                                                        LogisticRepo.getNearByAgent(
                                                            Position(
                                                                latitude: widget.merchant.bGeoPoint['geopoint'].latitude,
                                                                longitude: widget.merchant.bGeoPoint['geopoint'].longitude),
                                                            type).then((value) {
                                                              if(value.isNotEmpty){
                                                                stage = 'OVERVIEW';
                                                                mode = 'Delivery';
                                                                order = order.update(
                                                                  orderMode: OrderMode(
                                                                    mode: mode,
                                                                    coordinate: GeoPoint(
                                                                        position.latitude,
                                                                        position.longitude),
                                                                    address: _address.text,
                                                                  ),
                                                                  orderCustomer:
                                                                  Customer(
                                                                    customerName: widget
                                                                        .user.fname,
                                                                    customerReview: '',
                                                                    customerTelephone:
                                                                    _contact.text,
                                                                  ),
                                                                  customerID: widget.user.uid,
                                                                );
                                                                screenHeight = 0.8;
                                                                homeDelivery =false;
                                                                emptyAgent = false;
                                                              }
                                                              else {
                                                                emptyAgent =
                                                                true;

                                                                if (!isLogged.value) {
                                                                  StatisticRepo
                                                                      .saveDeliveryRequest(
                                                                      DeliveryRequest(
                                                                          isMiss: true,
                                                                          agent: '',
                                                                          distance: 0,
                                                                          orderId: '',
                                                                          cordinate: GeoPoint(
                                                                              (widget.merchant.bGeoPoint as Map<String, dynamic>)['geopoint']
                                                                                  .latitude,
                                                                              (widget.merchant.bGeoPoint as Map<String, dynamic>)['geopoint']
                                                                                  .longitude)
                                                                      ));
                                                                  isLogged.value = true;
                                                                }
                                                              }
                                                              //print(value);
                                                              setState(() {});
                                                        });

                                                      }
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(
                                                              vertical: 10,
                                                              horizontal: 15),
                                                      //width: Get.width,
                                                      color: PRIMARYCOLOR,
                                                      child: Center(
                                                        child: emptyAgent != null?
                                                        Text('Submit', style: TextStyle(color: Colors.white),)
                                                            :
                                                        JumpingDotsProgressIndicator(
                                                          fontSize: MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                              0.04,
                                                          color: Colors.white,
                                                        ),

                                                      )
                                                    )
                                                )
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
                                    : Container()*/
                  ],
                ),
                /*trailing: IconButton(
                              onPressed: () {
                                homeDelivery = homeDelivery ? false : true;
                                setState(() {});
                              },
                              icon: !homeDelivery
                                  ? Icon(Icons.arrow_forward_ios)
                                  : Icon(Icons.close),
                            ),*/
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: <Widget>[
                    Form(
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
                              } else if (value.length <= 11) {
                                return 'Valid Mobile number please';
                              }
                              return null;
                            },
                            controller: _contact,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.call),
                              labelText: 'Contact Telephone',
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
                              prefixIcon: Icon(Icons.place),
                              labelText: 'Delivery Address',
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
                            textInputAction: TextInputAction.done,
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
                          // if (widget.merchant.bCategory != 'Restuarant')
                          Container(
                            color: Colors.grey.withOpacity(0.2),
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Column(
                              children: <Widget>[
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Mode",
                                      style: TextStyle(color: Colors.black54),
                                    )),
                                DropdownButtonFormField<String>(
                                  value: type,
                                  items: ['MotorBike', 'Car', 'Van']
                                      .map((label) => DropdownMenuItem(
                                            child: Text(
                                              label,
                                              style: TextStyle(
                                                  color: Colors.black54),
                                            ),
                                            value: label,
                                          ))
                                      .toList(),
                                  isExpanded: true,
                                  hint: Text('Mode'),
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                  onChanged: (value) {
                                    type = value;
                                    emptyAgent = false;
                                    setState(() {});
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (emptyAgent != null)
                            if (emptyAgent)
                              const Center(
                                child: Text(
                                  'No rider within reach... Try again later',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          SizedBox(
                            height: 10,
                          ),
                          FlatButton(
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    emptyAgent = null;
                                    stage = 'LOGISTIC';
                                    screenHeight = 0.9;
                                    scrollable = false;
                                  });

                                  /*LogisticRepo.getNearByAgent(
                                            Position(latitude: widget.merchant.bGeoPoint['geopoint'].latitude,
                                                longitude: widget.merchant.bGeoPoint['geopoint'].longitude), type).then((value) {
                                          if(value.isNotEmpty){
                                            stage = 'OVERVIEW';
                                            mode = 'Delivery';
                                            order = order.update(
                                              orderMode: OrderMode(
                                                mode: mode,
                                                coordinate: GeoPoint(
                                                    position.latitude,
                                                    position.longitude),
                                                address: _address.text,
                                              ),
                                              orderCustomer:
                                              Customer(
                                                customerName: widget
                                                    .user.fname,
                                                customerReview: '',
                                                customerTelephone:
                                                _contact.text,
                                              ),
                                              customerID: widget.user.uid,
                                            );
                                            screenHeight = 0.8;
                                            homeDelivery =false;
                                            emptyAgent = false;
                                          }
                                          else {
                                            emptyAgent = true;

                                            if (!isLogged.value) {
                                              StatisticRepo
                                                  .saveDeliveryRequest(
                                                  DeliveryRequest(
                                                      isMiss: true,
                                                      agent: '',
                                                      distance: 0,
                                                      orderId: '',
                                                      cordinate: GeoPoint(
                                                          (widget.merchant.bGeoPoint as Map<String, dynamic>)['geopoint'].latitude,
                                                          (widget.merchant.bGeoPoint as Map<String, dynamic>)['geopoint'].longitude)
                                                  ));
                                              isLogged.value = true;
                                            }
                                          }
                                          //print(value);
                                          setState(() {});
                                        });*/

                                }
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  //width: Get.width,
                                  color: PRIMARYCOLOR,
                                  child: Center(
                                      child: Text(
                                    'Submit',
                                    style: TextStyle(color: Colors.white),
                                  ))))
                        ],
                      ),
                    )
                  ],
                ),
              ),

              /*Divider(
                      height: 2,
                      color: Colors.grey,
                    ),*/
              /*ListTile(
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
                          orderETA: pickupETA(),
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
                            Get.height * 0.03),
                      ),
                      subtitle: !widget.merchant.adminUploaded?Text('Unavailable',style: TextStyle(color: Colors.red),)
                          :
                      Text('Unavailable',style: TextStyle(color: Colors.red),),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward_ios), onPressed: () {  },
                      ),
                      enabled: false,
                    )*/
              /*ListTile(
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
                          orderETA: pickupETA(),
                        );
                        deliveryETA(0, 'Pickup', 0.0, 0, 120.0);
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
                                Get.height * 0.03),
                      ),
                      subtitle: !widget.merchant.adminUploaded?Text('Choose this if you want to pickup your order.')
                          :
                      Text('service unavailable',style: TextStyle(color: Colors.red),),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward_ios), onPressed: () {  },
                      ),
                      enabled:!widget.merchant.adminUploaded ,
                    )*/
              /*Divider(
                      height: 2,
                      color: Colors.grey,
                    ),*/
            ],
          )
          /*: 'Restuarant' == widget.merchant.bCategory
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
                                    Get.height * 0.03),
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
                            deliveryETA(0, 'TakeAway', 120.0, 5, 60.0);
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
                                    Get.height * 0.03),
                          ),
                          subtitle: !widget.merchant.adminUploaded?
                          Text('Choose this if you do not want to take your order away.')
                          :
                          Text('service unavailable',style: TextStyle(color: Colors.red),),
                          trailing: IconButton(
                            icon: Icon(Icons.arrow_forward_ios), onPressed: () {  },
                          ),
                          enabled: !widget.merchant.adminUploaded,
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
                              deliveryETA(0, 'ServeMe', 120.0, 5, 60.0);
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
                                    Get.height * 0.03),
                          ),
                          subtitle: Column(
                            children: <Widget>[
                              !widget.merchant.adminUploaded?
                              Align(alignment: Alignment.centerLeft,child: Text('Choose this if you want to have you order here.'),)
                              :
                              Align(alignment: Alignment.centerLeft,child:Text('service unavailable',style: TextStyle(color: Colors.red),))
                              ,
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
                            icon: Icon(Icons.arrow_forward_ios), onPressed: () {  },
                          ),
                          enabled: !widget.merchant.adminUploaded,
                        ),
                        Divider(
                          height: 2,
                          color: Colors.grey,
                        ),
                      ],
                    )*/
          /*: ListTile(
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
                          orderETA: pickupETA(),
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
                                Get.height * 0.03),
                      ),
                      subtitle: !widget.merchant.adminUploaded?Text('Choose this if you want to buy this item.')
                          :
                      Text('service unavailable',style: TextStyle(color: Colors.red),),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward_ios), onPressed: () {  },
                      ),
                    enabled: !widget.merchant.adminUploaded,
                    )*/
          ,
        ],
      ),
    );
  }

  Widget stageLogistic() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: IconButton(
                onPressed: () {
                  stage = 'FAROPTION';
                  screenHeight = 0.8;
                  setState(() {});
                },
                icon: Icon(Icons.arrow_back),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Choose A Rider',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(Icons.close),
              ),
            ),
          ],
        ),
        FutureBuilder(
          future: LogisticRepo.getNearByAgent(
              Position(
                  latitude: widget.merchant.bGeoPoint['geopoint'].latitude,
                  longitude: widget.merchant.bGeoPoint['geopoint'].longitude),
              type,
              isDevice: false),
          initialData: <String>[],
          builder: (context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.isEmpty) {
                if (!isLogged.value) {
                  StatisticRepo.saveDeliveryRequest(DeliveryRequest(
                      isMiss: true,
                      agent: '',
                      distance: 0,
                      orderId: '',
                      cordinate: GeoPoint(
                          (widget.merchant.bGeoPoint
                                  as Map<String, dynamic>)['geopoint']
                              .latitude,
                          (widget.merchant.bGeoPoint
                                  as Map<String, dynamic>)['geopoint']
                              .longitude)));
                  isLogged.value = true;
                }
              }
            }
            return ListTile(
                onTap: () {

                  if (snapshot.hasData) {
                    if (snapshot.data.isNotEmpty || subList.isNotEmpty) {
                      List<String> _potentials = snapshot.data;
                      _potentials.addAll(subList.map((e) => e.mID));
                      stage = 'OVERVIEW';
                      mode = 'Delivery';
                      order = order.update(
                        orderMode: OrderMode(
                          mode: mode,
                          coordinate:
                              GeoPoint(position.latitude, position.longitude),
                          address: _address.text,
                        ),
                        orderCustomer: Customer(
                          customerName: widget.user.fname,
                          customerReview: '',
                          customerTelephone: _contact.text,
                        ),
                        potentials: _potentials ?? [],
                        customerID: widget.user.uid,
                        orderLogistic: '',
                        auto: type,
                      );
                      screenHeight = 0.8;
                      setState(() {});
                    } else {
                      Utility.infoDialogMaker('Unavailable', title: '');
                    }
                  }
                },
                leading: CircleAvatar(
                  child: Icon(Icons.computer),
                  radius: 30,
                  backgroundColor: Colors.white,
                ),
                title: Text(
                  'Automatic',
                  style: TextStyle(fontSize: Get.height * 0.03),
                ),
                subtitle: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (snapshot.connectionState == ConnectionState.waiting)
                          Text('Initializing. Please wait')
                        else if (snapshot.hasError)
                          Text('Unavailable.',
                              style: TextStyle(color: Colors.red))
                        else if (snapshot.data.isNotEmpty ||
                              subList.isNotEmpty)
                          Text(
                              'Let Pocketshopping choose a rider for you \n(${subList.length > 10 ? (snapshot.data.length + 10) : (snapshot.data.length + subList.length)} rider(s) close to ${widget.merchant.bName}).',
                              style: TextStyle(color: Colors.green))
                        else
                          Text(
                            'Unavailable.',
                            style: TextStyle(color: Colors.red),
                          )
                      ],
                    )) //,
                );
          },
        ),
        Divider(
          height: 1,
          color: Colors.grey,
        ),
        ListTile(
            onTap: () {},
            leading: CircleAvatar(
              child: Icon(AntIcons.tool),
              radius: 30,
              backgroundColor: Colors.white,
            ),
            title: Text(
              'Manual',
              style: TextStyle(fontSize: Get.height * 0.03),
            ),
            subtitle: Text(
                'Please note this method might take more time. Select from list below.') //,
            ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: TextFormField(
            controller: null,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search For Rider',
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
            onChanged: (value) async {
              if (value.isNotEmpty) {
                setState(() {
                  logisticList = null;
                  favourite = null;
                });
                logisticList = await FenceRepo.searchNearByLogistic(
                  Position(
                      latitude: widget.merchant.bGeoPoint['geopoint'].latitude,
                      longitude:
                          widget.merchant.bGeoPoint['geopoint'].longitude),
                  value.toLowerCase().trim(),
                );
                setState(() {});
              } else {
                setState(() {
                  logisticList = null;
                });
                logisticList = await FenceRepo.nearByLogistic(
                    Position(
                        latitude:
                            widget.merchant.bGeoPoint['geopoint'].latitude,
                        longitude:
                            widget.merchant.bGeoPoint['geopoint'].longitude),
                    null,
                    onlyLogistic: false);
                FavRepo.getFavourites(widget.user.uid, 'count',
                        category: 'logistic')
                    .then((value) => favourite = value);
                setState(() {});
              }
            },
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
            child: ListView(
          children: [
            if (favourite != null)
              if (favourite.favourite.isNotEmpty)
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Favourite'),
                      ),
                    ),
                    Column(
                        children: List<Widget>.generate(
                            favourite.favourite.values.length, (index) {
                      return FutureBuilder(
                        future: MerchantRepo.getMerchant(favourite
                            .favourite.values
                            .toList(growable: false)[index]
                            .merchant),
                        builder: (context, AsyncSnapshot<Merchant> merchant) {
                          if (merchant.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              height: 80,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              child: ListSkeleton(
                                style: SkeletonStyle(
                                  theme: SkeletonTheme.Light,
                                  isShowAvatar: false,
                                  barCount: 3,
                                  colors: [
                                    Colors.grey.withOpacity(0.5),
                                    Colors.grey,
                                    Colors.grey.withOpacity(0.5)
                                  ],
                                  isAnimation: true,
                                ),
                              ),
                              alignment: Alignment.center,
                            );
                          } else if (merchant.hasError) {
                            return const SizedBox.shrink();
                          } else {
                            if (favourite.favourite.isNotEmpty) {
                              return Column(
                                children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5),
                                      child: ListTile(
                                        onTap: () {
                                          if (type == "MotorBike") {
                                            if (merchant.data.bikeCount > 0) {
                                              stage = 'OVERVIEW';
                                              mode = 'Delivery';
                                              order = order.update(
                                                  orderMode: OrderMode(
                                                    mode: mode,
                                                    coordinate: GeoPoint(
                                                        position.latitude,
                                                        position.longitude),
                                                    address: _address.text,
                                                  ),
                                                  orderCustomer: Customer(
                                                    customerName:
                                                        widget.user.fname,
                                                    customerReview: '',
                                                    customerTelephone:
                                                        _contact.text,
                                                  ),
                                                  customerID: widget.user.uid,
                                                  orderLogistic: merchant.data.mID,
                                                  potentials:[merchant.data.mID],
                                                  auto: 'MotorBike');
                                              screenHeight = 0.8;
                                              setState(() {});
                                            } else {
                                              Utility.infoDialogMaker(
                                                "${merchant.data.bName} does not have a delivery motorbike at the moment",
                                              );
                                            }
                                          } else if (type == "Car") {
                                            if (merchant.data.carCount > 0) {
                                              stage = 'OVERVIEW';
                                              mode = 'Delivery';
                                              order = order.update(
                                                  orderMode: OrderMode(
                                                    mode: mode,
                                                    coordinate: GeoPoint(
                                                        position.latitude,
                                                        position.longitude),
                                                    address: _address.text,
                                                  ),
                                                  orderCustomer: Customer(
                                                    customerName:
                                                        widget.user.fname,
                                                    customerReview: '',
                                                    customerTelephone:
                                                        _contact.text,
                                                  ),
                                                  customerID: widget.user.uid,
                                                  orderLogistic: merchant.data.mID,
                                                  potentials:[merchant.data.mID],
                                                  auto: 'Car');
                                              screenHeight = 0.8;
                                              setState(() {});
                                            } else {
                                              Utility.infoDialogMaker(
                                                "${merchant.data.bName} does not have a delivery car at the moment",
                                              );
                                            }
                                          } else if (type == "Van") {
                                            if (merchant.data.vanCount > 0) {
                                              stage = 'OVERVIEW';
                                              mode = 'Delivery';
                                              order = order.update(
                                                  orderMode: OrderMode(
                                                    mode: mode,
                                                    coordinate: GeoPoint(
                                                        position.latitude,
                                                        position.longitude),
                                                    address: _address.text,
                                                  ),
                                                  orderCustomer: Customer(
                                                    customerName:
                                                        widget.user.fname,
                                                    customerReview: '',
                                                    customerTelephone:
                                                        _contact.text,
                                                  ),
                                                  customerID: widget.user.uid,
                                                  orderLogistic: merchant.data.mID,
                                                  potentials:[merchant.data.mID],
                                                  auto: 'Van');
                                              screenHeight = 0.8;
                                              setState(() {});
                                            } else {
                                              Utility.infoDialogMaker(
                                                "${merchant.data.bName} does not have a delivery van at the moment",
                                              );
                                            }
                                          }
                                        },
                                        leading: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(
                                              merchant.data.bPhoto.isNotEmpty
                                                  ? merchant.data.bPhoto
                                                  : PocketShoppingDefaultCover),
                                        ),
                                        title: Text(merchant.data.bName),
                                        subtitle: Column(
                                          children: [
                                            Row(
                                              children: [
                                                FutureBuilder(
                                                  future: ReviewRepo.getRating(
                                                      merchant.data.mID),
                                                  builder: (context,
                                                      AsyncSnapshot<Rating>
                                                          snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState.waiting)
                                                      return const SizedBox
                                                          .shrink();
                                                    else if (snapshot.hasError)
                                                      return const SizedBox
                                                          .shrink();
                                                    else {
                                                      if (snapshot.hasData) {
                                                        if (snapshot.data !=
                                                            null) {
                                                          return RatingBar(
                                                            onRatingUpdate:
                                                                null,
                                                            initialRating:
                                                                snapshot.data
                                                                    .rating,
                                                            minRating: 1,
                                                            maxRating: 5,
                                                            itemSize:
                                                                Get.width *
                                                                    0.05,
                                                            direction:
                                                                Axis.horizontal,
                                                            allowHalfRating:
                                                                true,
                                                            ignoreGestures:
                                                                true,
                                                            itemCount: 5,
                                                            //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                            itemBuilder:
                                                                (context, _) =>
                                                                    Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.amber,
                                                            ),
                                                          );
                                                        } else {
                                                          return RatingBar(
                                                            onRatingUpdate:
                                                                null,
                                                            initialRating: 3,
                                                            minRating: 1,
                                                            maxRating: 5,
                                                            itemSize:
                                                                Get.width *
                                                                    0.05,
                                                            direction:
                                                                Axis.horizontal,
                                                            allowHalfRating:
                                                                true,
                                                            ignoreGestures:
                                                                true,
                                                            itemCount: 5,
                                                            //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                            itemBuilder:
                                                                (context, _) =>
                                                                    Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.amber,
                                                            ),
                                                          );
                                                        }
                                                      } else {
                                                        return RatingBar(
                                                          onRatingUpdate: null,
                                                          initialRating: 3,
                                                          minRating: 1,
                                                          maxRating: 5,
                                                          itemSize:
                                                              Get.width * 0.05,
                                                          direction:
                                                              Axis.horizontal,
                                                          allowHalfRating: true,
                                                          ignoreGestures: true,
                                                          itemCount: 5,
                                                          //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                          itemBuilder:
                                                              (context, _) =>
                                                                  Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: FutureBuilder(
                                                        future: Utility
                                                            .computeDistance(
                                                                merchant.data
                                                                        .bGeoPoint[
                                                                    'geopoint'],
                                                                widget.merchant
                                                                        .bGeoPoint[
                                                                    'geopoint']),
                                                        initialData: 0.1,
                                                        builder: (context,
                                                            AsyncSnapshot<
                                                                    double>
                                                                distance) {
                                                          if (distance
                                                              .hasData) {
                                                            return Text(
                                                                '${Utility.formatDistance(distance.data, '${widget.merchant.bName}')}');
                                                          } else {
                                                            return const SizedBox
                                                                .shrink();
                                                          }
                                                        }))
                                              ],
                                            )
                                          ],
                                        ),
                                        trailing: (merchant.data.bStatus == 1 &&
                                                Utility.isOperational(
                                                    merchant.data.bOpen,
                                                    merchant.data.bClose))
                                            ? Icon(
                                                Icons.lock_open,
                                                color: Colors.green,
                                              )
                                            : Icon(
                                                Icons.lock_outline,
                                                color: Colors.redAccent,
                                              ),
                                        enabled: (merchant.data.bStatus == 1 &&
                                            Utility.isOperational(
                                                merchant.data.bOpen,
                                                merchant.data.bClose)),
                                      )),
                                  Divider(
                                    thickness: 1,
                                  )
                                ],
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }
                        },
                      );
                    }).toList(growable: false)),
                    const SizedBox(
                      height: 30,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Others'),
                      ),
                    ),
                  ],
                ),
            if (logisticList != null)
              if (logisticList.isNotEmpty)
                Column(
                    children:
                        List<Widget>.generate(logisticList.length, (index) {
                  return Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            onTap: () {
                              if (type == "MotorBike") {
                                if (logisticList[index].bikeCount > 0) {
                                  stage = 'OVERVIEW';
                                  mode = 'Delivery';
                                  order = order.update(
                                      orderMode: OrderMode(
                                        mode: mode,
                                        coordinate: GeoPoint(position.latitude,
                                            position.longitude),
                                        address: _address.text,
                                      ),
                                      orderCustomer: Customer(
                                        customerName: widget.user.fname,
                                        customerReview: '',
                                        customerTelephone: _contact.text,
                                      ),
                                      customerID: widget.user.uid,
                                      orderLogistic: logisticList[index].mID,
                                      potentials:[logisticList[index].mID],
                                      auto: 'MotorBike');
                                  screenHeight = 0.8;
                                  setState(() {});
                                } else {
                                  Utility.infoDialogMaker(
                                    "${logisticList[index].bName} does not have a delivery motorbike at the moment",
                                  );
                                }
                              } else if (type == "Car") {
                                if (logisticList[index].carCount > 0) {
                                  stage = 'OVERVIEW';
                                  mode = 'Delivery';
                                  order = order.update(
                                      orderMode: OrderMode(
                                        mode: mode,
                                        coordinate: GeoPoint(position.latitude,
                                            position.longitude),
                                        address: _address.text,
                                      ),
                                      orderCustomer: Customer(
                                        customerName: widget.user.fname,
                                        customerReview: '',
                                        customerTelephone: _contact.text,
                                      ),
                                      customerID: widget.user.uid,
                                      orderLogistic: logisticList[index].mID,
                                      potentials:[logisticList[index].mID],
                                      auto: 'Car');
                                  screenHeight = 0.8;
                                  setState(() {});
                                } else {
                                  Utility.infoDialogMaker(
                                    "${logisticList[index].bName} does not have a delivery car at the moment",
                                  );
                                }
                              } else if (type == "Van") {
                                if (logisticList[index].vanCount > 0) {
                                  stage = 'OVERVIEW';
                                  mode = 'Delivery';
                                  order = order.update(
                                      orderMode: OrderMode(
                                        mode: mode,
                                        coordinate: GeoPoint(position.latitude,
                                            position.longitude),
                                        address: _address.text,
                                      ),
                                      orderCustomer: Customer(
                                        customerName: widget.user.fname,
                                        customerReview: '',
                                        customerTelephone: _contact.text,
                                      ),
                                      customerID: widget.user.uid,
                                      orderLogistic: logisticList[index].mID,
                                      potentials:[logisticList[index].mID],
                                      auto: 'Van');
                                  screenHeight = 0.8;
                                  setState(() {});
                                } else {
                                  Utility.infoDialogMaker(
                                    "${logisticList[index].bName} does not have a delivery van at the moment",
                                  );
                                }
                              }
                            },
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  logisticList[index].bPhoto.isNotEmpty
                                      ? logisticList[index].bPhoto
                                      : PocketShoppingDefaultCover),
                            ),
                            title: Text(logisticList[index].bName),
                            subtitle: Column(
                              children: [
                                Row(
                                  children: [
                                    FutureBuilder(
                                      future: ReviewRepo.getRating(
                                          logisticList[index].mID),
                                      builder: (context,
                                          AsyncSnapshot<Rating> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting)
                                          return const SizedBox.shrink();
                                        else if (snapshot.hasError)
                                          return const SizedBox.shrink();
                                        else {
                                          if (snapshot.hasData) {
                                            if (snapshot.data != null) {
                                              return RatingBar(
                                                onRatingUpdate: null,
                                                initialRating:
                                                    snapshot.data.rating,
                                                minRating: 1,
                                                maxRating: 5,
                                                itemSize: Get.width * 0.05,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                ignoreGestures: true,
                                                itemCount: 5,
                                                //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                itemBuilder: (context, _) =>
                                                    Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                              );
                                            } else {
                                              return RatingBar(
                                                onRatingUpdate: null,
                                                initialRating: 3,
                                                minRating: 1,
                                                maxRating: 5,
                                                itemSize: Get.width * 0.05,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                ignoreGestures: true,
                                                itemCount: 5,
                                                //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                itemBuilder: (context, _) =>
                                                    Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                              );
                                            }
                                          } else {
                                            return RatingBar(
                                              onRatingUpdate: null,
                                              initialRating: 3,
                                              minRating: 1,
                                              maxRating: 5,
                                              itemSize: Get.width * 0.05,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              ignoreGestures: true,
                                              itemCount: 5,
                                              //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: FutureBuilder(
                                            future: Utility.computeDistance(
                                                logisticList[index]
                                                    .bGeoPoint['geopoint'],
                                                widget.merchant
                                                    .bGeoPoint['geopoint']),
                                            initialData: 0.1,
                                            builder: (context,
                                                AsyncSnapshot<double>
                                                    distance) {
                                              if (distance.hasData) {
                                                return Text(
                                                    '${Utility.formatDistance(distance.data, '${widget.merchant.bName}')}');
                                              } else {
                                                return const SizedBox.shrink();
                                              }
                                            }))
                                  ],
                                )
                              ],
                            ),
                            trailing: (logisticList[index].bStatus == 1 &&
                                    Utility.isOperational(
                                        logisticList[index].bOpen,
                                        logisticList[index].bClose))
                                ? Icon(
                                    Icons.lock_open,
                                    color: Colors.green,
                                  )
                                : Icon(
                                    Icons.lock_outline,
                                    color: Colors.redAccent,
                                  ),
                            enabled: (logisticList[index].bStatus == 1 &&
                                Utility.isOperational(logisticList[index].bOpen,
                                    logisticList[index].bClose)),
                          )),
                      Divider(
                        thickness: 1,
                      )
                    ],
                  );
                }).toList(growable: false))
              else
                Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No Rider(s)'),
                ))
            else
              Center(
                  child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Fetching Riders...Please wait'),
              ))
          ],
        ))
      ],
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
            Get.off(CustomerDeliveryTrackerWidget(
              order: order.docID,
              user: widget.user,
            ));
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

/*  static Future<void> callback() async {


    // Get the previous cached count and increment it.
    final prefs = await SharedPreferences.getInstance();
    String currentAgent = prefs.getString(riderKey);
    int count = await OrderRepo.getUnclaimedDelivery(currentAgent);
    debugPrint(" function='$callback'");
    if(count>0)
      Utility.localNotifier("PocketShopping", "PocketShopping",
          "Delivery Request", 'New Delivery request. view dashboard to accept');
  }

  Future<void> requestListenerWorker()async{
    final int workerID = 0369;
    await AndroidAlarmManager.cancel(workerID);
    await AndroidAlarmManager.periodic(
      const Duration(minutes: 2),
      workerID,
      callback,
      rescheduleOnReboot: true,exact: true,);
  }*/

  Widget uploadingOrder() {
    return !paydone
        ? Center(
            child: Container(
              alignment: Alignment.center,
              width: Get.width,
              height: Get.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      width: Get.width * 0.3,
                      height: Get.height * 0.18,
                      child: JumpingDotsProgressIndicator(
                        fontSize: Get.height * 0.12,
                        color: PRIMARYCOLOR,
                      )),
                  Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Placing Order please wait..',
                          style: TextStyle(fontSize: Get.height * 0.025),
                          textAlign: TextAlign.center,
                        )),
                  ),
                  /* if(false)
                  Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: FlatButton(
                          onPressed: (){
                            setState(() {
                              screenHeight = 0.8;
                              stage = 'ERROR';
                              payerror = "You cancelled the process.";
                            });
                          },
                          child:
                          Text(
                            'Cancel.',
                            style: TextStyle(
                                fontSize:
                                Get.height * 0.025),
                            textAlign: TextAlign.center,
                          )
                        )
                    ),
                  ),*/
                ],
              ),
            ),
          )
        : Container(
            height: Get.height * 0.8,
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
                            style: TextStyle(fontSize: Get.height * 0.04),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '${_start}s',
                            style: TextStyle(fontSize: Get.height * 0.05),
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
      case 'LOGISTIC':
        setState(() {
          screenHeight = 0.8;
          stage = 'FAROPTION';
        });
        return false;
        break;
      case 'OVERVIEW':
        setState(() {
          screenHeight = 0.9;
          stage = 'LOGISTIC';
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

  Future<void> newOrderNotifier() async {
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
                'Hello. You have a new Delivery(${widget.merchant.bName}). Advance to your dashboard for details',
            'title': 'New Delivery'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'NewDeliveryOrderRequest',
            }
          },
          'to': agentDevice,
        }));
  }
}
