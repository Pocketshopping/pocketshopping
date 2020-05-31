import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/logistic/vehicle/repository/vehicleObj.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:progress_indicators/progress_indicators.dart';

class MyAuto extends StatefulWidget{

  MyAuto({this.agent});
  final Session agent;
  @override
  _MyAutoState createState() => new _MyAutoState();
}

class _MyAutoState extends State<MyAuto>{

  AutoMobile auto;
  @override
  void initState() {
    LogisticRepo.getAutomobile(widget.agent.agent.autoAssigned).then((value) => setState((){auto=value;}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('My Automobile',style: TextStyle(color: PRIMARYCOLOR),),
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
      body: auto != null ?
      Container(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: auto.autoType == 'MotorBike'?
              Image.asset('assets/images/bike.png'):
              auto.autoType =='Car'?
              Image.asset('assets/images/car.png'):
              auto.autoType =='Van'?
              Image.asset('assets/images/van.png'):
              Center(
                child: Text('${auto.autoType}'),
              ),
            ),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Auto:"),
                          Text("${auto.autoName}")
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Model Number:"),
                          Text("${auto.autoModelNumber}")
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Plate Number:"),
                          Text("${auto.autoPlateNumber}")
                        ],
                      ),
                      SizedBox(height: 10,),
                    ],
                  ),
                )
            ),
        if(widget.agent.user.role == 'Admin')
        Expanded(
          flex: 0,
          child: Row(
            children: [
              Expanded(
                child: FlatButton(
                  onPressed: (){},
                  color: Colors.redAccent,
                  child: Text('Delete'),
                ),
              ),
              Expanded(
                child: FlatButton(
                  onPressed: (){},
                  color: Colors.greenAccent,
                  child: Text('Edit'),
                ),
              )
            ],
          ) ,
        )
          ],
        ),
      ):
      Center(
          child: JumpingDotsProgressIndicator(
            fontSize: MediaQuery.of(context).size.height * 0.12,
            color: PRIMARYCOLOR,
          )),
    );
  }
}