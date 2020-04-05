
import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/firebase/BaseAuth.dart';
import 'package:pocketshopping/model/DataModel/categoryData.dart';
import 'package:pocketshopping/model/DataModel/userData.dart';
import 'package:pocketshopping/page/admin.dart';
import 'package:pocketshopping/page/admin/deepLinkBranch.dart';
import 'package:pocketshopping/page/introduction.dart';
import 'package:pocketshopping/page/login.dart';
import 'package:pocketshopping/page/setUpBusiness.dart';
import 'package:pocketshopping/page/signUp.dart';
import 'package:pocketshopping/page/user.dart';
import 'package:provider/provider.dart';
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
    handleDynamicLinks();
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
      psProvider.of(context).value['route']=1;
        }
        else{
      psProvider.of(context).value['route']=0;
        }


  }

  @override
  Widget build(BuildContext context) {

    return
      Scaffold(

        body: FutureBuilder<FirebaseUser>(
          future: Provider.of<Auth>(context).getCurrentUser(),
          builder: (context, AsyncSnapshot<FirebaseUser> snapshot) { //          ⇐ NEW
            if (snapshot.connectionState == ConnectionState.done) {
              // log error to console                                            ⇐ NEW
              if (snapshot.error != null) {
                print("error");
                return Text(snapshot.error.toString());
              }

              if(snapshot.hasData){
                //UserData(uid: psProvider.of(context).value['uid']).getOne().then((value){
                //psProvider.of(context).value['user']=value;
                //});
                print(snapshot.data.displayName);
                psProvider.of(context).value['user']={'role':snapshot.data.displayName};
                psProvider.of(context).value['uid']=snapshot.data.uid;
                SharedPreferences.getInstance().then((value) => value.setString('uid', snapshot.data.uid));
                switch(snapshot.data.displayName){
                  case 'user':
                    return UserPage();
                    break;
                  case 'admin':
                    return AdminPage();
                    break;
                  case 'staff':
                    return UserPage();
                    break;
                  default:
                    return LoginPage();
                }

              }
              else{
                if(psProvider.of(context).value['route']==1){
                  return SignUpPage();
                }
                else{
                  return Introduction();
                }
              }
              //return snapshot.hasData ? UserPage() : LoginPage();
            } else {
              // show loading indicator                                         ⇐ NEW
              return Container(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        )
      );





  }

  Future handleDynamicLinks() async {
    print('i aam been launched');
    // 1. Get the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData data =
    await FirebaseDynamicLinks.instance.getInitialLink();

    // 2. handle link that has been retrieved
    _handleDeepLink(data);

    // 3. Register a link callback to fire if the app is opened up from the background
    // using a dynamic link.
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          // 3a. handle link that has been retrieved
          _handleDeepLink(dynamicLink);
        }, onError: (OnLinkErrorException e) async {
      print('Link Failed: ${e.message}');
    });
  }

  void _handleDeepLink(PendingDynamicLinkData data)async {
    final Uri deepLink = data?.link;
    if (deepLink != null) {

      psProvider.of(context).value['linkdata']=deepLink.queryParameters;
      FirebaseUser user;
      user = await Auth().getCurrentUser();
      print('user= $user');
      if(user == null ){
        if(psProvider.of(context).value['route']==1){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpPage(linkdata: deepLink.queryParameters,)));

        }
        else{
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Introduction()));

        }

      }
      else{
        psProvider.of(context).value['user']={'role':user.displayName};
        psProvider.of(context).value['uid']=user.uid;
        switch(deepLink.queryParameters['route']){
          case 'branch':
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeepLinkBranch(linkdata: deepLink.queryParameters,)));
            break;
          default:
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpPage(linkdata: deepLink.queryParameters,)));
            break;
        }
      }

    }
  }
}


