import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/admin/package_admin.dart' as admin;
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/admin/product/editProduct.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/agentCompany/agentTracker.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/logistic/vehicle/newVehicle.dart';
import 'package:pocketshopping/src/logistic/vehicle/repository/vehicleObj.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/agent/myAuto.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:http/http.dart' as http;

class AutomobileList extends StatefulWidget {
  final Session user;
  final int callBckActionType;
  final String title;
  AutomobileList({this.user,this.callBckActionType=1,this.title});
  @override
  _AutomobileListState createState() => new _AutomobileListState();
}

class _AutomobileListState extends State<AutomobileList> {
  int get count => list.length;

  Map<String,AutoMobile> list = {};
  bool _finish;
  bool loading;
  bool empty;
  String address ;


  void initState() {
    _finish = true;
    loading =true;
    empty = false;
    LogisticRepo.fetchMyAutomobile(widget.user.merchant.mID, null).then((value){
      //print(value);
      if(mounted)
        setState((){
          list=value;
          loading =false;
          if(list.length >= 10)
            _finish=false;
          else
            _finish=true;

          if(list.isEmpty) {
            empty = true;
            _finish=true;
          }
        });
    });
    super.initState();
  }

  void load() {

    if(list.isNotEmpty)
      LogisticRepo.fetchMyAutomobile(widget.user.merchant.mID, list[list.keys.toList().last]).then((value) {
        if(mounted)
          if(value.isNotEmpty)
            setState((){

              list.addAll(value);
              if(list.length >= 10)
                _finish=false;
              else
                _finish=true;
            });
          else
            setState(() {
              _finish=true;
            });

      });
    else
      LogisticRepo.fetchMyAutomobile(widget.user.merchant.mID, null).then((value) {
        if(mounted)
          if(value.isNotEmpty)
            setState((){
              list.addAll(value);
              if(list.length >= 10)
                _finish=false;
              else
                _finish=true;
            });else
            setState(() {
              _finish=true;
              empty=true;
            });

      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              MediaQuery.of(context).size.height *
                  0.15),
          child: AppBar(
              title: Text(widget.title==null?'${widget.user.merchant.bName} Automobiles':widget.title,style: TextStyle(color: PRIMARYCOLOR),),
              centerTitle: true,
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              elevation: 0.0,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(
                    MediaQuery.of(context).size.height *
                        0.1),
                child: Container(
                    child: TextFormField(
                      controller: null,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search ${widget.user.merchant.bName} Automobiles',
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.2),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                      autofocus: false,
                      enableSuggestions: true,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        if(value.isEmpty){

                          LogisticRepo.fetchMyAutomobile(widget.user.merchant.mID, null).then((value) {
                            if(mounted)
                              setState((){
                                empty = false;
                                list=value;
                                if(list.length >= 10)
                                  _finish=false;
                              });

                          });
                        }
                        else{
                          LogisticRepo.searchMyAutomobile(widget.user.merchant.mID, null,value.trim()).then((result) {

                            if(mounted)
                              setState((){
                                if(result.isNotEmpty) {
                                  list = result;
                                  if (list.length >= 10)
                                    _finish = false;
                                  empty = false;
                                }
                                else {
                                  //list.clear();
                                  empty = true;
                                }

                              });


                          });
                        }
                      },
                    )

                ),

              )
          ),
        ),
        body: Column(
          children: [
            Expanded(
                flex:3,
                child: !loading?
                !empty?
                Container(
                  child: RefreshIndicator(
                    child: LoadMore(
                      isFinish: _finish,
                      onLoadMore: _loadMore,
                      child: ListView.separated(
                        separatorBuilder: (_,i){return const Divider(thickness: 1,);},
                        itemBuilder: (BuildContext context, int index) {

                          return uiType(list.values.toList()[index],list.keys.toList()[index]);
                        },
                        itemCount: count,
                      ),
                      whenEmptyLoad: false,
                      delegate: DefaultLoadMoreDelegate(),
                      textBuilder: (l){
                        switch(l){
                          case LoadMoreStatus.nomore:
                            return '';
                            break;
                          case LoadMoreStatus.loading:
                            return 'Loading.. please wait';
                            break;
                          case LoadMoreStatus.fail:
                            return 'Error';
                            break;
                          default:
                            return 'Loading.. please wait';
                            break;
                        }
                      },
                    ),
                    onRefresh: _refresh,
                  ),
                ):
                ListTile(
                  title: Image.asset('assets/images/empty.gif'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Text(
                          'Empty',
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.06),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "No Automobile added yet",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
                    :
                Center(
                  child: JumpingDotsProgressIndicator(
                    fontSize: MediaQuery.of(context).size.height * 0.12,
                    color: PRIMARYCOLOR,
                  ),
                )
            ),
            Expanded(
              flex: 0,
              child: Container(
                color: PRIMARYCOLOR,
                child:Padding(
                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                  child: Center(
                    child: FlatButton.icon(
                      color: PRIMARYCOLOR,
                      onPressed: (){
                        Get.to(
                            VehicleForm(
                              session: widget.user,
                            )
                        ).then((value) {
                          _refresh();
                        });
                      },
                      icon: Icon(Icons.add,color: Colors.white,),
                      label: Text('New Automobile',style: TextStyle(color: Colors.white),),
                    ),
                  )
                ),
              ),
            )
          ],
        )
    );
  }

  Future<bool> _loadMore() async {
    load();
    return true;
  }

  Future<void> _refresh() async {
    setState(() {
      list.clear();
    });
    load();
  }



  Widget uiType(AutoMobile data,String name){
    switch(widget.callBckActionType){
      case 1:
        return Tracker(data: data,user: widget.user,autoMobileName: name,refresh: _refresh,);
        break;

      default:
        return const SizedBox.shrink();
    }
  }

}

class Tracker extends StatelessWidget{
  const Tracker({this.data,this.user,this.autoMobileName,this.refresh});
  final AutoMobile data;
  final Session user;
  final String autoMobileName;
  final Function refresh;

  @override
  Widget build(BuildContext context) {
    return  ListTile(
        onTap: (){
          Get.bottomSheet(builder: (context){
            return Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    flex:0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text('$autoMobileName',style: TextStyle(fontSize: 20),),
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: const Divider(thickness: 1,),
                  ),
                  Expanded(

                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('Plate Number:'),
                              ),
                              Expanded(
                                child: Text(data.autoPlateNumber),
                              )
                            ],
                          ),
                          const Divider(thickness: 1,),
                          Row(
                            children: [
                              Expanded(
                                child: Text('Model Number:'),
                              ),
                              Expanded(
                                child: Text(data.autoModelNumber),
                              )
                            ],
                          ),
                          const Divider(thickness: 1,),
                          Row(
                            children: [
                              Expanded(
                                child: Text('Auto Type:'),
                              ),
                              Expanded(
                                child: Text(data.autoType),
                              )
                            ],
                          ),
                          const Divider(thickness: 1,),
                          Row(
                            children: [
                              Expanded(
                                child: Text('Auto Name:'),
                              ),
                              Expanded(
                                child: Text(data.autoName),
                              )
                            ],
                          ),
                          const Divider(thickness: 1,),
                          Row(
                            children: [
                              Expanded(
                                child: Text('Auto Added AT:'),
                              ),
                              Expanded(
                                child: Text('${Utility.presentDate(data.autoAddedAt.toDate())}'),
                              )
                            ],
                          ),
                          const Divider(thickness: 1,),
                          Row(
                            children: [
                              Expanded(
                                child: Text('Auto Assigned:'),
                              ),
                              Expanded(
                                child: Text(data.autoAssigned.toString()),
                              )
                            ],
                          ),
                          const Divider(thickness: 1,),
                          data.autoAssigned?
                          FutureBuilder<AgentLocUp>(
                              future: LogisticRepo.getOneAgentLocation((data.assignedTo)),
                              initialData: null,
                              builder: (_, AsyncSnapshot<AgentLocUp> agent){
                                if(agent.hasData){
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Text('Auto Assigned To:'),
                                      ),
                                      Expanded(
                                        child: Text(agent.data.agentName),
                                      )
                                    ],
                                  );
                                }
                                else{
                                  return const SizedBox.shrink();
                                }
                              }
                          ):const SizedBox.shrink(),
                        ],
                      )
                    )
                  ),
                  Expanded(
                    flex:0,
                    child: Container(
                      color: Colors.red,
                      child:Padding(
                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                          child: Center(
                            child: FlatButton.icon(

                              onPressed: ()async{
                                if(data.autoAssigned)
                                  await Utility.infoDialogMaker("You can not delete this automobile because it assigned to an agent. Head to"
                                      " 'manage Agent' and Unassign the agent then you can continue with the deletion");
                                else{
                                  bool result = await Utility.confirmDialogMaker('Are you sure you want to delete this automobile?'
                                      ' Note this action can not be undone.');
                                  if(result){
                                    Get.back();
                                    Utility.bottomProgressLoader(title: 'Automobile',body: 'Deleting $autoMobileName.....please wait');
                                    var autoResult = await LogisticRepo.deleteAutomobile(data.autoID);
                                    Get.back();
                                    if(autoResult){
                                      Utility.bottomProgressSuccess(title: 'Deleted',body: '$autoMobileName has been deleted');
                                    }
                                    else
                                      Utility.bottomProgressFailure(title: 'Error',body: 'Error deleting $autoMobileName, check your network connection and try again');

                                  }
                                }

                              },
                              icon: Icon(Icons.delete,color: Colors.white,),
                              label: Text('Delete',style: TextStyle(color: Colors.white),),
                            ),
                          )
                      ),
                    ),
                  ),
                ],
              )
            );
          }).then((value) {refresh();});
        },
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.withOpacity(0.2),
          backgroundImage: data.autoType == "MotorBike"?AssetImage('assets/images/bike.png'):
          data.autoType == "Car"?AssetImage('assets/images/car.png'):data.autoType == "Van"?AssetImage('assets/images/van.png')
              :AssetImage('assets/images/bike.png')
        ),
        title: Text('$autoMobileName',style: TextStyle(fontSize: 18),),
        subtitle:Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          children: [
            data.autoAssigned?
            FutureBuilder<AgentLocUp>(
                future: LogisticRepo.getOneAgentLocation((data.assignedTo)),
                initialData: null,
                builder: (_, AsyncSnapshot<AgentLocUp> agent){
                  if(agent.hasData){
                    return Row(children: [
                      Text('assigned to: ${agent.data.agentName}',)
                    ]);
                  }
                  else{
                    return Row(
                      children: [
                        data.autoAssigned?
                        Icon(Icons.check,color: Colors.green,):const SizedBox.shrink(),
                        data.autoAssigned?
                        Text('Assigned')
                            :
                        const SizedBox.shrink(),
                      ],
                    );
                  }
                }
            ):const SizedBox.shrink(),
            Row(

              children: [
                Row(
                  children: [
                    !data.autoAssigned?
                    Icon(Icons.close,color: Colors.red,):const SizedBox.shrink(),
                    !data.autoAssigned?
                    Text('Unassigned')
                        :
                    const SizedBox.shrink(),
                  ],
                ),
                Text(data.autoType)
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ],
        ),
        trailing:  Icon(Icons.arrow_forward_ios),
    );
  }
}

