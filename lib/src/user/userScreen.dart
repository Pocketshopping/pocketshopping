import 'dart:async';
import 'dart:convert';

import 'package:bottom_navigation_badge/bottom_navigation_badge.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/backgrounder/app_retain_widget.dart';
import 'package:pocketshopping/src/geofence/radius.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/pocketPay/pocket.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/request/bloc/requestBloc.dart';
import 'package:pocketshopping/src/request/repository/requestRepo.dart';
import 'package:pocketshopping/src/request/request.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/favourite.dart';
import 'package:pocketshopping/src/user/myOrder.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:flutter/scheduler.dart';
import 'package:pocketshopping/src/user/merchant.dart';

import 'bloc/user.dart';

class UserScreen extends StatefulWidget {
  final UserRepository _userRepository;
  final int route;
  final String merchant;

  UserScreen({Key key, @required UserRepository userRepository,this.route=0,this.merchant})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _UserScreenState createState() => new _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _selectedIndex;
  Color fabColor;
  fire.User currentUser;
  Stream<LocalNotification> _notificationsStream;
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
      label: 'Places',
    ),
    BottomNavigationBarItem(
      label: 'Favourite',
      icon:Icon(Icons.favorite_border),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.folder_open),
      label: 'History',
    ),
    const BottomNavigationBarItem(
      icon: ImageIcon(
        AssetImage("assets/images/blogo.png"),
        color: PRIMARYCOLOR,
      ),
      label: 'Pocket',
    ),
  ];

  @override
  void initState() {
    _selectedIndex = 0;
    fabColor = PRIMARYCOLOR;
    currentUser = BlocProvider.of<AuthenticationBloc>(context).state.props[0];
    UserRepo()
        .upDate(uid: currentUser.uid, notificationID: 'fcm')
        .then((value) => null);
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      try{
        if (notification != null) {
          var payload = jsonDecode(notification.data['data']['payload']);
          processNotification(payload, notification);
        }
      }catch(_){
        //print(_.toString());
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((_) async{await requester();});
    Utility.locationAccess();

    if(widget.route > 0)
      SchedulerBinding.instance.addPostFrameCallback((_) async{
        Get.dialog(MerchantScreen(user: currentUser.uid ,merchant: widget.merchant,));
      });
    Utility.stopAllService();
    super.initState();
  }




  Future<void> requester({bool showNotification=true})async{
    var value = await RequestRepo.getAll(currentUser.uid);
    RequestBloc.instance.newCount(value.length);
    if(showNotification){
      if (value.length > 0)
        if(!Get.isSnackbarOpen)
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
                uid: currentUser.uid,
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
    }
    Future.value();
  }



  static Future<dynamic> BackgroundMessageHandler(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
    }
    if (message.containsKey('notification')) {
    }
    
  }



  processNotification(dynamic payload,dynamic notification)async{
    switch (payload['NotificationType']) {
      case 'WorkRequestResponse':
        await requester();
        break;
      /*case 'RemoveStaffResponse':
        GetBar(
          title: payload['title'],
          messageText: Text(payload['message']??'',style: TextStyle(color: Colors.white),),
          backgroundColor: PRIMARYCOLOR,
          icon: Icon(Icons.check,color: Colors.white,),
          duration: Duration(seconds: 5),
        ).show().then((value) async{
          await RequestRepo.clear(payload['data']['requestId']);
          await UserRepository().changeRole('user');
          BlocProvider.of<AuthenticationBloc>(context).add(AppStarted());
          Get.back();
        });*/
        break;
      /*
      case 'WorkRequestCancelResponse':
        await requester(showNotification: false);
        NotificationsBloc.instance.newNotification(null);
        break;*/
      case 'PocketTransferResponse':
        Utility.bottomProgressSuccess(
          title:payload['title'],
        body: payload['message'],
        wallet: payload['data']['wallet'],
          duration: 5
        );
        NotificationsBloc.instance.newNotification(null);
        break;

      case 'CloudDeliveryCancelledResponse':
        User user = await UserRepo.getOneUsingUID(currentUser.uid);
        Utility.bottomProgressSuccess(
            title:'Delivery',
            body: 'Your Delivery has been cancelled',
            wallet: user.walletId
        );
        NotificationsBloc.instance.newNotification(null);
        break;
      default:
        if(payload['message'] != null){
          if(payload['message'].toString().isNotEmpty){
            Utility.bottomProgressSuccess(
                title:payload['title'],
                body: payload['message'],
                //wallet: payload['data']['wallet'],
                duration: 5
            );
          }
        }
        break;
    }
  }




  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return AppRetainWidget(
      child: BlocProvider(
        create: (context) => UserBloc(
          userRepository: UserRepo(),
        )..add(LoadUser(currentUser.uid)),
        child: BlocBuilder<UserBloc, UserState>(builder: (context, state) {
          if (state is UserLoaded) {
            return Scaffold(
              drawer: DrawerScreen(
                userRepository: widget._userRepository,
                user: state.user.user,
              ),
              body: Container(
                  child: Center(
                    child: <Widget>[
                      MyRadius(),
                      Favourite(),
                      MyOrders(),
                      PocketPay(),
                    ].elementAt(_selectedIndex),
                  ),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Colors.black54.withOpacity(0.2))))),/*ShowCaseWidget(
                builder: Builder(
                  builder: (context){
                    return Container(
                        child: Center(
                          child: <Widget>[
                            MyRadius(),
                            Favourite(),
                            MyOrders(),
                            PocketPay(),
                          ].elementAt(_selectedIndex),
                        ),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.black54.withOpacity(0.2)))));
                  },
                ),

              ),*/
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
                fontSize: Get.height * 0.12,
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
