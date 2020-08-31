import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:progress_indicators/progress_indicators.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: JumpingDotsProgressIndicator(
        fontSize: Get.height * 0.12,
        color: PRIMARYCOLOR,
      )),
    );
  }
}
