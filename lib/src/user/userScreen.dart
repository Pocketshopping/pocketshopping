import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bottom_navigation_badge/bottom_navigation_badge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/user/favourite.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/geofence/geofence.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/request/repository/requestRepo.dart';
import 'package:pocketshopping/src/request/request.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/myOrder.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:workmanager/workmanager.dart';

import 'bloc/user.dart';

class UserScreen extends StatefulWidget {
  final UserRepository _userRepository;

  UserScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _UserScreenState createState() => new _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _selectedIndex;
  Color fabColor;
  FirebaseUser CurrentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;
  BottomNavigationBadge badger = new BottomNavigationBadge(
      backgroundColor: Colors.red,
      badgeShape: BottomNavigationBadgeShape.circle,
      textColor: Colors.white,
      position: BottomNavigationBadgePosition.topRight,
      textSize: 8);
  List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      title: Text('Places'),
    ),
    BottomNavigationBarItem(
      title: Text('Favourite'),
      icon:Icon(Icons.favorite_border),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.folder_open),
      title: Text('Order'),
    ),
  ];

  @override
  void initState() {
    _selectedIndex = 0;
    fabColor = PRIMARYCOLOR;
    CurrentUser = BlocProvider.of<AuthenticationBloc>(context).state.props[0];
    UserRepo()
        .upDate(uid: CurrentUser.uid, notificationID: 'fcm')
        .then((value) => null);
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
      },
      onBackgroundMessage: Platform.isIOS ? null : BackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        _fcm.onTokenRefresh;
        final notification = LocalNotification("notification", Map<String, dynamic>.from(message));
        NotificationsBloc.instance.newNotification(notification);
      },
      onResume: (Map<String, dynamic> message) async {
        _fcm.onTokenRefresh;
        final notification = LocalNotification("notification", Map<String, dynamic>.from(message));
        NotificationsBloc.instance.newNotification(notification);
      },
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      RequestRepo.getAll(CurrentUser.uid).then((value) {
        if (value.length > 0)
          GetBar(
            title: 'Rquest',
            messageText: Text(
              'You have an important request to attend to',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: PRIMARYCOLOR,
            mainButton: FlatButton(
              onPressed: () {
                Get.back();
                Get.to(RequestScreen(
                  requests: value,
                ));
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Text(
                    'View',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ).show();
      });
    });
    Workmanager.cancelAll();
    super.initState();
  }

  static Future<dynamic> BackgroundMessageHandler(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      final dynamic data = message['data'];
    }
    if (message.containsKey('notification')) {
      final dynamic data = message['notification'];
    }
    print(message);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    print(CurrentUser.uid);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: BlocProvider(
        create: (context) => UserBloc(
          userRepository: UserRepo(),
        )..add(LoadUser(CurrentUser.uid)),
        child: BlocBuilder<UserBloc, UserState>(builder: (context, state) {
          if (state is UserLoaded) {
            print(state.user.user.uid);
            return Scaffold(
              drawer: DrawerScreen(
                userRepository: widget._userRepository,
                user: state.user.user,
              ),
              body: Container(
                  child: Center(
                    child: <Widget>[
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
                selectedItemColor: fabColor,
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
}
