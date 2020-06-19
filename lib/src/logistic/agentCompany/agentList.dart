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
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/agent/myAuto.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:http/http.dart' as http;

class AgentList extends StatefulWidget {
  final Session user;
  final int callBckActionType;
  final String title;
  AgentList({this.user,this.callBckActionType=1,this.title});
  @override
  _AgentListState createState() => new _AgentListState();
}

class _AgentListState extends State<AgentList> {
  int get count => list.length;

  List<AgentLocUp> list = [];
  bool _finish;
  bool loading;
  bool empty;
  String address ;


  void initState() {
    _finish = true;
    loading =true;
    empty = false;
    LogisticRepo.fetchMyAgents(widget.user.merchant.mID, null).then((value){
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
      LogisticRepo.fetchMyAgents(widget.user.merchant.mID, list.last).then((value) {
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
      LogisticRepo.fetchMyAgents(widget.user.merchant.mID, null).then((value) {
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
              title: Text(widget.title==null?'${widget.user.merchant.bName} Agent(s)':widget.title,style: TextStyle(color: PRIMARYCOLOR),),
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
                        hintText: 'Search ${widget.user.merchant.bName} Agent(s)',
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

                          LogisticRepo.fetchMyAgents(widget.user.merchant.mID, null).then((value) {
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
                          LogisticRepo.searchMyAgent(widget.user.merchant.mID, null,value.trim()).then((result) {

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
                      child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {

                          return Column(
                            children: [
                              uiType(list[index]),
                              const Divider(thickness: 1,),
                            ],
                          );
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
                                "No Agent added yet",
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

  callBackAction(int type,dynamic item)async{
    switch(type){
      case 1:
        Get.to(AgentTracker(agent: (item as AgentLocUp),)).then((value) => null);
      break;
    }
  }

  Widget uiType(dynamic data){
    switch(widget.callBckActionType){
      case 1:
        return Tracker(data: data,user: widget.user);
      break;
      case 2:
        return Clearance(data: data,user: widget.user,refresh: _refresh,);
        break;
      case 3:
        return Manage (data: data,user: widget.user,refresh: _refresh,);
        break;

      default:
        return const SizedBox.shrink();
    }
  }

}

class Tracker extends StatelessWidget{
  const Tracker({this.data,this.user});
  final dynamic data;
  final Session user;

  @override
  Widget build(BuildContext context) {
    return  ListTile(
        onTap: (){
          Get.to(AgentTracker(agent: (data as AgentLocUp),)).then((value) => null);
        },
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.withOpacity(0.2),
          backgroundImage: NetworkImage(data.profile.isNotEmpty?data.profile:PocketShoppingDefaultAvatar,
          ),
        ),
        title: Text('${data.agentName}',style: TextStyle(fontSize: 18),),
        subtitle:Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(

              children: [
                Text('${data.agentAutomobile}',),

                Row(
                  children: [
                    data.availability && Utility.isOperational(user.merchant.bOpen, user.merchant.bClose)?
                    Icon(Icons.check,color: Colors.green,):
                    Icon(Icons.close,color: Colors.red,),
                    data.availability && Utility.isOperational(user.merchant.bOpen, user.merchant.bClose)?
                    Text('Available')
                        :
                    Text('Unavailable')
                  ],
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            if(data.availability && Utility.isOperational(user.merchant.bOpen, user.merchant.bClose))
              Row(
                children: [
                  Expanded(
                    child: Text('${data.address} (last updated: ${Utility.presentDate(DateTime.parse(data.agentUpdateAt.toDate().toString()))})'),
                  )
                ],
              )
          ],
        )
    );
  }
}


class Clearance extends StatelessWidget{
   Clearance({this.data,this.user,this.remittance,this.refresh});
  final dynamic data;
  final Session user;
  final Map<String,dynamic> remittance;
  final Function refresh;


  final _clearing  = ValueNotifier<bool>(false);



  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<Map<String,dynamic>>(
      future: LogisticRepo.getRemittance( (data as AgentLocUp).wallet,limit:(data as AgentLocUp).limit),
      initialData: null,
      builder: (_, AsyncSnapshot<Map<String,dynamic>> remit){
        if(remit.hasData){
          return ListTile(
              onTap: (){
                Get.bottomSheet(builder: (context){
                  return Container(
                    height: MediaQuery.of(context).size.height*0.35,
                    color: Colors.white,
                    child: Column(
                      children: [
                        Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                          child: Text('${data.agentName}',style: TextStyle(fontSize: 30),
                        ),
                        )
                        ),
                        Text('Current cash',),
                        Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                          child: Text('$CURRENCY${remit.data['total']}',style: TextStyle(fontSize: 26),
                          ),
                        )
                        ),

                        remit.data['remittance']?
                            Column(
                              children: [
                                Center(child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                                  child: Text('${remit.data['remittanceID']}',style: TextStyle(fontSize: 18),
                                  ),
                                )
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                  child: ValueListenableBuilder(
                                    valueListenable: _clearing,
                                    builder: (_,bool clearing,__){
                                      return !clearing?
                                      FlatButton(
                                        onPressed: ()async{
                                          
                                          _clearing.value =true;
                                          var result =await Utility.clearRemittance(remit.data['remittanceID']);
                                          if(result != null){
                                            _clearing.value =false;
                                            if(result){
                                              Get.back();
                                              GetBar(
                                                title: 'Clearance',
                                                messageText: Text('${data.agentName} has been cleared',style: TextStyle(color: Colors.white),),
                                                snackPosition: SnackPosition.BOTTOM,
                                                backgroundColor: PRIMARYCOLOR,
                                                duration: Duration(seconds: 5),
                                              ).show();
                                              confirmClearanceNotifier((data as AgentLocUp).device).then((value) => null);
                                            }
                                            else{
                                              Get.back();
                                              GetBar(
                                                title: 'Clearance',
                                                messageText: Text('Error clearing ${data.agentName}. Check your connection and try again',style: TextStyle(color: Colors.white),),
                                                snackPosition: SnackPosition.BOTTOM,
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 5),
                                              ).show();
                                            }
                                          }
                                          else{
                                            Get.back();
                                            GetBar(
                                              title: 'Clearance',
                                              messageText: Text('Error clearing ${data.agentName}. Check your connection and try again',style: TextStyle(color: Colors.white),),
                                              snackPosition: SnackPosition.BOTTOM,
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 5),
                                            ).show();
                                          }
                                          },
                                        color: PRIMARYCOLOR,
                                        child: Center(
                                          child: Text('Clear',style: TextStyle(color: Colors.white),),
                                        ),
                                      ):CircularProgressIndicator();
                                    },
                                  )
                                )
                              ],
                            )
                            :
                            const SizedBox.shrink(),


                      ],
                    ),
                  );
                }).then((value) {refresh();} );
              },
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.withOpacity(0.2),
                backgroundImage: NetworkImage(data.profile.isNotEmpty?data.profile:PocketShoppingDefaultAvatar,
                ),
              ),
              title: Text('${data.agentName}',style: TextStyle(fontSize: 18),),
              subtitle:Column(
                //mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(

                    children: [
                      Text('$CURRENCY${remit.data['total']}',),

                      Row(
                        children: [
                          !remit.data['remittance']?
                          Icon(Icons.check,color: Colors.green,):
                          Icon(Icons.close,color: Colors.red,),
                          !remit.data['remittance']?
                          Text('No Pending Clearance')
                              :
                          Text('Pending Clearance')
                        ],
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  if(remit.data['remittance'])
                  Row(
                    children: [
                      Expanded(
                        child: Text('Pending clearance with ID:${remit.data['remittanceID']} '),
                      )
                    ],
                  )
                ],
              )
          );
        }
        else{
          return Container(
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: ListSkeleton(
              style: SkeletonStyle(
                theme: SkeletonTheme.Light,
                isShowAvatar: false,
                barCount: 3,
                colors: [
                  Colors.grey.withOpacity(0.5),
                  Colors.grey,
                  Colors.grey.withOpacity(0.5)
                ],
                isAnimation: true,
              ),
            ),
            alignment: Alignment.center,
          );
        }
      },
    );
  }

   Future<void> confirmClearanceNotifier(String to) async {
     //print('team meeting');
     await FirebaseMessaging().requestNotificationPermissions(
       const IosNotificationSettings(
           sound: true, badge: true, alert: true, provisional: false),
     );
     await http.post('https://fcm.googleapis.com/fcm/send',
         headers: <String, String>{
           'Content-Type': 'application/json',
           'Authorization': 'key=$serverToken'
         },
         body: jsonEncode(<String, dynamic>{
           'notification': <String, dynamic>{
             'body': 'Hello. you habe been cleared by the admin. you can now proceed with excuting delivery, Thank you',
             'title': 'Cleared'
           },
           'priority': 'high',
           'data': <String, dynamic>{
             'click_action': 'FLUTTER_NOTIFICATION_CLICK',
             'id': '1',
             'status': 'done',
             'payload': {
               'NotificationType': 'clearanceConfirmationResponse',
             }
           },
           'to': to,
         })).timeout(
       Duration(seconds: TIMEOUT),
       onTimeout: () {
         return null;
       },
     );
   }
}



class Manage extends StatelessWidget{
  const Manage({this.data,this.user,this.refresh});
  final dynamic data;
  final Session user;
  final Function refresh;

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<Agent>(
    future: LogisticRepo.getOneAgent((data as AgentLocUp).agent),
    initialData: null,
    builder: (_, AsyncSnapshot<Agent> agent){
    if(agent.hasData){
      return ListTile(
        onTap: (){
          Get.to(MyAuto(agent: agent.data,isAdmin: true,)).then((value) {refresh();});
        },
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.withOpacity(0.2),
          backgroundImage: NetworkImage(data.profile.isNotEmpty?data.profile:PocketShoppingDefaultAvatar,
          ),
        ),
        title: Text('${data.agentName}',style: TextStyle(fontSize: 18),),
        subtitle:Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(

              children: [
                Text('${data.autoAssigned?data.agentAutomobile:'Unassign'}',),

                Row(
                  children: [
                    Text('Collection Limit:'),
                    Text('$CURRENCY${Utility.numberFormatter(data.limit)} ')

                  ],
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            if(!data.autoAssigned)
              Row(
                children: [
                  Text('This agent is not assigned to any automobile.',style: TextStyle(color: Colors.red),)
                ],
              )
          ],
        )
    );
    }
    else{
      return Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: ListSkeleton(
          style: SkeletonStyle(
            theme: SkeletonTheme.Light,
            isShowAvatar: false,
            barCount: 3,
            colors: [
              Colors.grey.withOpacity(0.5),
              Colors.grey,
              Colors.grey.withOpacity(0.5)
            ],
            isAnimation: true,
          ),
        ),
        alignment: Alignment.center,
      );
    }
    },
    );
  }
}