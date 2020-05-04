import 'package:flutter/material.dart';
import 'package:pocketshopping/component/merchantMap.dart';
import 'package:pocketshopping/widget/bSheetTemplate.dart';

class BottomSheetMapTemplate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomSheetTemplate(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.blue,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.7,
            child: MerchantMap(),
          ),
          Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Text("Address"),
                ],
              )),
        ],
      ),
    );
  }
}
