import 'package:flutter/material.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:progress_indicators/progress_indicators.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: JumpingDotsProgressIndicator(
        fontSize: MediaQuery.of(context).size.height * 0.12,
        color: PRIMARYCOLOR,
      )),
    );
  }
}
