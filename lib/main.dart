import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' as _get;
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/login/login.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/locRepo.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/simple_bloc_delegate.dart';
import 'package:pocketshopping/src/splash_screen.dart';
import 'package:pocketshopping/src/ui/shared/businessSetup.dart';
import 'package:pocketshopping/src/ui/shared/introduction.dart';
import 'package:pocketshopping/src/ui/shared/splashScreen.dart';
import 'package:pocketshopping/src/ui/shared/verifyAccountWidget.dart';
import 'package:pocketshopping/src/user/package_user.dart';
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
    debugPrint('movieTitle: wwerwe');
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
  final UserRepository userRepository = UserRepository();
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
    importance: Importance.High,
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
      final prefs = await SharedPreferences.getInstance();
      double lat;
      double lng;
      double distance;
      try{
        bool enable = await Geolocator().isLocationServiceEnabled();
        final FirebaseMessaging _fcm = FirebaseMessaging();
        GeolocationStatus permit = await Geolocator().checkGeolocationPermissionStatus();
        if(enable){
          if(permit == GeolocationStatus.granted){
            Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high,locationPermissionLevel: GeolocationPermission.locationAlways);
            if(position != null){
              String fcmToken = await _fcm.getToken();
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


              //prefs.setDouble('riderLat', position.latitude);
              //prefs.setDouble('riderLng', position.longitude);
            }
          }
          else{
            Utility.localNotifier("PocketShopping", "PocketShopping", 'Permission', 'Grant Location Access to PocketShopping');
          }
        }
        else{
          Utility.localNotifier("PocketShopping", "PocketShopping", 'Location', 'Enable Location');
        }
      }catch(_){debugPrint(_);}
    }
    else if(task  == 'DeliveryRequestUpdateTask'){
     try{
       final prefs = await SharedPreferences.getInstance();
       String currentAgent = prefs.getString('rider');
       int count = await OrderRepo.getUnclaimedDelivery(currentAgent);
       if(count>0)
         Utility.localNotifier("PocketShopping", "PocketShopping",
             "Delivery Request", 'New Delivery request. view dashboard to accept');
     }catch(_){debugPrint(_);}
    }
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
  @override
  void initState() {
    initConfigure();
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
      transitionDuration: Duration(milliseconds: 500),
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
      onBackgroundMessage: myBackgroundMessageHandler,
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
    handleDynamicLinks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {

          if (state is Started) return LoadingScreen();
          if (state is Uninitialized) return Introduction(userRepository: widget._userRepository,linkdata: state.link,);
          if (state is Unauthenticated)return LoginScreen(userRepository: widget._userRepository,linkdata: state.link,);


         if (state is Authenticated) {
            if (state.user.displayName == 'user')
              return UserScreen(userRepository: widget._userRepository);
            else if (state.user.displayName == 'admin')
              return AdminScreen(userRepository: widget._userRepository);
            else if (state.user.displayName == 'staff')
              return StaffScreen(userRepository: widget._userRepository);
            else
              return LoginScreen(userRepository: widget._userRepository);
          }
          if (state is DLink) {
            print(state.props[1]);
          }
          if(state is SetupBusiness)return BSetup(userRepository: widget._userRepository,);
          if (state is VerifyAccount)return VerifyAccountWidget();

          return LoadingScreen();
        },
      ),
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
