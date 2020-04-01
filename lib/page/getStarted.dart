
import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/firebase/BaseAuth.dart';
import 'package:pocketshopping/model/DataModel/categoryData.dart';
import 'package:pocketshopping/model/DataModel/userData.dart';
import 'package:pocketshopping/page/admin.dart';
import 'package:pocketshopping/page/introduction.dart';
import 'package:pocketshopping/page/login.dart';
import 'package:pocketshopping/page/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketshopping/component/psProvider.dart';

class GetStartedPage extends StatefulWidget {
  static String tag = 'getStarted-page';
  @override
  _GetStartedPageState createState() => new _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {

  var uData;
  String uid='';
  var authHandler = new Auth();
  final FirebaseMessaging _fcm = FirebaseMessaging();

  StreamSubscription iosSubscription;


  @override
  void initState() {
    super.initState();
    uid='';
    processInstallationStatus();

    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        print(data);
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );

  }

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  processInstallationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    psProvider.of(context).value['category']= await CategoryData().getAll();
    if( prefs.containsKey('uid')){
      authHandler.getCurrentUser().then((value) => {

        if(value == null){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()))
        }
        else{
          psProvider.of(context).value['uid']=value.uid,
          UserData(uid: value.uid).getOne().then((value) =>
          {
            psProvider.of(context).value['user']=value,
            value['role'] == 'user' ?
            Navigator.push(context,MaterialPageRoute(builder: (context) => UserPage()))
                :
            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPage()))
          }
          )
        }
      });
    }
    else{
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Introduction()));
    }
  }

  @override
  Widget build(BuildContext context) {

    return

    Container(
          color:Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: CircularProgressIndicator(),
          )
    );


  }
}


