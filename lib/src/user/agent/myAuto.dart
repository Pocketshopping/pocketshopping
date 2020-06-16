import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/logistic/vehicle/repository/vehicleObj.dart';
import 'package:pocketshopping/src/statistic/agentStatistic/agentStatistic.dart';
import 'package:pocketshopping/src/statistic/repository.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';

class MyAuto extends StatefulWidget{

  MyAuto({this.agent,this.isAdmin=false});
  final Agent agent;
  final bool isAdmin;
  @override
  _MyAutoState createState() => new _MyAutoState();
}

class _MyAutoState extends State<MyAuto>{

  AutoMobile auto;
  AgentStatistic agentStatistic;
  Agent agent;
  User agentAcct;
  @override
  void initState() {
    agent = widget.agent;
    LogisticRepo.getAutomobile(agent.autoAssigned).then((value) => setState((){auto=value;}));
    StatisticRepo.getAgentStatistic(agent.agent).then((value) => setState((){agentStatistic=value;}));
    UserRepo.getOneUsingUID(agent.agent).then((value) => setState((){agentAcct=value;}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('My Automobile',style: TextStyle(color: PRIMARYCOLOR),),
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
      body: auto != null && agentStatistic != null?
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
            Expanded(flex: 0,child:Center(child: Text('${agentAcct!=null?agentAcct.fname:''}'),)),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Auto:"),
                          Text("${auto.autoName}")
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Model Number:"),
                          Text("${auto.autoModelNumber}")
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Plate Number:"),
                          Text("${auto.autoPlateNumber}")
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Divider(thickness: 1,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Center(
                                    child: Text('$CURRENCY ${Utility.numberFormatter(agentStatistic.totalAmount)}',style: TextStyle(fontSize: 20),),
                                  ),
                                  Center(
                                    child: Text('Total Money Generated',textAlign: TextAlign.center,),
                                  )
                                ],
                              ),
                            )
                          ),
                          Expanded(flex:0,child: Container(color: Colors.grey[400], height: 50, width: 1,),),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Center(
                                    child: Text(' ${Utility.numberFormatter((agentStatistic.totalDistance/1609).round())} Mile(s)',style: TextStyle(fontSize: 20),),
                                  ),
                                  Center(
                                    child: Text('Total Milage',textAlign: TextAlign.center,),
                                  )
                                ],
                              ),
                            )
                          )
                        ],
                      ),
                      const SizedBox(height: 20,),
                      const Divider(thickness: 1,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Center(
                                      child: Text(' ${Utility.numberFormatter(agentStatistic.totalOrderCount)}',style: TextStyle(fontSize: 20),),
                                    ),
                                    Center(
                                      child: Text('Total Delivery',textAlign: TextAlign.center,),
                                    )
                                  ],
                                ),
                              )
                          ),
                          Expanded(flex:0,child: Container(color: Colors.grey[400], height: 50, width: 1,),),
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Center(
                                      child: Text(' ${Utility.numberFormatter((agentStatistic.totalOrderCount-agentStatistic.totalCancelled))}',style: TextStyle(fontSize: 20),),
                                    ),
                                    Center(
                                      child: Text('Total Completed Delivery',textAlign: TextAlign.center,),
                                    )
                                  ],
                                ),
                              )
                          )
                        ],
                      ),
                      const SizedBox(height: 20,),
                      const Divider(thickness: 1,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Center(
                                      child: Text(' ${Utility.numberFormatter(agentStatistic.totalCancelled)}',style: TextStyle(fontSize: 20),),
                                    ),
                                    Center(
                                      child: Text('Total Cancelled Delivery',textAlign: TextAlign.center,),
                                    )
                                  ],
                                ),
                              )
                          ),
                          Expanded(flex:0,child: Container(color: Colors.grey[400], height: 50, width: 1,),),
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Center(
                                      child: Text(' ${Utility.numberFormatter(agentStatistic.totalUnitUsed)}',style: TextStyle(fontSize: 20),),
                                    ),
                                    Center(
                                      child: Text('Total Unit Used',textAlign: TextAlign.center,),
                                    )
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                      const Divider(thickness: 1,),
                    ],
                  ),
                )
            ),
        if(widget.isAdmin)
        Expanded(
          flex: 0,
          child: Row(
            children: [

              Expanded(
                child: Container(
                  color: Colors.redAccent,
                  child: FlatButton(
                    onPressed: (){},
                    color: Colors.redAccent,
                    child: const Text('Delete'),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    onPressed: (){},
                    color: Colors.greenAccent,
                    child: const Text('Edit'),
                  ),
                )
              )
            ],
          ) ,
        ),
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