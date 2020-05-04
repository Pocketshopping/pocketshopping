import 'package:flutter/material.dart';
import 'package:pocketshopping/widget/bSheetTemplate.dart';

class BottomSheetMenuWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomSheetTemplate(
      child: Column(
        children: <Widget>[
          Text("cart"),
        ],
      ),
    );
  }
}
