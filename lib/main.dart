import 'package:custom_splash/custom_splash.dart';
import 'package:flutter/material.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/firebase/BaseAuth.dart';
import 'package:pocketshopping/page/curvyPage.dart';
import 'package:pocketshopping/page/introduction.dart';
import 'package:pocketshopping/page/signUp.dart';
import 'package:pocketshopping/page/login.dart';
import 'package:pocketshopping/page/getStarted.dart';
import 'package:pocketshopping/page/business.dart';
import 'package:pocketshopping/page/user.dart';
import 'package:pocketshopping/page/admin.dart';
import 'package:pocketshopping/page/map.dart';
import 'package:pocketshopping/component/MerchantDestination.dart';
import 'package:pocketshopping/page/user/merchant.dart';
import 'package:pocketshopping/component/psProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    SignUpPage.tag: (context) => SignUpPage(),
    LoginPage.tag: (context) => LoginPage(),
    GetStartedPage.tag: (context) => GetStartedPage(),
    BusinessSetUpPage.tag: (context) => BusinessSetUpPage(),
    UserPage.tag: (context) => UserPage(),
    AdminPage.tag: (context) => AdminPage(),
    MapSample.tag: (context) => MapSample(),
    MerchantDestination.tag: (context) => MerchantDestination(),
    MerchantWidget.tag: (context) =>MerchantWidget(),

  };



  Function duringSplash=(){
    //SharedPreferences prefs =  await SharedPreferences.getInstance();
    //print(prefs.containsKey("firstTime"));
    int a=123+23;
    if(a>100)
      return 1;
    else
      return 2;
  };

  Map<int,Widget>op={1:GetStartedPage(),2:SignUpPage()};

  @override
  Widget build(BuildContext context) {



    return psProvider(
      data: appState,
      child:MaterialApp(
        builder: (context, child) =>
            MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child),
      theme: ThemeData(
        backgroundColor: Colors.white,
        bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.black.withOpacity(0.5)),

      ),
      home: CustomSplash(
        imagePath: 'assets/images/blogo.png',
        backGroundColor: Colors.white,
        animationEffect: 'fade-in',
        logoSize: 200,
        home: GetStartedPage(),
        customFunction: duringSplash,
        outputAndHome: op,
        duration: 2500,
        type: CustomSplashType.BackgroundProcess,
      ),



      routes: routes,
      )

    );
  }
}

class AppState extends ValueNotifier {

  AppState(value) : super(value);
}
var appState = new AppState({'instanceID':'34','cart':0});

