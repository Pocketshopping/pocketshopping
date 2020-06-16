import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/admin/package_admin.dart' as admin;
import 'package:pocketshopping/src/admin/product/manage.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/business/mangeBusiness.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:progress_indicators/progress_indicators.dart';

class AgentTracker extends StatefulWidget {
  final Session user;
  AgentTracker({this.user});
  @override
  _AgentTrackerState createState() => new _AgentTrackerState();
}

class _AgentTrackerState extends State<AgentTracker> {
  int get count => list.length;

  List<Merchant> list = [];
  bool _finish;
  bool loading;
  bool empty;

  void initState() {
    _finish = true;
    loading =true;
    empty = false;
    MerchantRepo.getMyBusiness(widget.user.user.uid, null).then((value){
      //print(value);
      if(mounted)
        setState((){
          list=value;
          loading =false;
          if(list.length >= 10)
            _finish=false;
          if(list.isEmpty)
            empty = true;
        });
    });
    super.initState();
  }

  void load() {

    if(list.isNotEmpty)
      MerchantRepo.getMyBusiness(widget.user.user.uid, list.last).then((value) {
        if(mounted)
          setState((){
            list.addAll(value);
            if(list.length >= 10)
              _finish=false;
          });

      });
    else
      MerchantRepo.getMyBusiness(widget.user.user.uid, null).then((value) {
        if(mounted)
          setState((){
            list.addAll(value);
            if(list.length >= 10)
              _finish=false;
          });

      });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              MediaQuery.of(context).size.height *
                  0.12),
          child: AppBar(
            title: Text('Business(es)',style: TextStyle(color: PRIMARYCOLOR),),
            backgroundColor: Color.fromRGBO(255, 255, 255, 1),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.grey,
              ),
              onPressed: () {
                Get.back();
              },
            ),
            elevation: 0.0,
          ),
        ),
        body: !loading?
        !empty?
        Container(
          child: RefreshIndicator(
            child: LoadMore(
              isFinish: _finish,
              onLoadMore: _loadMore,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: (){
                      if(!Get.isBottomSheetOpen)
                        Get.bottomSheet(builder: (context)=>
                            admin.BottomSheetTemplate(
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: Container(
                                child:  Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                          child: GestureDetector(
                                            child: Column(
                                              children: [
                                                Image.asset('assets/images/product.png',
                                                  height: MediaQuery.of(context).size.height*0.1,),
                                                Center(
                                                  child: Text('Product'),
                                                )
                                              ],
                                            ),
                                            onTap: (){
                                              Session sess= widget.user;
                                              sess = sess.copyWith(merchant:list[index] );
                                              Get.off(ManageProduct(user: sess,)).then((value){
                                                if(value == 'Refresh')
                                                  _refresh();
                                              });
                                            },
                                          )
                                      ),
                                      Expanded(
                                          child: GestureDetector(
                                            onTap: (){
                                              Session sess= widget.user;
                                              sess = sess.copyWith(merchant:list[index] );
                                              Get.off(ManageBusiness(session: sess,)).then((value){
                                                if(value == 'Refresh')
                                                  _refresh();
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.settings,
                                                  size: MediaQuery.of(context).size.height*0.1,
                                                ),
                                                Center(
                                                  child: Text('Manage Business'),
                                                )
                                              ],
                                            ),
                                          )
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )

                        );
                    },
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey.withOpacity(0.5),
                      backgroundImage: NetworkImage(list[index].bPhoto),
                    ),
                    title: Text('${list[index].bName}',style: TextStyle(fontSize: 18),),
                    subtitle: Text('${list[index].bDescription}',style: TextStyle(fontSize: 16),),
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
                        "No business to display",
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
    );
  }

  Future<bool> _loadMore() async {
    load();
    return true;
  }

  Future<void> _refresh() async {
    list.clear();
    load();
  }
}