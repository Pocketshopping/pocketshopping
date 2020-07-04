import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motion_widget/motion_widget.dart';
import 'package:pocketshopping/main.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';

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


    motionExitConfigurations = MotionExitConfigurations(durationMs: 1000, displacement: 50);

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

    super.initState();
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
