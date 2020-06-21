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
  final TextEditingController _limitController = TextEditingController();
  final _autovalidate  = ValueNotifier<bool>(false);
  final _isSelected  = ValueNotifier<List<bool>>([true,false]);
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _assigned  = ValueNotifier<String>("Select");
  Map<String,AutoMobile> autos;
  List<String> autoMobiles;
  String autoHolder;


  @override
  void initState() {
    _isSelected.value = [widget.agent.agentStatus == 0,widget.agent.agentStatus == 1];
    agent = widget.agent;
    _limitController.text = agent.limit.toString();
    autoMobiles = ['Select'];

    if(agent.autoAssigned != 'Unassign')
    LogisticRepo.getAutomobile(agent.autoAssigned).then((value) => setState((){

      auto=value;

      _assigned.value=auto.autoName.isNotEmpty
          ? auto.autoName + '(${auto.autoPlateNumber})'
          : auto.autoType + ' ( ${auto.autoPlateNumber} )';

      autoHolder = auto.autoName.isNotEmpty
          ? auto.autoName + '(${auto.autoPlateNumber})'
          : auto.autoType + ' ( ${auto.autoPlateNumber} )';

      autoMobiles.add(auto.autoName.isNotEmpty
          ? auto.autoName + '(${auto.autoPlateNumber})'
          : auto.autoType + ' ( ${auto.autoPlateNumber} )');

      autoMobiles.add( 'Unassign');

    }));
    else {
      autoMobiles.add('Unassign');
      autoHolder = 'Unassign';
      _assigned.value = 'Unassign';
    }

    LogisticRepo.getAllAutomobile(agent.agentWorkPlace, false).then((value) {
      if(value.isNotEmpty)
      setState(() {
        autos = value;
        autoMobiles.addAll(autos.keys.toList());
      });
    });



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
      body: autoMobiles.length>1 && agentStatistic != null?
      Container(
        child: Column(
          children: [
            auto != null?
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
            ):const SizedBox.shrink(),
            const SizedBox(height: 10,),
            Expanded(flex: 0,child:Center(child: Text('${agentAcct!=null?agentAcct.fname:''}',style: TextStyle(fontSize: 30),),)),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    children: [
                      auto != null?
                      Column(
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
                        ],
                      ):Center(
                        child: Text('${widget.isAdmin?'This agent is not assigned to any automobile. Click on the green button to assign automobile to agent':
                        'You are not assigned to any automobile. Request for automobile'}',
                          style: TextStyle(color: Colors.red),textAlign: TextAlign.center,),
                      ),
                      const SizedBox(height: 10,),
                      Center(child: Text('Collection Limit: $CURRENCY${agent.limit}'),),
                      const SizedBox(height: 20,),
                      const Center(child: Text('Agent Overall Statistic'),),
                      const SizedBox(height: 5,),
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
                    onPressed: (){
                      Get.defaultDialog(
                        title: 'Confirm',
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('State reason for removing this agent'),
                            TextFormField(
                              controller: _limitController,
                              decoration: InputDecoration(
                                  labelText: 'Reason',
                                  hintText: 'Reason',
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: InputBorder.none),
                              keyboardType: TextInputType.number,
                              autocorrect: false,
                              autovalidate: false,
                              maxLengthEnforced: true,
                              maxLength: 120,
                              maxLines: 3,
                              onChanged: (value) {},
                            ),
                          ],
                        ),
                        cancel: FlatButton(
                          onPressed: (){
                            Get.back();
                          },
                          child: Text('No'),
                        ),
                        confirm: FlatButton(
                          onPressed: (){},
                          child: Text('Yes'),
                        )
                      );
                    },
                    color: Colors.redAccent,
                    child: const Text('Delete Agent',style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.greenAccent,
                  child: FlatButton(
                    onPressed: (){
                      Get.bottomSheet(builder: (context){
                        return Container(
                          height: MediaQuery.of(context).size.height / 2 +
                              MediaQuery.of(context).viewInsets.bottom,
                          color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                                child: Text('${agentAcct.fname}',style: TextStyle(fontSize: 28),),
                              ),
                              ValueListenableBuilder(
                                valueListenable: _autovalidate,
                                builder: (_,autoValidate,__){
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Form(
                                            key:_formKey,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        //                   <--- left side
                                                        color: Colors.black12,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.all(
                                                      MediaQuery.of(context).size.width *
                                                          0.02),
                                                  child: TextFormField(
                                                    controller: _limitController,
                                                    decoration: InputDecoration(
                                                        labelText: 'Collection Limit:$CURRENCY',
                                                        hintText: 'Collection Limit:$CURRENCY',
                                                        filled: true,
                                                        fillColor: Colors.grey[200],
                                                        border: InputBorder.none),
                                                    keyboardType: TextInputType.number,
                                                    autocorrect: false,
                                                    autovalidate: autoValidate,
                                                    validator: (value) {
                                                      if (value.isEmpty) {
                                                        return 'Collection Limit can not be empty';
                                                      }
                                                      if ((int.tryParse(value.trim())??0) < 1000) {
                                                        return 'Collection Limit must be greater than $CURRENCY 1000';
                                                      }
                                                      return null;
                                                    },
                                                    onChanged: (value) {},
                                                  ),
                                                ),

                                              ],
                                            )
                                          ),
                                        ),
                                        Expanded(
                                          flex:0,
                                          child: Container(
                                            color: PRIMARYCOLOR,
                                            child: FlatButton(
                                              child: Text('Set',style: TextStyle(color: Colors.white),),
                                              onPressed: ()async{
                                                if(_formKey.currentState.validate()){
                                                  Get.back();
                                                  Utility.bottomProgressLoader(title: 'Changing Agent Limit',body: '...please wait');
                                                  bool result = await LogisticRepo.setAgentLimit(agent.agentID,limit: int.tryParse(_limitController.text)??10000);
                                                  Get.back();
                                                  if(result)
                                                    Utility.bottomProgressSuccess(title: 'Limit Changed',body: '${agentAcct.fname} limit has been changed to $CURRENCY${int.tryParse(_limitController.text)??10000}',goBack: true);
                                                  else
                                                    Utility.bottomProgressFailure(title: 'Error',body: 'Error encountered changing limit check connection and try again');

                                                }
                                                else{
                                                  _autovalidate.value=true;
                                                }
                                              },
                                              color: PRIMARYCOLOR,
                                            ),
                                          )
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20,),
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                                  child: Align(
                                      alignment:Alignment.centerLeft,
                                      child:Text('Agent Status:')),
                                   ),
                              const SizedBox(height: 5,),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                                child:
                                Align(
                                  alignment:Alignment.centerLeft,
                                  child: ValueListenableBuilder(
                                    valueListenable: _isSelected,
                                    builder: (_,isSelected,__){
                                      return ToggleButtons(
                                        borderColor: Colors.blue.withOpacity(0.5),
                                        fillColor: Colors.blue,
                                        borderWidth: 1,
                                        selectedBorderColor: Colors.blue,
                                        selectedColor: Colors.white,
                                        borderRadius: BorderRadius.circular(0),
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              'Unvailable',
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              'Available',
                                            ),
                                          ),
                                        ],
                                        onPressed: (int index) async{
                                          _isSelected.value = [index==0,index==1];
                                          Get.back();
                                          Utility.bottomProgressLoader(title: 'Changing Agent Status',body: '...please wait');
                                          bool result = await LogisticRepo.activateDeactivateAgent(agent.agentID,activate: index == 1?true:false);
                                          Get.back();
                                          if(result)
                                          Utility.bottomProgressSuccess(title: 'Status Changed',body: '${agentAcct.fname} status has been changed');
                                          else
                                            Utility.bottomProgressFailure(title: 'Error',body: 'Error encountered changing status check connection and try again');
                                        },
                                        isSelected: isSelected,
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width,
                                            minWidth: MediaQuery.of(context).size.width*0.25
                                        ),
                                      );
                                    },
                                  )
                                ),
                              ),
                              //auto != null?
                              ValueListenableBuilder(
                                valueListenable: _assigned,
                                builder: (_,String assign,__){
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          //                   <--- left side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                    child:  Column(
                                      children: <Widget>[
                                        Align(
                                            alignment:
                                            Alignment.centerLeft,
                                            child: Text(
                                              "Automobile",
                                              style: TextStyle(
                                                  color: Colors.black54),
                                            )),
                                        Row(
                                          children: [
                                            Expanded(flex: 1,
                                            child:
                                            DropdownButtonFormField<String>(
                                              autovalidate: false,
                                              value: assign,
                                              items: autoMobiles.toSet().toList()
                                                  .map((label) =>
                                                  DropdownMenuItem(
                                                    child: Text(
                                                      label,
                                                      style: TextStyle(
                                                          color: Colors
                                                              .black54),
                                                    ),
                                                    value: label,
                                                  ))
                                                  .toList(),
                                              isExpanded: true,
                                              hint: Text(
                                                  'Automobile'),
                                              decoration: InputDecoration(
                                                  border: InputBorder.none),
                                              onChanged: (String value) {
                                                _assigned.value = value;
                                              },
                                            )
                                              ,),
                                            Expanded(
                                              flex: 0,
                                              child: Container(
                                                color: PRIMARYCOLOR,
                                                child: FlatButton(
                                                  onPressed: ()async{
                                                    if(_assigned.value == 'Select'){
                                                      Utility.infoDialogMaker('Select a valid option');
                                                    }
                                                    else if(_assigned.value == autoHolder){
                                                      Utility.infoDialogMaker('Select other options.');
                                                    }
                                                    else if(_assigned.value == 'Unassign'){
                                                      bool resultTwo;
                                                      bool resultThree;
                                                      var result =await  Utility.confirmDialogMaker('Are you sure you want to unassign automobile from this agent');
                                                      if(result){
                                                        Get.back();
                                                        Utility.bottomProgressLoader(title: 'Reassigning Agent',body: '...please wait');
                                                        bool resultOne = await LogisticRepo.updateAgent(agent.agentID, {
                                                          'autoAssigned':'Unassign',
                                                          'autoType':'',

                                                        });
                                                        if(resultOne)
                                                        resultTwo = await LogisticRepo.updateAgentLoc(agent.agentID, {
                                                          'autoAssigned':false,
                                                          'agentAutomobile':'',

                                                        });
                                                        if(resultTwo)
                                                          resultThree = await LogisticRepo.reAssignAutomobile(auto.autoID,"",isAssigned: false);

                                                        Get.back();
                                                        if(resultThree)
                                                          Utility.bottomProgressSuccess(title: 'Reassignment Complete',body: '${agentAcct.fname} has been Reassigned',goBack: true);
                                                        else
                                                          Utility.bottomProgressFailure(title: 'Error',body: 'Error encountered Reassigning agent check connection and try again');

                                                      }

                                                    }
                                                    else{

                                                      bool resultTwo;
                                                      bool resultThree;



                                                      var result =await  Utility.confirmDialogMaker('Are you sure you want to assign $assign to ${agentAcct.fname}');
                                                      //autos[assign]
                                                      if(result){
                                                        Get.back();
                                                        if(_assigned.value != 'Unassign' ){
                                                          await LogisticRepo.reAssignAutomobile(auto.autoID,"",isAssigned: false);
                                                        }
                                                        Utility.bottomProgressLoader(title: 'Reassigning Agent',body: '...please wait');
                                                        bool resultOne = await LogisticRepo.updateAgent(agent.agentID, {
                                                          'autoAssigned':autos[assign].autoID,
                                                          'autoType':autos[assign].autoType,

                                                        });
                                                        if(resultOne)
                                                          resultTwo = await LogisticRepo.updateAgentLoc(agent.agentID, {
                                                            'autoAssigned':true,
                                                            'agentAutomobile':autos[assign].autoType,

                                                          });
                                                        if(resultTwo)
                                                          resultThree = await LogisticRepo.reAssignAutomobile(autos[assign].autoID,agent.agentID,isAssigned: true);

                                                        Get.back();
                                                        if(resultThree)
                                                          Utility.bottomProgressSuccess(title: 'Reassignment Complete',body: '${agentAcct.fname} has been Reassigned',goBack: true);
                                                        else
                                                          Utility.bottomProgressFailure(title: 'Error',body: 'Error encountered Reassigning agent check connection and try again');

                                                      }

                                                    }
                                                  },

                                                  child: Text('Save',style: TextStyle(color: Colors.white),),
                                                ),
                                              )
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                  );
                                },
                              )
                                  //:const SizedBox.shrink(),
                            ],
                          ),
                        );
                      },
                        isScrollControlled: true,
                      ).then((value) => null);
                    },
                    color: Colors.greenAccent,
                    child: const Text('Edit Agent',style: TextStyle(color: Colors.black54),),
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