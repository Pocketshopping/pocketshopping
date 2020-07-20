import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:ant_icons/ant_icons.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:pocketshopping/src/admin/bottomScreen/unit.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/channels/repository/channelRepo.dart';
import 'package:pocketshopping/src/location/bloc/locationBloc.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/locRepo.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/order/bloc/orderBloc.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/requestBucket.dart';
import 'package:pocketshopping/src/payment/topup.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/agent/myAuto.dart';
import 'package:pocketshopping/src/user/agent/myDeliveries.dart';
import 'package:pocketshopping/src/user/agent/requestPocketSense.dart';
import 'package:pocketshopping/src/user/agentBusiness.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';





class AgentDashBoardScreen extends StatefulWidget {
  static String tag = 'Agent Dashboard';
  @override
  _AgentDashBoardScreenState createState() => new _AgentDashBoardScreenState();
}

class _AgentDashBoardScreenState extends State<AgentDashBoardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Session currentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  Stream<LocalNotification> _notificationsStream;
  StreamSubscription iosSubscription;
  StreamSubscription orders;
  StreamSubscription bucket;
  StreamSubscription todayOrderCount;
  Stream<Wallet> _walletStream;
  Location location;

  final _isAvailableNotifier = ValueNotifier<bool>(true);
  final _walletNotifier = ValueNotifier<Wallet>(null);
  final _orderNotifier = ValueNotifier<List<Order>>([]);
  final _bucketCount = ValueNotifier<int>(0);
  final _orderCountNotifier = ValueNotifier<int>(0);
  final _remittanceNotifier = ValueNotifier<Map<String,dynamic>>(null);
  StreamSubscription<LocationData> locStream;



  @override
  void initState() {
    currentUser = BlocProvider.of<UserBloc>(context).state.props[0];
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      if (notification != null) {
        //print('Notifications: ${notification.data['data']}');
        try{
        if (mounted && notification.data['data']['payload'].toString().isNotEmpty) {
          Map<String,dynamic> payload = jsonDecode(notification.data['data']['payload']);
          switch (payload['NotificationType']) {
            case 'NewDeliveryOrderRequest':
              showBar('New Delivery','Hello. You have a new Delivery. Advance to your dashboard for details');
              NotificationsBloc.instance.clearNotification();
              break;
            case 'OrderConfirmationResponse':
              showBar('Delivery Confirmation','Hello. You have a Delivery has been confirmed by the customer');
              break;
            case 'clearanceConfirmationResponse':
              WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
              showBar('Cleared','Hello. you have been cleared by the admin. you can now proceed with excuting delivery, Thank you');
              backgroundWorker().then((value) => null);
              NotificationsBloc.instance.clearNotification();
              break;

            case 'PendingRemittanceNotification':
              WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
              showBar('Pending Clearance','Hello. you have a pending clearance. Head straight to the office or request for clearance to enable you continue');
              backgroundWorker().then((value) => null);
              NotificationsBloc.instance.clearNotification();
              break;

            case 'agentCancellationNotifier':
              WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
              showBar('Order Cancelled','Hello. An Order has been cancelled by the office, check delivery dashboard for details');
              backgroundWorker().then((value) => null);
              NotificationsBloc.instance.clearNotification();
              break;

            default:
              WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
              break;
          }
          WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
        }}catch(_){}
      }

    });

    WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if(mounted) {
        updateWallet(wallet);
        LogisticRepo.getRemittance(currentUser.user.walletId,limit:currentUser.agent.limit).then((value) => _remittanceNotifier.value=value);
      }
    });

    orders = OrderRepo.agentOrder(currentUser.agent.agent).listen((event) {
      if(mounted)
        {
          _orderNotifier.value=[];
          _orderNotifier.value=event;
        }
      OrderBloc.instance.newOrder(event);
    });

    bucket = OrderRepo.agentBucketCount(currentUser.agent.agentID).listen((event) {
      if(mounted)
      {
        _bucketCount.value=event;
      }

    });

    LogisticRepo.getRemittance(currentUser.user.walletId,limit:currentUser.agent.limit).then((value) => _remittanceNotifier.value=value);
    todayOrderCount = OrderRepo.agentTodayOrder(currentUser.agent.agent).listen((event) {if(mounted) _orderCountNotifier.value=event;});

    if(currentUser.agent == null) ChannelRepo.update(currentUser.merchant.mID, currentUser.user.uid);
    location = new Location();
    location.hasPermission().then((value)  {
      if(value == PermissionStatus.granted){
        location.serviceEnabled().then((value){
          if(value){

            location.changeSettings(accuracy: LocationAccuracy.navigation, interval: 1000);
            locStream = location.onLocationChanged.listen((LocationData cLoc) { LocationBloc.instance.newLocationUpdate(cLoc); });
          }
        });
      }
    });


    try {
      LogisticRepo.getOneAgentLocation(currentUser.agent.agentID).then((value) {
        if (value != null) _isAvailableNotifier.value = value.availability;
      });
    }catch(_){}
    //requestListenerWorker();

    //backgroundWorker();
    setAgentLocationDetails().then((value) {
        AndroidAlarmManager.initialize();
        requestListenerWorker();
    });

    //initPlatformState();
    //setAgentLocationDetails().then((value) => null);
    super.initState();


  }

  Future<bool> setAgentLocationDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('agentID', currentUser.agent.agentID??"");
    await prefs.setString('agentAutomobile', currentUser.agent.autoType??"");
    await prefs.setBool('availability', true);
    await prefs.setString('agentTelephone', currentUser.user.telephone??"");
    await prefs.setString('agentName', currentUser.user.fname??"");
    await prefs.setString('wallet', currentUser.user.walletId??"");
    await prefs.setString('agentParent', currentUser.agent.agentWorkPlace??"");
    await prefs.setString('workPlaceWallet', currentUser.agent.workPlaceWallet??"");
    await prefs.setString('profile', currentUser.user.profile??"");
    await prefs.setInt('limit', currentUser.agent.limit??1000);
    await prefs.setBool('autoAssigned', currentUser.agent.autoAssigned!=null?currentUser.agent.autoAssigned.isNotEmpty:false);
    return true;
  }

/*  Future<void> initPlatformState() async {
    bool isRunning = await BackgroundLocator.isRegisterLocationUpdate();
    if(!isRunning){
      await BackgroundLocator.initialize();
      startLocationService();
    }

  }*/

/*  static void locCallback(LocationDto locationDto) async {
    //debugPrint('background: ${locationDto.toString()}');
    final prefs = await SharedPreferences.getInstance();
    String currentAgent = prefs.getString('rider');
    double lat;
    double lng;
    double distance;
    Geoflutterfire geo = Geoflutterfire();
    try{
      GeoFirePoint agentLocation = geo.point(latitude: locationDto.latitude, longitude: locationDto.longitude);
      if(prefs.containsKey('rider')){
        if(prefs.containsKey('riderLat') && prefs.containsKey('riderLng')){
          lat = prefs.getDouble('riderLat');
          lng = prefs.getDouble('riderLng');
          distance = await geoloc.Geolocator().distanceBetween(lat, lng, locationDto.latitude, locationDto.longitude);
          if(distance > 50){
            prefs.setDouble('riderLat', locationDto.latitude);
            prefs.setDouble('riderLng', locationDto.longitude);
            LocRepo.updateAgentCoord(currentAgent, agentLocation.data);
          }
        }
        else{
          prefs.setDouble('riderLat', locationDto.latitude);
          prefs.setDouble('riderLng', locationDto.longitude);
          LocRepo.updateAgentCoord(currentAgent, agentLocation.data);
        }
      }
    }catch(_){}

  }*/

 /* void startLocationService(){
    BackgroundLocator.registerLocationUpdate(
      locCallback,
      //optional
      //androidNotificationCallback: notificationCallback,
      settings: LocationSettings(
        //Scroll down to see the different options
          notificationTitle: "Pocketshopping",
          notificationMsg: "Currently running",
          notificationIcon: 'app_icon',
          wakeLockTime: 20,
          autoStop: false,
          interval: 120,
          accuracy: LocationAccuracy.HIGH,
      ),
    );
  }*/

  Future<bool> setAgentID() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rider', currentUser.agent.agentID);
    return true;

  }

  static Future<void> requestCallback() async {
    try{
      final prefs = await SharedPreferences.getInstance();
      String currentAgent = prefs.getString('rider');
      int count = await OrderRepo.getUnclaimedDelivery(currentAgent);
      if(count>0)
        Utility.localNotifier("PocketShopping", "PocketShopping", "Delivery Request", 'There is a Delivery request in request bucket. check it out');
    }catch(_){debugPrint(_);}
  }

/*  Future<void> backgroundWorker(){
    Workmanager.cancelAll();
    Workmanager.registerPeriodicTask(
        "AGENTLOCATIONUPDATE", "LocationUpdateTask",
        frequency: Duration(minutes: 5),
        tag: 'LocationUpdateTag',
        inputData: {
          'agentID': currentUser.agent.agentID,
          'agentAutomobile': currentUser.agent.autoType,
          'availability': true,
          'agentTelephone': currentUser.user.telephone,
          'agentName': currentUser.user.fname,
          'wallet':currentUser.user.walletId,
          'agentParent':currentUser.agent.agentWorkPlace,
          'workPlaceWallet':currentUser.agent.workPlaceWallet??'',
          'profile':currentUser.user.profile,
          'limit':currentUser.agent.limit,
          'autoAssigned':currentUser.agent.autoAssigned!=null?currentUser.agent.autoAssigned.isNotEmpty:false
        });

      return Future.value();
  }*/

  static Future<void> backgroundWorker(){
    Workmanager.cancelAll();
    Workmanager.registerPeriodicTask(
        "AGENTLOCATIONUPDATE", "LocationUpdateTask",
        frequency: Duration(minutes: 15),
        tag: 'LocationUpdateTag',
        inputData: {});

      return Future.value();
  }

  Future<void> requestListenerWorker()async{

    await AndroidAlarmManager.cancel(requestWorkerID);
   await AndroidAlarmManager.periodic(const Duration(minutes: 2), requestWorkerID, backgroundWorker, rescheduleOnReboot: true, exact: true,);
  }


  /*Future<void> requestListenerWorker()async{
    await AndroidAlarmManager.cancel(requestWorkerID);
    await AndroidAlarmManager.periodic(const Duration(minutes: 3), requestWorkerID, requestCallback, rescheduleOnReboot: true, exact: true,);
  }*/





  Future<bool> updateWallet(Wallet wallet){
    _walletNotifier.value=null;
    _walletNotifier.value = wallet;
    return Future.value(true);
  }

  showBar(String title,String body){
    GetBar(title: '$title',
      messageText: Text( '$body ',style: TextStyle(color: Colors.white),),
      backgroundColor: PRIMARYCOLOR,
      snackStyle: SnackStyle.GROUNDED,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    ).show();
  }

 void showBottom(Map<String,dynamic>  payload) {
    switch (payload['NotificationType']) {
      case 'NewDeliveryOrderRequest':
        showBar('New Delivery','Hello. You have a new Delivery. Advance to your dashboard for details');
        NotificationsBloc.instance.clearNotification();
        break;
      case 'OrderConfirmationResponse':
        showBar('Delivery Confirmation','Hello. A Delivery has been confirmed by the customer');
        break;

      default:
        WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
        break;
    }
    WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
  }

  @override
  void dispose() {
    _orderNotifier?.dispose();
   _walletNotifier?.dispose();
    orders?.cancel();
    todayOrderCount?.cancel();
    iosSubscription?.cancel();
    bucket?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double marginLR = MediaQuery.of(context).size.width;
    double gridHeight = MediaQuery.of(context).size.height * 0.1;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.1), // here the desired height
          child: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: PRIMARYCOLOR,
                size: marginLR * 0.08,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.white,
            title: Text(
              currentUser.merchant.bName ?? "Pocketshopping",
              style: const TextStyle(color: PRIMARYCOLOR),
            ),
            automaticallyImplyLeading: false,
          ),

        ),
        body: Container(
            color: Colors.white,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                    delegate: SliverChildListDelegate(
                  [

                    Center(
                      child: const Text(
                        'Rider',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 20,)
                  ],
                )),
                SliverList(
                    delegate: SliverChildListDelegate(
                      [

                        Center(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height*0.3,
                            width: MediaQuery.of(context).size.width*0.6,
                            child: GestureDetector(onTap: ()async{
                              FlutterRingtonePlayer.playNotification();
                              await FlutterRingtonePlayer.play(
                                android: AndroidSounds.notification,
                                ios: IosSounds.glass,
                                looping: true, // Android only - API >= 28
                                volume: 0.1, // Android only - API >= 28
                                asAlarm: false, // Android only - all APIs
                              );
                              Get.to(RequestBucket(user: currentUser,)).then((value) => null);
                            },child: Card(
                              child: ValueListenableBuilder(
                                valueListenable: _bucketCount,
                                builder: (_,count,__){
                                  return
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text('$count',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color:PRIMARYCOLOR,fontSize: 30),),
                                        const Text('Request Bucket',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: PRIMARYCOLOR),),
                                        const Text('click to view',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: PRIMARYCOLOR),),
                                      ],

                                    );
                                },
                              ),
                            )
                            )
                          )
                        ),
                        const SizedBox(height: 20,)
                      ],
                    )),
                SliverList(
                    delegate: SliverChildListDelegate(
                      [

                        Container(
                            color: Colors.white,
                            //margin:  MediaQuery.of(context).size.height*0.05,
                            margin: EdgeInsets.only(
                                left: marginLR * 0.01, right: marginLR * 0.01),
                            child: ValueListenableBuilder(
                              valueListenable: _walletNotifier,
                              builder: (_,Wallet wallet,__){
                                if(wallet != null)
                                  return Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          const Expanded(
                                            flex: 0,
                                            child: const SizedBox(
                                              width: 10,
                                            ),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Column(
                                                children: [
                                                  Center(
                                                      child: const Text(
                                                        "PocketUnit",
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight.bold),
                                                      )
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      "1.00 unit = ${CURRENCY}1.00",
                                                      style: TextStyle(
                                                          fontSize: 11),
                                                    )),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Center(
                                                      child: Text(
                                                        "${wallet.pocketUnitBalance}",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold),
                                                      )),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: PRIMARYCOLOR
                                                              .withOpacity(0.5)),
                                                      color:
                                                      PRIMARYCOLOR.withOpacity(0.8),
                                                    ),
                                                    child: FlatButton(
                                                      onPressed: ()  {
                                                        FocusScope.of(context).requestFocus(FocusNode());
                                                        //sendAndRetrieveMessage()
                                                        //  .then((value) => null)
                                                        //DynamicLinks
                                                        //  .createLinkWithParams({
                                                        //'merchant': 'rerereg',
                                                        //'OTP':
                                                        //  'randomNumber.toString()',
                                                        //'route': 'branch'
                                                        //}).then((value) => print(value))
                                                        Get.dialog(TopUp(user: currentUser.user,payType: "TOPUPUNIT",));

                                                      },
                                                      child: const Center(
                                                          child: const Text(
                                                            "TopUp",
                                                            style: const TextStyle(
                                                                color: Colors.white),
                                                          )),
                                                    ),
                                                  )
                                                ],
                                              )
                                          ),
                                          const Expanded(
                                            flex: 0,
                                            child: SizedBox(
                                              width: 10,
                                            ),
                                          ),
                                          ValueListenableBuilder(
                                            valueListenable: _remittanceNotifier,
                                            builder: (_,remittance,__){
                                              return remittance != null?
                                              Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    children: [
                                                      Center(
                                                          child: Text(
                                                            "Cash Collected",
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold),
                                                          )),
                                                      Center(
                                                          child: Text(
                                                            remittance['remittance']?"Below is your clearance code":"Current cash in your disposal",
                                                            style: TextStyle(
                                                                fontSize: 11),
                                                          )),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Center(
                                                          child: Text(
                                                            "$CURRENCY ${remittance['total']}",
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold),
                                                          )),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: PRIMARYCOLOR
                                                                  .withOpacity(0.5)),
                                                          color:
                                                          PRIMARYCOLOR.withOpacity(0.8),
                                                        ),
                                                        child: FlatButton(
                                                          onPressed: () => {
                                                            if(!remittance['remittance']){
                                                              if(remittance['total']>0.0){
                                                                 LogisticRepo.getRemittance(currentUser.user.walletId,limit: remittance['total'].round()).then((value)
                                                                 { _remittanceNotifier.value=value;
                                                                 GetBar(title: 'Clearance Code Generated',
                                                                   messageText: Text( 'Head to the office for clearance ',style: TextStyle(color: Colors.white),),
                                                                   backgroundColor: PRIMARYCOLOR,
                                                                   snackStyle: SnackStyle.GROUNDED,
                                                                   snackPosition: SnackPosition.BOTTOM,
                                                                   duration: const Duration(seconds: 5),
                                                                 ).show();
                                                                 }),
                                                                backgroundWorker()
                                                              }
                                                              else{
                                                                GetBar(title: 'Error Generating Clearance',
                                                                messageText: Text( 'Your Cash total is ${CURRENCY}0.0 ',style: TextStyle(color: Colors.white),),
                                                                backgroundColor: PRIMARYCOLOR,
                                                                snackStyle: SnackStyle.GROUNDED,
                                                                snackPosition: SnackPosition.BOTTOM,
                                                                duration: const Duration(seconds: 3),
                                                                ).show()
                                                              }
                                                            }
                                                            else{
                                                              GetBar(title: 'Clearance Code ${remittance['remittanceID']}',
                                                                messageText: Text( 'You have a pending clearance ',style: TextStyle(color: Colors.white),),
                                                                backgroundColor: PRIMARYCOLOR,
                                                                snackStyle: SnackStyle.GROUNDED,
                                                                snackPosition: SnackPosition.BOTTOM,
                                                                duration: const Duration(seconds: 5),
                                                              ).show()
                                                            }
                                                          },
                                                          child: Center(
                                                              child: Text(
                                                                remittance['remittance']?remittance['remittanceID']:"Generate Clearance",
                                                                style: TextStyle(
                                                                    color: Colors.white),
                                                              )),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                              ):const SizedBox.shrink();
                                            },
                                          ),
                                          ],
                                      ),
                                      if (wallet.pocketUnitBalance<100)
                                        Column(
                                          children: [
                                            const Divider(),
                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                              child: Text('${'You are currently on hold because your PocketUnit is below the expected quota($CURRENCY 100), you will be unavaliable to run delivery until you Topup.'}'),
                                            )
                                          ],
                                        ),
                                      ValueListenableBuilder(
                                          valueListenable: _remittanceNotifier,
                                          builder: (_,remittance,__){
                                            return remittance != null ?
                                            remittance['remittance']?Column(
                                              children: [
                                                const Divider(),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                                  child: Text('${'You are currently on hold because you have a pending clearance with the following clearance code ${remittance['remittanceID']}'} head to the office for clearance.'),
                                                )
                                              ],
                                            ):const SizedBox.shrink()
                                                :const SizedBox.shrink();
                                          })

                                    ],
                                  );
                                else
                                  return const SizedBox.shrink();
                              } ,
                            )


                        ),
                        if(currentUser.agent.autoAssigned == 'Unassign')
                        Column(
                          children: [
                            const Divider(),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                              child: Text('You are currently on hold because you are not assigned to any automobile. Contact office for more information.',style: TextStyle(color: Colors.red),),
                            ),
                          ],
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                      ],
                    )),
                SliverGrid.count(crossAxisCount: 3, children: [
                  ValueListenableBuilder(
                      valueListenable: _orderNotifier,
                      builder: (_, orders,__){
                        return
                  GestureDetector(
                    onTap: (){
                      //print(currentUser.agent.agentID);
                      Get.to(MyDelivery(orders: orders,user: currentUser,)).then((value) => null);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('${orders.length}',
                                textAlign: TextAlign.center,
                                style: TextStyle(color:PRIMARYCOLOR,fontSize: 25),),
                              const Text('Active Delivery',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: PRIMARYCOLOR),),
                            ],

                          )

                      ),
                    );
                      }
                  ),
                  GestureDetector(
                    onTap: (){},
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('$CURRENCY ${Utility.numberFormatter(0)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: PRIMARYCOLOR,fontSize: 25),),
                         const Text('Amount Made Today',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: PRIMARYCOLOR),),
                        ],
                      ),
                    ),
                  ),
                  ValueListenableBuilder(
                     valueListenable: _isAvailableNotifier,
                      builder: (_,available,__){
                       return GestureDetector(
                         onTap: (){},
                         child: Container(
                           margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                           decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.only(
                                 topLeft: Radius.circular(10),
                                 topRight: Radius.circular(10),
                                 bottomLeft: Radius.circular(10),
                                 bottomRight: Radius.circular(10)
                             ),
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.grey.withOpacity(0.2),
                                 spreadRadius: 2,
                                 blurRadius: 7,
                                 offset: Offset(0, 1), // changes position of shadow
                               ),
                             ],
                           ),
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children: [
                               Text('I am currently '
                                   '${available?'Available':'Unavailable'}',
                                 textAlign: TextAlign.center,
                                 style: TextStyle(color: PRIMARYCOLOR),),
                               FlatButton(
                                 onPressed: ()async{
                                   bool change =!available;
                                   bool result = await LocRepo.updateAvailability(currentUser.agent.agentID, change);
                                   if(!(change == result))
                                     GetBar(title: 'Error changing your status please try again');
                                   else
                                     _isAvailableNotifier.value = result;
                                 },
                                 child: Padding(
                                   padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                   child: const Text('Change',style: TextStyle(color: Colors.white),),
                                 ),
                                 color: PRIMARYCOLOR.withOpacity(0.8),
                               )
                             ],
                           ),
                         ),
                       );
                      })

                ]),
                SliverList(
                    delegate: SliverChildListDelegate([
                  Container(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ])),

                SliverList(
                    delegate: SliverChildListDelegate(
                  [
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 0.5,
                                color: PRIMARYCOLOR.withOpacity(0.5)),
                          ),
                          color: Colors.white),
                      padding: EdgeInsets.only(left: marginLR * 0.04),
                      child: const Text(
                        "Menu",
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                )),
                SliverGrid.count(
                  crossAxisCount: 3,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _orderNotifier,
                      builder: (_, orders,__){
                        return
                        MenuItem(
                          gridHeight,
                          Icon(AntIcons.shopping_outline,
                              size: MediaQuery.of(context).size.width * 0.1,
                              color: PRIMARYCOLOR.withOpacity(0.8)),
                          'Deliveries',
                          border: PRIMARYCOLOR,
                          isBadged: true,
                          isMultiMenu: false,
                          openCount: orders.length,
                          content: MyDelivery(orders: orders,user: currentUser,),
                        );
                      }),
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.bulb_outline,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8),
                      ),
                      'New Business',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: SetupBusiness(isAgent: true,agent: User(currentUser.agent.agentWorkPlace,email: currentUser.user.email),),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.shop_outline,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My Business(es)',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: AgentBusiness(user: currentUser,),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.smile_outline,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'PocketSense',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: RequestPocketSense(user: currentUser,),
                    ),

                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.deployment_unit,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'PocketUnit',
                      border: PRIMARYCOLOR,
                      content: UnitBottomPage(),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.user,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My Account',
                      isBadged: false,
                      isMultiMenu: false,
                      border: PRIMARYCOLOR,
                      content: MyAuto(agent: currentUser.agent,isAdmin: false,),
                    ),

                  ],
                ),
                SliverList(
                    delegate: SliverChildListDelegate(
                  [
                    const SizedBox(height: 20,),
                  ],
                )),
              ],
            )
        )
    );
  }
}
