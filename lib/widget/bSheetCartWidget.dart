import 'package:flutter/material.dart';
import 'package:pocketshopping/widget/bSheetTemplate.dart';
import 'package:pocketshopping/component/merchantMap.dart';

class BottomSheetCartWidget extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    return BottomSheetTemplate(
      height: MediaQuery.of(context).size.height*0.8,
      child:Column(
        children: <Widget>[
          Text("cart"),
        ],
      ),
    );

  }

}

