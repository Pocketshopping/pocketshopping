import 'dart:async';
import 'dart:convert';

import 'package:ant_icons/ant_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
import 'package:pocketshopping/src/user/logistic.dart';
import 'package:pocketshopping/src/user/myOrder.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
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
  FirebaseUser currentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;
  String userName;
  Stream<LocalNotification> _notificationsStream;


  List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[
    const BottomNavigationBarItem(
      icon: Icon(AntIcons.shop_outline),
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
      title: Text('Transations'),
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
    //sendAndRetrieveMessage();
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      if (notification != null) {
        var payload = jsonDecode(notification.data['data']['payload']);
        processNotification(payload, notification);
      }
    });

    Utility.stopAllService();
    Utility.locationAccess();
    super.initState();
  }




    processNotification(dynamic payload,dynamic notification)async{
    switch (payload['NotificationType']) {
/*      case 'OrderRequest':
        if (!Get.isDialogOpen)
          Get.dialog(PingWidget(
            ndata: notification.data,
            uid: currentUser.uid,
          ));
        break;
      case 'OrderResolutionResponse':
        if (!Get.isDialogOpen)
          Get.dialog(PingWidget(
            ndata: notification.data,
            uid: currentUser.uid,
          ));
        //Get.dialog(Resolution(payload: payload,));
        break;*/
      case 'NewDeliveryOrderRequest':
        GetBar(titleText: Text('New Delivery',style: TextStyle(color: Colors.white),),
          messageText:Text('You have new Delivery. Check you dashboard for details',style: TextStyle(color: Colors.white),),
            snackPosition: SnackPosition.BOTTOM,
            snackStyle: SnackStyle.GROUNDED,
            backgroundColor: PRIMARYCOLOR,
            duration: Duration(seconds: 3)
        ).show();


      break;
      case 'WorkRequestResponse':
        await requester();
        break;

      case 'PocketTransferResponse':
        Utility.bottomProgressSuccess(
          title:payload['title'],
          body: payload['message'],
            wallet: payload['data']['wallet'],
        duration: 5);
        break;

      case 'CloudDeliveryCancelledResponse':
        User user = await UserRepo.getOneUsingUID(currentUser.uid);
        Utility.bottomProgressSuccess(
            title:'Delivery',
            body: 'Your Delivery has been cancelled',
            wallet: user.walletId
        );
        break;
     default:
         Utility.bottomProgressSuccess(
              title:payload['title'],
              body: payload['message'],
              //wallet: payload['data']['wallet'],
              duration: 5
          );
          break;
    }
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
    return AppRetainWidget(
      child: BlocProvider(
        create: (context) => UserBloc(
          userRepository: UserRepo(),
        )..add(LoadUser(currentUser.uid)),
        child: BlocBuilder<UserBloc, UserState>(builder: (context, state) {
          if (state is UserLoaded) {
            //setState(() {
            userName = state.user.user.fname;
            // });
            return state.user.merchant != null ?Scaffold(
              drawer: DrawerScreen(
                userRepository: widget._userRepository,
                user: state.user.user,
              ),
              body: Container(
                  child: Center(
                    child: <Widget>[
                      state.user.merchant.bCategory == 'Logistic' ? LogisticDashBoardScreen() : DashBoardScreen(),
                      MyRadius(),//GeoFence(),
                      Favourite(),
                      MyOrders(),
                      PocketPay(),
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
            ):
            Scaffold(
              body:  Center(
                  child: Text('Error')
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

  Future<void> respond(bool yesNo, String response, String fcm) async {
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
                                                  '$CURRENCY ${payload['Items'][index]['ProductPrice']}'),
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
                                  Text('Amount: $CURRENCY ${payload['Amount']}'),
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
                            respond(delay, _delay.text, payload['fcmToken'],
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

  Future<void> respond(int delay, String comment, String fcm, String telephone,
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
