import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/ui/shared/help.dart';

class Tour extends StatelessWidget{

  final String name;
  Tour({this.name});
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Column(
              children: [
                Expanded(
                  flex: 0,
                  child: SizedBox(height: 20,),
                ),
                Expanded(
                    flex: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text('Hi. $name, Welcome to pocketshopping,',style: TextStyle(fontSize: 25),textAlign: TextAlign.center,),
                        ),
                        SizedBox(height: 30,),
                        Center(
                          child: Text('Would you like to take a tour?',style: TextStyle(fontSize: 18),),
                        )
                      ],
                    )
                ),
                Expanded(
                  child: Image.asset('assets/images/ballon.png'),
                ),
                Expanded(
                  flex: 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: FlatButton(
                          onPressed: (){
                            Get.back();
                          },
                          child: Text("Skip"),
                        ),
                      ),
                      Expanded(
                        child: FlatButton(
                          onPressed: (){
                            Get.off(HelpWebView(page: 'new',showNav: false,));
                          },
                          child: Text("proceed"),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          )
        )
      )
    );
  }
}