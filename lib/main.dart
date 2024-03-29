import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' as _get;
import 'package:pocketshopping/src/admin/product/bloc/categoryBloc.dart';
import 'package:pocketshopping/src/admin/product/bloc/refreshBloc.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/geofence/bloc/geofenceRefreshBloc.dart';
import 'package:pocketshopping/src/login/login.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/locRepo.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/server/bloc/serverBloc.dart';
import 'package:pocketshopping/src/server/bloc/sessionBloc.dart';
import 'package:pocketshopping/src/server/server.dart';
import 'package:pocketshopping/src/simple_bloc_delegate.dart';
import 'package:pocketshopping/src/splash_screen.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/ui/shared/businessSetup.dart';
import 'package:pocketshopping/src/ui/shared/introduction.dart';
import 'package:pocketshopping/src/ui/shared/splashScreen.dart';
import 'package:pocketshopping/src/ui/shared/verifyAccountWidget.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/user/riderScreen.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';





final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();
final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();
NotificationAppLaunchDetails notificationAppLaunchDetails;
class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async{
  if (message.containsKey('data')) {
    final dynamic data = message['data'];
    //debugPrint('movieTitle: wwerwe');
  }
  if (message.containsKey('notification')) {
    final dynamic notification = message['notification'];
  }



}



void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager.initialize(callbackDispatcher, isInDebugMode: false);
  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  await Firebase.initializeApp();
  final UserRepository userRepository = UserRepository(firebaseAuth: FirebaseAuth.instance);
  await _createNotificationChannel('PocketShopping','PocketShopping','default notification channel for pocketshopping');


/*  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );*/


/*  var channel = const MethodChannel('com.example/background_service');
  var callbackHandle = PluginUtilities.getCallbackHandle(backgroundMain);
  channel.invokeMethod('startService', callbackHandle.toRawHandle());
  ListenerService().startListening();*/

  /*var initializationSettingsAndroid = AndroidInitializationSettings('app_icon',);
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
*/

/*  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
        selectNotificationSubject.add(payload);
      });*/

  //await _createNotificationChannel('PocketShopping','PocketShopping','default notification channel for pocketshopping');

/*  final scheduler = NeatPeriodicTaskScheduler(
    interval: Duration(seconds: 30),
    name: 'hello-world',
    timeout: Duration(seconds: 5),
    task: () async => debugPrint('Hello World'),
    minCycle: Duration(seconds: 5),
  );

  scheduler.start();
  await ProcessSignal.sigterm.watch().first;
  //await scheduler.stop();*/

  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(
        userRepository: userRepository,
      )..add(AppStarted()),
      child: MyApp(userRepository: userRepository),
    ),
  );


}

Future<void> _createNotificationChannel(String id, String name,
    String description) async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var androidNotificationChannel = AndroidNotificationChannel(
    id,
    name,
    description,
    enableLights: true,
    playSound: true,
    importance: Importance.high,
    enableVibration: true,
    showBadge: true,

  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidNotificationChannel);
}

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData)async{

    if(task == "LocationUpdateTask"){
      try{
        await Firebase.initializeApp();
        final prefs = await SharedPreferences.getInstance();
        bool enable = await isLocationServiceEnabled();
        final FirebaseMessaging _fcm = FirebaseMessaging();
        await _fcm.autoInitEnabled();
        LocationPermission permit = await checkPermission();
        String currentMerchant = prefs.getString('merchant');
        if(currentMerchant.isEmpty){
          if(enable){
            if(permit == LocationPermission.always || permit == LocationPermission.whileInUse){
              Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation,);
              if(position != null){
                String fcmToken = await FirebaseMessaging().getToken();
                Geoflutterfire geo = Geoflutterfire();
                GeoFirePoint agentLocation = geo.point(latitude: position.latitude, longitude: position.longitude);
                await LocRepo.update({
                  'agentParent':prefs.getString('agentParent'),
                  'wallet':prefs.getString('wallet'),
                  'agentID':prefs.getString('agentID'),
                  'agentLocation':agentLocation.data,
                  'agentAutomobile':prefs.getString('agentAutomobile'),
                  'agentName':prefs.getString('agentName'),
                  'agentTelephone':prefs.getString('agentTelephone'),
                  'availability':prefs.getBool('availability'),
                  'pocket':true,
                  'parent':true,
                  'remitted':true,
                  'busy':false,
                  'device':fcmToken,
                  'UpdatedAt':Timestamp.now(),
                  'address':await Utility.address(position),
                  'workPlaceWallet':prefs.getString('workPlaceWallet'),
                  'profile':prefs.getString('profile'),
                  'limit':prefs.getInt('limit'),
                  'index':Utility.makeIndexList(prefs.getString('agentName')),
                  'autoAssigned':prefs.getBool('autoAssigned'),
                });
              }
            }
            else{
              await Utility.localNotifier("PocketShopping", "Permission", 'Permission', 'Grant Location Access to PocketShopping');
            }
          }
          else{
            await Utility.localNotifier("PocketShopping", "Location", 'Location', 'Enable Location');
          }
        }
        else{

          int count = await OrderRepo.getLogisticUnclaimedDelivery(currentMerchant);


          if(count>0)
           {
             //debugPrint('ewewvxc xzczx $currentMerchant ($count)');
             await Utility.localNotifier("PocketShopping", "PocketShopping", "Request", 'There is a Delivery request in request bucket. check it out');
           }

        }
      }catch(_){//debugPrint(_);
      }
    }
   /* else if(task  == 'LogisticRequestUpdateTask'){
     try{
       final prefs = await SharedPreferences.getInstance();
       String currentMerchant = prefs.getString('merchant');
       int count = await OrderRepo.getLogisticUnclaimedDelivery(currentMerchant);
       if(count>0)
         Utility.localNotifier("PocketShopping", "PocketShopping", "Delivery Request", 'There is a Delivery request in request bucket. check it out');
       debugPrint(count.toString());
     }catch(_){

     }
    }*/
    return true;
  });
}

class MyApp extends StatefulWidget {
  final UserRepository _userRepository;
  MyApp({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  //Stream<Map<String,dynamic>> _serverStream;
  @override
  void initState() {
    initConfigure();
    //Firestore.instance.settings(cacheSizeBytes: 200000,persistenceEnabled: true);
    //Stream<Map<String,dynamic>> _serverStream;
    //_serverStream = ServerBloc.instance.serverStream
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return _get.GetMaterialApp(
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child),
      theme: ThemeData(
        backgroundColor: Colors.transparent,
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.black.withOpacity(0)),
      ),
      home:Splash(userRepository:widget._userRepository,),
      defaultTransition: _get.Transition.rightToLeftWithFade,
      //transitionDuration: Duration(milliseconds: 500),
    );
  }
  initConfigure() {
    if (Platform.isIOS) _iosPermission();
    _fcm.requestNotificationPermissions();
    _fcm.setAutoInitEnabled(true);
    _fcm.autoInitEnabled();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
       // _fcm.onTokenRefresh;
        final notification = LocalNotification("notification", Map<String, dynamic>.from(message));
        NotificationsBloc.instance.newNotification(notification);
      },
      onLaunch: (Map<String, dynamic> message) async {
       // _fcm.onTokenRefresh;
        final notification = LocalNotification("notification", Map<String, dynamic>.from(message));
        NotificationsBloc.instance.newNotification(notification);
      },
      onResume: (Map<String, dynamic> message) async {
        //_fcm.onTokenRefresh;
        final notification = LocalNotification("notification", Map<String, dynamic>.from(message));
        NotificationsBloc.instance.newNotification(notification);
      },
      //onBackgroundMessage: myBackgroundMessageHandler,
    );
  }

  _iosPermission() {
    _fcm.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
    _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
    });
  }
}

class App extends StatefulWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  AppState createState() => new AppState();
}

class AppState extends State<App> {

  @override
  void initState() {
    SessionBloc.instance.addSession(widget._userRepository);
    ProductRefreshBloc.instance.addNextRefresh(DateTime.now());
    GeofenceRefreshBloc.instance.addNextRefresh(DateTime.now());
    CategoryBloc.instance.addNewCategory([]);
    handleDynamicLinks();
    /*widget._userRepository.getCurrentUser().then((value) {
      print('${value.displayName}');
    });*/
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: ServerRepo.get(),
        builder: (context,AsyncSnapshot<Map<String,dynamic>>snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return FutureBuilder<bool>(
              future: Future.delayed(Duration(seconds: 15)),
              initialData: false,
              builder: (context,AsyncSnapshot<bool> result){
                if(result.connectionState == ConnectionState.waiting){
                  return LoadingScreen();
                }
                else{
                  if(result.hasError){
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: Image.asset('assets/images/blogo.png'),),
                        Center(child:
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                          child: Text('Error connecting to server. Ensure you have internet connection',textAlign: TextAlign.center,),
                        )
                        ),
                        Center(
                          child: FlatButton(
                            onPressed: (){
                              setState(() {});
                            },
                            color: PRIMARYCOLOR,
                            child: Text('Retry',style: TextStyle(color: Colors.white),),
                          ),
                        )
                      ],
                    );
                  }
                  else{
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: Image.asset('assets/images/blogo.png'),),
                        Center(child:
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                          child: Text('Error connecting to server. Ensure you have internet connection',textAlign: TextAlign.center,),
                        )
                        ),
                        Center(
                          child: FlatButton(
                            onPressed: (){
                              setState(() {});
                            },
                            color: PRIMARYCOLOR,
                            child: Text('Retry',style: TextStyle(color: Colors.white),),
                          ),
                        )
                      ],
                    );
                  }
                }
              },
            );
          }
          else if(snapshot.hasError){
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Image.asset('assets/images/blogo.png'),),
                Center(child:
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                  child: Text('Error connecting to server. Ensure you have internet connection',textAlign: TextAlign.center,),
                )
                ),
                Center(
                  child: FlatButton(
                    onPressed: (){
                      setState(() {});
                    },
                    color: PRIMARYCOLOR,
                    child: Text('Retry',style: TextStyle(color: Colors.white),),
                  ),
                )
              ],
            );
          }
          else{
            if((snapshot.data['key']as String).isNotEmpty){
              ServerBloc.instance.addServer(snapshot.data);
              return BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {


          if (state is Started) return LoadingScreen();
          if (state is Uninitialized) {
            //print('Uninitialized');
            return Introduction(userRepository: widget._userRepository,linkdata: state.link,);}
          if (state is Unauthenticated)return LoginScreen(userRepository: widget._userRepository,linkdata: state.link,);


          if (state is Authenticated) {
            //print(state.props[1]);
          if (state.user.displayName == 'user')
          return UserScreen(userRepository: widget._userRepository);
          else if (state.user.displayName == 'admin')
          return AdminScreen(userRepository: widget._userRepository);
          else if (state.user.displayName == 'staff')
          return StaffScreen(userRepository: widget._userRepository);
          else if (state.user.displayName == 'rider')
          return RiderScreen(userRepository: widget._userRepository);
          else
          return LoginScreen(userRepository: widget._userRepository);
          }
          if (state is DLink) {
            //print(state.props[1]);

            if (state.user.displayName == 'user')
              return UserScreen(userRepository: widget._userRepository,merchant: (state.props[1] as Uri).queryParameters['merchant'],route: 1,);
            else if (state.user.displayName == 'admin')
              return AdminScreen(userRepository: widget._userRepository,merchant: (state.props[1] as Uri).queryParameters['merchant'],route: 1,);
            else if (state.user.displayName == 'staff')
              return StaffScreen(userRepository: widget._userRepository,merchant: (state.props[1] as Uri).queryParameters['merchant'],route: 1,);
            else if (state.user.displayName == 'rider')
              return RiderScreen(userRepository: widget._userRepository,merchant: (state.props[1] as Uri).queryParameters['merchant'],route: 1,);
            else
              return LoginScreen(userRepository: widget._userRepository,);

          }
          if(state is SetupBusiness)return BSetup(userRepository: widget._userRepository,);
          if (state is VerifyAccount)return VerifyAccountWidget();

          return LoadingScreen();
          },
          );
          }
            else{
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Image.asset('assets/images/blogo.png'),),
                  Center(child:

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                      child: Text('Error connecting to server. Ensure you have internet connection',style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                    )

                    ,),
                  Center(
                    child: FlatButton(
                      onPressed: (){
                        setState(() {});
                      },
                      color: PRIMARYCOLOR,
                      child: Text('Retry',style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              );
            }
          }
        },
      )
    );
  }

  Future handleDynamicLinks() async {
    final PendingDynamicLinkData data =
    await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(data);
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          _handleDeepLink(dynamicLink);
        }, onError: (OnLinkErrorException e) async {
    });
  }

  void _handleDeepLink(PendingDynamicLinkData data) async {
    final Uri deepLink = data?.link;
    if (deepLink != null) {BlocProvider.of<AuthenticationBloc>(context).add(DeepLink(deepLink));}

  }

}
