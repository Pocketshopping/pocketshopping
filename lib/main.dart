/*
import 'package:custom_splash/custom_splash.dart';
import 'package:flutter/material.dart';
import 'package:pocketshopping/firebase/BaseAuth.dart';
import 'package:pocketshopping/page/signUp.dart';
import 'package:pocketshopping/page/getStarted.dart';
import 'package:pocketshopping/component/psProvider.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());




class MyApp extends StatelessWidget {



  @override
  Widget build(BuildContext context) {


    return psProvider(
      data: appState,
      child:MaterialApp(
        builder: (context, child) =>
            MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child),
      theme: ThemeData(
        backgroundColor: Colors.transparent,
        bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.black.withOpacity(0)),
      ),
      home: CustomSplash(
        imagePath: 'assets/images/blogo.png',
        backGroundColor: Colors.white,
        animationEffect: 'fade-in',
        logoSize: 200,
        home: ChangeNotifierProvider<Auth>(
    child: GetStartedPage(),
    create:(BuildContext context) {
    return Auth();
          }     ),
        duration: 2000,
        type: CustomSplashType.StaticDuration,
      ),



      )

    );
  }



}

class AppState extends ValueNotifier {

  AppState(value) : super(value);
}
var appState = new AppState({'instanceID':'34','cart':0});

*/

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' as _get;
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/login/login.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/locRepo.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/simple_bloc_delegate.dart';
import 'package:pocketshopping/src/splash_screen.dart';
import 'package:pocketshopping/src/ui/shared/businessSetup.dart';
import 'package:pocketshopping/src/ui/shared/introduction.dart';
import 'package:pocketshopping/src/ui/shared/splashScreen.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
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

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager.initialize(callbackDispatcher, isInDebugMode: false);
  notificationAppLaunchDetails =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
  // of the `IOSFlutterLocalNotificationsPlugin` class
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
        selectNotificationSubject.add(payload);
      });
  await _createNotificationChannel('PocketShopping','PocketShopping','default notification channel for pocketshopping');
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
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
    importance: Importance.Max,
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
    bool enable = await Geolocator().isLocationServiceEnabled();
    final FirebaseMessaging _fcm = FirebaseMessaging();
    GeolocationStatus permit = await Geolocator().checkGeolocationPermissionStatus();
   // Wallet wallet = await WalletRepo.getWallet(inputData['wallet']);
    if(enable){
      if(permit == GeolocationStatus.granted){
        Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high,locationPermissionLevel: GeolocationPermission.locationAlways);
       // final databaseReference = Firestore.instance;
        if(position != null){
          String fcmToken = await _fcm.getToken();
          Geoflutterfire geo = Geoflutterfire();
          GeoFirePoint agentLocation = geo.point(latitude: position.latitude, longitude: position.longitude);
          await LocRepo.update({
            'agentParent':inputData['agentParent'],
            'wallet':inputData['wallet'],
            'agentID':inputData['agentID'],
            'agentLocation':agentLocation.data,
            'agentAutomobile':inputData['agentAutomobile'],
            'agentName':inputData['agentName'],
            'agentTelephone':inputData['agentTelephone'],
            'availability':inputData['availability'],
            'pocket':true,
            'parent':true,
            'remitted':true,
            'busy':false,
            'device':fcmToken,
            'UpdatedAt':Timestamp.now(),
            'workPlaceWallet':inputData['workPlaceWallet']
          });
        }
        //print(position.toString());
      }
      else{
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'PocketShopping', 'PocketShopping', 'LocationUpdate',
          importance: Importance.Default,
          priority: Priority.High,
          ticker: 'ticker',
          icon: 'app_icon',
          ongoing: true,
          enableVibration: true,
          enableLights: true,
          playSound: true,
        );
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            0,
            'Permission',
            'Grant Location Access to PocketShopping',
            platformChannelSpecifics,
            payload: 'LocationUpdate',


        );
      }
    }
    else{
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'PocketShopping', 'PocketShopping', 'LocationUpdate',
        importance: Importance.Default,
        priority: Priority.High,
        ticker: 'ticker',
        icon: 'app_icon',
        ongoing: true,
        enableVibration: true,
        enableLights: true,
        playSound: true,
      );
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        'Location',
        'Enable Location',
        platformChannelSpecifics,
        payload: 'LocationUpdate',


      );
      //print('No location enabled');
    }


    //print("Native called background task at ${DateTime.now().toString()}");
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  final UserRepository _userRepository;

  MyApp({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return _get.GetMaterialApp(
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child),
      theme: ThemeData(
        backgroundColor: Colors.transparent,
        bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.black.withOpacity(0)),
      ),
      home:Splash(userRepository: _userRepository,),
      defaultTransition: _get.Transition.rightToLeftWithFade,
      transitionDuration: Duration(milliseconds: 500),
    );
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
  bool isNew;
  @override
  void initState() {
    processInstallationStatus();
    handleDynamicLinks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Unauthenticated) {

            if (!isNew) {
              return Introduction(userRepository: widget._userRepository,linkdata: state.link,);
            } else {
              return LoginScreen(userRepository: widget._userRepository,linkdata: state.link,);
            }
          }
          if (state is Authenticated) {
            //print('i got here this is me ${state.user.displayName}');
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
          if(state is SetupBusiness){
            return BSetup(userRepository: widget._userRepository,);
          }
          return SplashScreen();
        },
      ),
    );
  }

  Future<bool> processInstallationStatus() async{
    SharedPreferences prefs= await SharedPreferences.getInstance();

    if (prefs.containsKey('uid')) {
      isNew = true;
    } else {
      isNew =  false;
    }
    setState(() {});

    return isNew;
  }

  Future handleDynamicLinks() async {
    //print('i am working');
    final PendingDynamicLinkData data =
    await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(data);
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          _handleDeepLink(dynamicLink);
        }, onError: (OnLinkErrorException e) async {
      //print('Link Failed: ${e.message}');
    });
  }

  void _handleDeepLink(PendingDynamicLinkData data) async {
    final Uri deepLink = data?.link;
    if (deepLink != null) {BlocProvider.of<AuthenticationBloc>(context).add(DeepLink(deepLink));}

  }

}
