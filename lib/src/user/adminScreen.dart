import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navigation_badge/bottom_navigation_badge.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/page/user/favourite.dart';
import 'package:pocketshopping/page/user/order.dart';
import 'package:flutter/services.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/geofence/geofence.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;


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
  final TextEditingController _comment = TextEditingController();
  final String serverToken='AAAAqX0WEGw:APA91bGWMn9QDp_xiH3fgsy8-4V348-0ltS2Pfjybk_lSafjSS8etIAry6jBzsc2n9eHj0SDr2TzYwVVBVmz2uhjftxPrhGLfWj9PgFRqAzOtck1_JjOsjMXyMYtGiqFoauMt5Z-LNLl';
  String userName;



  BottomNavigationBadge badger = new BottomNavigationBadge(
      backgroundColor: Colors.red,
      badgeShape: BottomNavigationBadgeShape.circle,
      textColor: Colors.white,
      position: BottomNavigationBadgePosition.topRight,
      textSize: 8);
  List<BottomNavigationBarItem>items=
  <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      title: Text('DashBoard'),
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
      title: Text('Order'),
    ),
  ];

  @override
  void initState(){
    //LocalNotificationService.instance.start();
    userName='';
    _selectedIndex = 0;
    CurrentUser = BlocProvider.of<AuthenticationBloc>(context).state.props[0];
    UserRepo().upDate(uid: CurrentUser.uid,notificationID: 'fcm').then((value)=>null);
    //sendAndRetrieveMessage();
     if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        //print(data);
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        var data = Map<String, dynamic>.from(message);
        var payload = jsonDecode(data['data']['payload']);
        print("onMessage: ${data['data']}");
        final notification = LocalNotification("notification", Map<String, dynamic>.from(message));
        //NotificationsBloc.instance.clearNotification();
        NotificationsBloc.instance.newNotification(notification);
        //GetBar(title: 'tdsd',messageText: Text('sdsd'),
         // duration: Duration(seconds: 5),
       // ).show();
          //print(payload['Items'].first['productName']);
          switch(payload['NotificationType']){
            case 'OrderRequest':
              if(!Get.isDialogOpen)
                Get.defaultDialog(
                  title: '${payload['type']} Request',
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Can you execute this ${payload['type']} order'),
                      SizedBox(height: 20,),
                      Column(
                        children: List<Widget>.generate(payload['Items'].length,
                                (index) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('${payload['Items'][index]['productName']}'),
                                ),
                                Expanded(
                                  child: Text('${payload['Items'][index]['productCount']}'),
                                ),
                              ],
                            )).toList(),
                      ),
                      SizedBox(height: 10,),
                      Align(alignment:Alignment.centerLeft,child: Text('Amount: \u20A6 ${payload['Amount']}'),),
                      payload['type']=='Delivery'?
                      Align(alignment:Alignment.centerLeft,child:Text('delivery Fee: \u20A6${payload['deliveryFee']}')):Container(),
                      payload['type']=='Delivery'?
                      Align(alignment:Alignment.centerLeft,child:Text('Total Fee: \u20A6${payload['deliveryFee']+payload['Amount']}',style: TextStyle(fontWeight: FontWeight.bold),)):Container(),
                      SizedBox(height: 10,),
                      payload['type']=='Delivery'?
                      Align(alignment:Alignment.centerLeft,child:Text('Address: ${payload['Address']}')):Container(),
                      payload['type']=='Delivery'?
                      Align(alignment:Alignment.centerLeft,child:Text('Distance: ${payload['deliveryDistance']/1000}km')):Container(),
                    ],
                  ),
                  confirm: FlatButton(
                    child: Text('Yes'),
                    onPressed: ()async{
                      await Respond(true,'',payload['fcmToken']);
                      NotificationsBloc.instance.clearNotification();
                      Get.back();
                    },
                  ),
                  cancel: FlatButton(
                    child: Text('No'),
                    onPressed: ()async{
                      await Respond(false,'',payload['fcmToken']);
                      NotificationsBloc.instance.clearNotification();
                      Get.back();
                      },
                  ),

                );
              break;
          }




      },
      onBackgroundMessage: Platform.isIOS?null:BackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        _fcm.onTokenRefresh;
        print("onLaunch: ${message['data']}");
        final notification = LocalNotification("notification", Map<String, dynamic>.from(message));
        NotificationsBloc.instance.newNotification(notification);
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        _fcm.onTokenRefresh;
        print("onResume: $message");
        final notification = LocalNotification("notification", Map<String, dynamic>.from(message));
        NotificationsBloc.instance.newNotification(notification);
        // TODO optional
      },
    );




    super.initState();

  }


  static Future<dynamic> BackgroundMessageHandler(Map<String,dynamic>message){
    if(message.containsKey('data')){
      final dynamic data = message['data'];
    }
    if(message.containsKey('notification')){
      final dynamic data = message['notification'];
    }

  }


  unpackNotification(dynamic data){

  }



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
      child:
      BlocProvider(
        create: (context) => UserBloc(
          userRepository: UserRepo(),
        )..add(LoadUser(CurrentUser.uid)),
        child: BlocBuilder<UserBloc, UserState>(

            builder: (context, state) {
              if(state is UserLoaded)
              {
                //setState(() {
                  userName=state.user.user.fname;
               // });
                return Scaffold(
                  drawer: DrawerScreen(userRepository: widget._userRepository,user: state.user.user,),
                  body: Container(

                      child:Center(
                        child: <Widget>[
                          DashBoardScreen(),
                          GeoFence(),
                          Favourite(),
                          OrderWidget(PRIMARYCOLOR),
                        ].elementAt(_selectedIndex),
                      ),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black54.withOpacity(0.2))))
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    items: items,
                    currentIndex: _selectedIndex,
                    selectedItemColor: PRIMARYCOLOR,
                    unselectedItemColor: Colors.black54,
                    showUnselectedLabels: true,
                    onTap: _onItemTapped,
                  ),
                );
              }
              else{
                return Scaffold(
                  body: Center(
                    child:Image.asset("assets/images/loading.gif",
                      width: MediaQuery.of(context).size.width*0.3,),),
                );
              }



            }
        ),
      )

      ,




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
            onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            child: new Text('Yes'),
          ),
        ],
      ),
    ));

  }


  Future<void> Respond(bool yesNo,String response,String fcm)async{
    //print('team meeting');
    await _fcm.requestNotificationPermissions(
      const IosNotificationSettings(sound: true,badge: true,alert: true,provisional: false),
    );
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String,String>{
          'Content-Type':'application/json',
          'Authorization':'key=$serverToken'
        },
        body: jsonEncode(<String,dynamic>{
          'notification':<String,dynamic>{
            'body':yesNo?'Your order has been accepted':'Your order has been decline',
            'title':'Order Confirmation'
          },
          'priority':'high',
          'data':<String,dynamic>{
            'click_action':'FLUTTER_NOTIFICATION_CLICK',
            'id':'1',
            'status':'done',
            'payload': {
              'NotificationType':'OrderRequestResponse',
              'Response':yesNo,
              'Reason':response,
              'acceptedBy':userName
            }
          },
          'to':fcm,
        })
    );
  }


}