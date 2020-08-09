
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';

class AboutUs extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey,
          ),
          onPressed: () {
            Get.back(result: 'Refresh');
          },
        ),
        title: const Text(
          'AboutUs',
          style: TextStyle(color: PRIMARYCOLOR),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          SizedBox(height: 20,),
          Center(
            child: Image.asset('assets/images/blogo.png'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
            child: Text('$ABOUTUS',textAlign: TextAlign.justify,),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 0),
              child: Text('From',style: TextStyle(fontSize: 20),),
            ),
          ),
          SizedBox(height: 10,),
          Center(
            child: SizedBox(
              height: 100,
              width: 200,
              child: Image.asset('assets/images/fleepage.png')
            ),
          ),
          SizedBox(height: 10,),
        ],
      ),
    );
  }
}