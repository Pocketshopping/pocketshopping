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
import 'package:pocketshopping/src/admin/ping.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/geofence/geofence.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/request/blank.dart';
import 'package:pocketshopping/src/request/bloc/requestBloc.dart';
import 'package:pocketshopping/src/request/repository/requestRepo.dart';
import 'package:pocketshopping/src/request/request.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/favourite.dart';
import 'package:pocketshopping/src/user/myOrder.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:pocketshopping/src/pocketPay/pocket.dart';
import 'package:pocketshopping/src/backgrounder/app_retain_widget.dart';

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
  FirebaseUser currentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;
  final TextEditingController _comment = TextEditingController();
  String userName;
  Stream<LocalNotification> _notificationsStream;

  BottomNavigationBadge badger = new BottomNavigationBadge(
      backgroundColor: Colors.red,
      badgeShape: BottomNavigationBadgeShape.circle,
      textColor: Colors.white,
      position: BottomNavigationBadgePosition.topRight,
      textSize: 8);
  List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.check_box_outline_blank),
      title: Text('Workplace'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      title: Text('Places'),
    ),
    BottomNavigationBarItem(
      title: Text('Favourite'),
      icon: Icon(Icons.favorite_border),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.folder_open),
      title: Text('My Order(s)'),
    ),
    const BottomNavigationBarItem(
      icon: ImageIcon(
        AssetImage("assets/images/blogo.png"),
        color: PRIMARYCOLOR,
      ),
      title: Text('Pocket'),
    ),
  ];

  @override
  void initState() {
    //LocalNotificationService.instance.start();
    userName = '';
    _selectedIndex = 0;
    currentUser = BlocProvider.of<AuthenticationBloc>(context).state.props[0];
    UserRepo().upDate(uid: currentUser.uid, notificationID: 'fcm').then((value) => null);
    //initConfigure();
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {

      if (notification != null) {
        try {
          var payload = jsonDecode(notification.data['data']['payload']);
          processNotification(payload, notification);
        }catch(_){}
      }
    });
    super.initState();
  }


  Future<void> requester()async{
    var value = await RequestRepo.getAll(currentUser.uid);
    RequestBloc.instance.newCount(value.length);
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
    Future.value();
  }

  processNotification(dynamic payload,dynamic notification)async{
    switch (payload['NotificationType']) {
      case 'OrderRequest':
        if (!Get.isDialogOpen)
          Get.dialog(PingWidget(
            ndata: notification.data,
            uid: currentUser.uid,
          ));
        break;
      case 'OrderResolutionResponse':
        print('OrderResolutionResponse');
        if (!Get.isDialogOpen)
          Get.dialog(PingWidget(
            ndata: notification.data,
            uid: currentUser.uid,
          ));
        break;
      case 'NearByAgent':
        if (!Get.isDialogOpen)
          Get.dialog(PingWidget(
            ndata: notification.data,
            uid: currentUser.uid,
          ));
        break;
        break;
      case 'WorkRequestResponse':
        await requester();
        break;
    }
  }

  @override
  void dispose() {
    iosSubscription?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppRetainWidget(
      child: BlocProvider(
        create: (context) => UserBloc(
          userRepository: UserRepo(),
        )..add(LoadUser(currentUser.uid)),
        child: BlocBuilder<UserBloc, UserState>(builder: (context, state) {
          if (state is UserLoaded) {
            //print(state.user.agent.autoType);
            //setState(() {
            userName = state.user.user.fname;
            // });
            if(state.user.merchant != null)
            return Scaffold(
              drawer: DrawerScreen(
                userRepository: widget._userRepository,
                user: state.user.user,
              ),
              body: Container(
                  child: Center(
                    child: <Widget>[
                      state.user.merchant.bCategory == 'Logistic' ? AgentDashBoardScreen() : StaffDashBoardScreen(),
                      GeoFence(),
                      Favourite(),
                      MyOrders(),
                      PocketPay(),
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

            else
              return Scaffold(
                drawer: DrawerScreen(
                  userRepository: widget._userRepository,
                  user: state.user.user,
                ),
                body: Container(
                    child: Center(
                      child: <Widget>[
                        BlankWorkplace(),
                        GeoFence(),
                        Favourite(),
                        MyOrders(),
                        PocketPay(),
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
                SystemChannels.platform.invokeMethod('sendToBackground'),
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
