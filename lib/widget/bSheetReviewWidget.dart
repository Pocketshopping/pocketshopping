import 'package:flutter/material.dart';
import 'package:pocketshopping/widget/bSheetTemplate.dart';


class BottomSheetReviewWidget extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    return BottomSheetTemplate(
      height: MediaQuery.of(context).size.height*0.8,
      child:Column(
        children: <Widget>[
          Text("Review"),
        ],
      ),
    );

  }

}

