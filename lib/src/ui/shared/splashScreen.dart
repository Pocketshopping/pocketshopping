import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motion_widget/motion_widget.dart';
import 'package:pocketshopping/main.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bottom_navigation_badge/bottom_navigation_badge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/admin/ping.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/geofence/geofence.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/request/blank.dart';
import 'package:pocketshopping/src/request/bloc/requestBloc.dart';
import 'package:pocketshopping/src/request/repository/requestRepo.dart';
import 'package:pocketshopping/src/request/request.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/favourite.dart';
import 'package:pocketshopping/src/user/myOrder.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:pocketshopping/src/pocketPay/pocket.dart';

class Splash extends StatefulWidget {
  final UserRepository _userRepository;

  Splash({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splash> {
  MotionExitConfigurations motionExitConfigurations;

  @override
  void initState() {
    super.initState();

    motionExitConfigurations =
        MotionExitConfigurations(durationMs: 1000, displacement: 50);

    Future.delayed(Duration(seconds: 2), () {
      motionExitConfigurations.controller.addStatusListener((status) {
        if (status == AnimationStatus.completed)
          Get.offAll(App(
            userRepository: widget._userRepository,
          )
              //duration: Duration(milliseconds: 800)
              );
      });
      motionExitConfigurations.controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Motion<Row>(
          mainAxisSize: MainAxisSize.min,
          exitConfigurations: motionExitConfigurations,
          children: <Widget>[
            MotionElement(
              child: Image.asset('assets/images/blogo.png'),
              interval: Interval(0.5, 1.0, curve: Curves.easeOutBack),
            )
          ],
        )));
  }

}
