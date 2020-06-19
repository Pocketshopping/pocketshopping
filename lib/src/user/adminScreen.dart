import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/admin/ping.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/geofence/geofence.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/favourite.dart';
import 'package:pocketshopping/src/user/logistic.dart';
import 'package:pocketshopping/src/user/myOrder.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'bloc/user.dart';

class AdminScreen extends StatefulWidget {
  final UserRepository _userRepository;

  AdminScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _AdminScreenState createState() => new _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex;
  FirebaseUser CurrentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;
  String userName;


  List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[
    const BottomNavigationBarItem(
      icon: Icon(Icons.check_box_outline_blank),
      title: Text('DashBoard'),
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.search),
      title: Text('Places'),
    ),
    const BottomNavigationBarItem(
      title: Text('Favourite'),
      icon: Icon(Icons.favorite_border),
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.folder_open),
      title: Text('My Order(s)'),
    ),
  ];

  @override
  void initState() {
    //LocalNotificationService.instance.start();
    userName = '';
    _selectedIndex = 0;
    CurrentUser = BlocProvider.of<AuthenticationBloc>(context).state.props[0];
    UserRepo()
        .upDate(uid: CurrentUser.uid, notificationID: 'fcm')
        .then((value) => null);
    //sendAndRetrieveMessage();
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {});
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        var data = Map<String, dynamic>.from(message);
        var payload = jsonDecode(data['data']['payload']);
        final notification = LocalNotification("notification", Map<String, dynamic>.from(message));
        NotificationsBloc.instance.newNotification(notification);
        //GetBar(title: 'tdsd',messageText: Text('sdsd'),
        // duration: Duration(seconds: 5),
        // ).show();
        //print(payload['Items'].first['productName']);
        print(message);
        processNotification(payload,notification);

      },
      onBackgroundMessage: Platform.isIOS ? null : backgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        _fcm.onTokenRefresh;
        var data = Map<String, dynamic>.from(message);
        var payload = jsonDecode(data['data']['payload']);
        final notification = LocalNotification(
            "notification", Map<String, dynamic>.from(message));
        NotificationsBloc.instance.newNotification(notification);
        processNotification(payload,notification);

      },
      onResume: (Map<String, dynamic> message) async {
        _fcm.onTokenRefresh;
        var data = Map<String, dynamic>.from(message);
        var payload = jsonDecode(data['data']['payload']);
        final notification = LocalNotification(
            "notification", Map<String, dynamic>.from(message));
        NotificationsBloc.instance.newNotification(notification);
        processNotification(payload,notification);
      },
    );

    super.initState();
  }

  processNotification(dynamic payload,dynamic notification){
    switch (payload['NotificationType']) {
      case 'OrderRequest':
        if (!Get.isDialogOpen)
          Get.dialog(PingWidget(
            ndata: notification.data,
            uid: CurrentUser.uid,
          ));
        break;
      case 'OrderResolutionResponse':
        print('OrderResolutionResponse');
        if (!Get.isDialogOpen)
          Get.dialog(PingWidget(
            ndata: notification.data,
            uid: CurrentUser.uid,
          ));
        //Get.dialog(Resolution(payload: payload,));
        break;
      case 'NewDeliveryOrderRequest':
        print('NewDeliveryOrderRequest');
        GetBar(titleText: Text('New Delivery',style: TextStyle(color: Colors.white),),
          messageText:Text('You have new Delivery. Check you dashboard for details',style: TextStyle(color: Colors.white),),
            snackPosition: SnackPosition.BOTTOM,
            snackStyle: SnackStyle.GROUNDED,
            backgroundColor: PRIMARYCOLOR,
            duration: Duration(seconds: 3)
        ).show();

      break;
    }
  }

  static Future<dynamic> backgroundMessageHandler(
      Map<String, dynamic> message) {
    if (message.containsKey('data')) {
    }
    if (message.containsKey('notification')) {
    }
    return Future.value(true);
  }

  unpackNotification(dynamic data) {}

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: BlocProvider(
        create: (context) => UserBloc(
          userRepository: UserRepo(),
        )..add(LoadUser(CurrentUser.uid)),
        child: BlocBuilder<UserBloc, UserState>(builder: (context, state) {
          if (state is UserLoaded) {
            //setState(() {
            userName = state.user.user.fname;
            // });
            return Scaffold(
              drawer: DrawerScreen(
                userRepository: widget._userRepository,
                user: state.user.user,
              ),
              body: Container(
                  child: Center(
                    child: <Widget>[
                      state.user.merchant.bCategory == 'Logistic'
                          ? LogisticDashBoardScreen()
                          : DashBoardScreen(),
                      GeoFence(),
                      Favourite(),
                      MyOrders(),
                    ].elementAt(_selectedIndex),
                  ),
                  decoration:  BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Colors.black54.withOpacity(0.2))))),
              bottomNavigationBar: BottomNavigationBar(
                items: items,
                currentIndex: _selectedIndex,
                selectedItemColor: PRIMARYCOLOR,
                unselectedItemColor: Colors.black54,
                showUnselectedLabels: true,
                onTap: _onItemTapped,
              ),
            );
          } else {
            return Scaffold(
              body:  Center(
                  child: JumpingDotsProgressIndicator(
                fontSize: MediaQuery.of(context).size.height * 0.12,
                color: PRIMARYCOLOR,
              )),
            );
          }
        }),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: const Text('Warning'),
        content: const Text('Do you want to exit the App'),
        actions: <Widget>[
           FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          new FlatButton(
            onPressed: () =>
                SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            child: const Text('Yes'),
          ),
        ],
      ),
    ));
  }

  Future<void> Respond(bool yesNo, String response, String fcm) async {
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
            'body': yesNo
                ? 'Your order has been accepted'
                : 'Your order has been decline',
            'title': 'Order Confirmation'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'OrderRequestResponse',
              'Response': yesNo,
              'Reason': response,
              'acceptedBy': userName
            }
          },
          'to': fcm,
        }));
  }
}

class Resolution extends StatefulWidget {
  Resolution({this.payload});

  final dynamic payload;

  @override
  State<StatefulWidget> createState() => _ResolutionState();
}

class _ResolutionState extends State<Resolution> {
  Map<String, dynamic> payload;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final _formKey = GlobalKey<FormState>();
  var _telephone = TextEditingController();
  var _delay = TextEditingController();
  int delay;

  @override
  void initState() {
    delay = 5;
    payload = widget.payload as Map<String, dynamic>;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.3),
          body: Align(
            alignment: Alignment.center,
            child: Container(
              alignment: Alignment.center,
              color: Colors.white,
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  Expanded(
                    flex: 0,
                    child: Center(
                      child: const Text(
                          'Hello. I have not recieved my package and its already time',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ListView(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          //mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(
                              children: List<Widget>.generate(
                                  payload['Items'].length,
                                  (index) => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                  '${payload['Items'][index]['ProductName']}'),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                  '${payload['Items'][index]['count']}'),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                  '\u20A6 ${payload['Items'][index]['ProductPrice']}'),
                                            ),
                                          ),
                                        ],
                                      )).toList(),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child:
                                  Text('Amount: \u20A6 ${payload['Amount']}'),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Align(
                                alignment: Alignment.centerLeft,
                                child:
                                    Text('Telephone: ${payload['telephone']}')),
                            const SizedBox(
                              height: 5,
                            ),
                            payload['type'] == 'Delivery'
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child:
                                        Text('Address: ${payload['Address']}'))
                                : Container(),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
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
                                autofocus: true,
                                maxLines: 5,
                                maxLength: 120,
                                maxLengthEnforced: true,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: _telephone,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Delivery Man Telephone';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Delivery Man Telephone',
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
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: const Text('Extend duration by:(min)')),
                              DropdownButtonFormField<int>(
                                value: delay,
                                items: [5, 10, 15]
                                    .map((label) => DropdownMenuItem(
                                          child: Text(
                                            '$label',
                                            style: TextStyle(
                                                color: Colors.black54),
                                          ),
                                          value: label,
                                        ))
                                    .toList(),
                                hint: const Text('How many minute delay'),
                                decoration:
                                    InputDecoration(border: InputBorder.none),
                                onChanged: (value) {
                                  setState(() {
                                    delay = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      color: PRIMARYCOLOR,
                      child: FlatButton(
                        color: PRIMARYCOLOR,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            Respond(delay, _delay.text, payload['fcmToken'],
                                    _telephone.text, payload['oID'])
                                .then((value) => null);
                            Get.back();
                          }
                        },
                        child: const Text(
                          'Reply',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            ),
          ),
        ));
  }

  Future<void> Respond(int delay, String comment, String fcm, String telephone,
      String oID) async {
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
            'body': '$comment',
            'title': 'Resolution'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'OrderResolutionMerchantResponse',
              'orderID': oID,
              'delay': delay,
              'comment': comment,
              'deliveryman': telephone,
              'time': [Timestamp.now().seconds, Timestamp.now().nanoseconds],
            }
          },
          'to': fcm,
        }));
  }
}
