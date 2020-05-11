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
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' as _get;
import 'package:pocketshopping/src/ui/shared/introduction.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/home_screen.dart';
import 'package:pocketshopping/src/login/login.dart';
import 'package:pocketshopping/src/splash_screen.dart';
import 'package:pocketshopping/src/simple_bloc_delegate.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketshopping/src/ui/shared/splashScreen.dart';
import 'package:pocketshopping/src/ui/shared/businessSetup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  }

  Future handleDynamicLinks() async {
    print('i am working');
    final PendingDynamicLinkData data =
    await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(data);
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          _handleDeepLink(dynamicLink);
        }, onError: (OnLinkErrorException e) async {
      print('Link Failed: ${e.message}');
    });
  }

  void _handleDeepLink(PendingDynamicLinkData data) async {
    final Uri deepLink = data?.link;
    if (deepLink != null) {BlocProvider.of<AuthenticationBloc>(context).add(DeepLink(deepLink));}

  }




}
