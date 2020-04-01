import 'package:flutter/material.dart';
import 'package:pocketshopping/widget/bSheetTemplate.dart';
import 'package:pocketshopping/component/merchantMap.dart';

class BottomSheetMenuWidget extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    return BottomSheetTemplate(
      child:Column(
        children: <Widget>[
          Text("cart"),
        ],
      ),
    );

  }

}

