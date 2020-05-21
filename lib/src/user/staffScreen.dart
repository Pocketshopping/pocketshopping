import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bottom_navigation_badge/bottom_navigation_badge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/page/user/favourite.dart';
import 'package:pocketshopping/src/admin/ping.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/geofence/geofence.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/myOrder.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'bloc/user.dart';

class StaffScreen extends StatefulWidget {
  final UserRepository _userRepository;

  StaffScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _StaffScreenState createState() => new _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  int _selectedIndex;
  FirebaseUser CurrentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;
  final TextEditingController _comment = TextEditingController();
  String userName;

  BottomNavigationBadge badger = new BottomNavigationBadge(
      backgroundColor: Colors.red,
      badgeShape: BottomNavigationBadgeShape.circle,
      textColor: Colors.white,
      position: BottomNavigationBadgePosition.topRight,
      textSize: 8);
  List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      title: Text('Workplace'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.place),
      title: Text('Places'),
    ),
    BottomNavigationBarItem(
      title: Text('Favourite'),
      icon: Icon(Icons.favorite),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.folder),
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
        final notification = LocalNotification(
            "notification", Map<String, dynamic>.from(message));
        NotificationsBloc.instance.newNotification(notification);
        processNotification(payload,notification);
      },
      onBackgroundMessage: Platform.isIOS ? null : BackgroundMessageHandler,
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
      case 'NearByAgent':
        if (!Get.isDialogOpen)
          Get.dialog(PingWidget(
            ndata: notification.data,
            uid: CurrentUser.uid,
          ));
        //Get.dialog(Resolution(payload: payload,));
        break;
    }
  }

  static Future<dynamic> BackgroundMessageHandler(
      Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      final dynamic data = message['data'];
      print(message);
    }
    if (message.containsKey('notification')) {
      final dynamic data = message['notification'];
    }
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
            //print(state.user.agent.autoType);
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
                          ? AgentDashBoardScreen()
                          : StaffDashBoardScreen(),
                      GeoFence(),
                      Favourite(),
                      MyOrders(),
                    ].elementAt(_selectedIndex),
                  ),
                  decoration: BoxDecoration(
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
              body: Center(
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
        title: new Text('Warning'),
        content: new Text('Do you want to exit the App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () =>
                SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            child: new Text('Yes'),
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
