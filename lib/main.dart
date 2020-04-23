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


import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/home_screen.dart';
import 'package:pocketshopping/src/login/login.dart';
import 'package:pocketshopping/src/splash_screen.dart';
import 'package:pocketshopping/src/simple_bloc_delegate.dart';
import 'package:custom_splash/custom_splash.dart';
import 'package:pocketshopping/src/user/package_user.dart';

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


    return MaterialApp(
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
            home: App(userRepository: _userRepository),
            duration: 2000,
            type: CustomSplashType.StaticDuration,
          ),



        );


  }



}

class App extends StatelessWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        backgroundColor: Colors.transparent,
        bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.black.withOpacity(0)),
      ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Unauthenticated) {
            return LoginScreen(userRepository: _userRepository);
          }
          if (state is Authenticated) {
            if(state.user.displayName == 'user')
              return UserScreen(userRepository: _userRepository);
            else if(state.user.displayName == 'admin')
              return AdminScreen(userRepository: _userRepository);
            else if(state.user.displayName == 'staff')
              return StaffScreen(userRepository: _userRepository);
            else
              return HomeScreen(name: state.user.email);
          }
          return SplashScreen();
        },
      ),
    );
  }
}
