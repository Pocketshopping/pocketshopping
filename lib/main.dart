import 'package:custom_splash/custom_splash.dart';
import 'package:flutter/material.dart';
import 'package:pocketshopping/firebase/BaseAuth.dart';
import 'package:pocketshopping/page/signUp.dart';
import 'package:pocketshopping/page/getStarted.dart';
import 'package:pocketshopping/component/psProvider.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());




class MyApp extends StatelessWidget {

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
        customFunction: duringSplash,
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

