import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/admin/package_admin.dart' as admin;
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/admin/product/editProduct.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';

class AgentTracker extends StatefulWidget {
  final Session user;
  final int callBckActionType;
  AgentTracker({this.user,this.callBckActionType=1});
  @override
  _AgentTrackerState createState() => new _AgentTrackerState();
}

class _AgentTrackerState extends State<AgentTracker> {
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
              title: Text('${widget.user.merchant.bName} Agent(s)',style: TextStyle(color: PRIMARYCOLOR),),
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
                              ListTile(
                                  onTap: (){
                                    callBackAction(widget.callBckActionType);
                                  },
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.grey.withOpacity(0.2),
                                    backgroundImage: NetworkImage(list[index].profile.isNotEmpty?list[index].profile:PocketShoppingDefaultAvatar,
                                    ),
                                  ),
                                  title: Text('${list[index].agentName}',style: TextStyle(fontSize: 18),),
                                  subtitle: Column(
                                    //mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(

                                        children: [
                                          Text('${list[index].agentAutomobile}',),

                                          Row(
                                            children: [
                                              list[index].availability && Utility.isOperational(widget.user.merchant.bOpen, widget.user.merchant.bClose)?
                                              Icon(Icons.check,color: Colors.green,):
                                              Icon(Icons.close,color: Colors.red,),
                                              list[index].availability && Utility.isOperational(widget.user.merchant.bOpen, widget.user.merchant.bClose)?
                                              Text('Available')
                                                  :
                                              Text('Unavailable')
                                            ],
                                          )
                                        ],
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      ),
                                      if(list[index].availability && Utility.isOperational(widget.user.merchant.bOpen, widget.user.merchant.bClose))
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text('${list[index].address} (last updated: ${Utility.presentDate(DateTime.parse(list[index].agentUpdateAt.toDate().toString()))})'),
                                          )
                                        ],
                                      )
                                    ],
                                  )
                              ),
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

  callBackAction(int type){
    switch(type){
      case 1:
        print('clicked 1');
      break;
    }
  }

}