import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/constants/appColor.dart';

class MyAccount extends StatefulWidget{

  @override
  _MyAccountState createState() => new _MyAccountState();
}

class _MyAccountState extends State<MyAccount>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Settings',style: TextStyle(color: PRIMARYCOLOR),),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: false,
        elevation: 0.0,
      ),
      body: Container(),
    );
  }
}