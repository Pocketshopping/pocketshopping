import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/logistic/agent/newAgent.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/agentCompany/agentTracker.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/agent/myAuto.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';

class AgentList extends StatefulWidget {
  final Session user;
  final int callBckActionType;
  final String title;
  final int route;
  AgentList({this.user,this.callBckActionType=1,this.title,this.route=0});
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
              title: Text(widget.title==null?'${widget.user.merchant.bName} Rider(s)':widget.title,style: TextStyle(color: PRIMARYCOLOR),),
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
                        hintText: 'Search ${widget.user.merchant.bName} Rider(s)',
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
                      child: ListView.separated(
                        separatorBuilder: (_,i){return const Divider(thickness: 1,);},
                        itemBuilder: (BuildContext context, int index) {

                          return uiType(list[index]);
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
                            return '';
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
                                "No Rider added yet",
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
            if(widget.route>0)
            Expanded(
              flex: 0,
              child: Container(

                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: PRIMARYCOLOR,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
                ),
                child:Padding(
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                    child: Center(
                      child: FlatButton.icon(
                        color: PRIMARYCOLOR,
                        onPressed: (){
                          Get.to(
                              AgentForm(
                                session: widget.user,
                              )
                          ).then((value) {
                            _refresh();
                          });
                        },
                        icon: Icon(Icons.add,color: Colors.white,),
                        label: Text('New Rider',style: TextStyle(color: Colors.white),),
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
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    load();
    return list.length%10 == 0 ?true:false;
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
        ),
      trailing:  Icon(Icons.arrow_forward_ios),
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
                                              clearanceNotifier((data as AgentLocUp).device).then((value) => null);
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
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: PRIMARYCOLOR
                                    .withOpacity(0.5)),
                            color:
                            PRIMARYCOLOR.withOpacity(0.8),
                          ),
                          child: FlatButton(
                            onPressed: () {

                                if(remit.data['total']>0.0){
                                  Get.back();
                                  Utility.bottomProgressLoader(body: 'Generating clearaance code.. please wait');
                                  LogisticRepo.getRemittance((data as AgentLocUp).wallet,limit: remit.data['total'].round()).then((value)
                                  {
                                    Get.back();
                                  GetBar(title: 'Clearance Code Generated',
                                    messageText: Text( 'Notification has been sent to the agent ',style: TextStyle(color: Colors.white),),
                                    backgroundColor: PRIMARYCOLOR,
                                    snackStyle: SnackStyle.GROUNDED,
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 5),
                                  ).show();
                                    clearanceNotifier((data as AgentLocUp).device,
                                        title: 'Pending Clearance',
                                    body: 'You have a pending clearance. Head to office for clearance',
                                      notificationID: 'PendingRemittanceNotification'
                                    ).then((value) => null);
                                  });
                                }
                                else{
                                  Get.back();
                                  GetBar(title: 'Error Generating Clearance',
                                    messageText: Text( 'Cash total is ${CURRENCY}0.0 ',style: TextStyle(color: Colors.white),),
                                    backgroundColor: PRIMARYCOLOR,
                                    snackStyle: SnackStyle.GROUNDED,
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 3),
                                  ).show();
                                }


                            },
                            child: Center(
                                child: Text(
                                 "Generate Clearance",
                                  style: TextStyle(
                                      color: Colors.white),
                                )),
                          ),
                        )


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
              ),
            trailing:  Icon(Icons.arrow_forward_ios),
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

   Future<void> clearanceNotifier(String to,{String title='Cleared',
   String body='Hello. you have been cleared by the admin. you can now proceed with excuting delivery, Thank you',
   String notificationID= 'clearanceConfirmationResponse'}) async {

    await Utility.pushNotifier(
      body: body,
      title: title,
      fcm: to,
      notificationType: notificationID,
      data: {},

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
                  Expanded(
                    child: Text('This Rider is not assigned to any automobile.',style: TextStyle(color: Colors.red),)
                  )
                ],
              )
          ],
        ),
        trailing:  Icon(Icons.arrow_forward_ios),
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