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

class AgentBusiness extends StatefulWidget {
  final Session user;
  AgentBusiness({this.user});
  @override
  _AgentBusinessState createState() => new _AgentBusinessState();
}

class _AgentBusinessState extends State<AgentBusiness> {
  int get count => list.length;

  List<Merchant> list = [];
  bool _finish;
  bool loading;
  bool empty;

  void initState() {
    _finish = true;
    loading =true;
    empty = false;
     MerchantRepo.getMyBusiness(widget.user.merchant.mID, null).then((value){
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
    MerchantRepo.getMyBusiness(widget.user.merchant.mID, list.last).then((value) {
      if(mounted)
        setState((){
          list.addAll(value);
          if(list.length >= 10)
            _finish=false;
        });

    });
    else
      MerchantRepo.getMyBusiness(widget.user.merchant.mID, null).then((value) {
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
                0.17),
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
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(
                  MediaQuery.of(context).size.height *
                      0.1),
              child: Container(
                  child: TextFormField(
                    controller: null,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search ${widget.user.merchant.bName} Business',
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

                        MerchantRepo.getMyBusiness(widget.user.merchant.mID, null).then((value) {
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
                        MerchantRepo.searchMyBusiness(widget.user.merchant.mID, null,value.trim()).then((result) {

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
      body: !loading?
      !empty?
      Container(
        child: RefreshIndicator(
          child: LoadMore(
            isFinish: _finish,
            onLoadMore: _loadMore,
            child: ListView.separated(
              separatorBuilder: (_,i){return const Divider(thickness: 1,);},
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
                                  widget.user.user.role == 'admin'?
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
                                  ):const SizedBox.shrink()
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
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          list[index].bStatus == 1?Icon(Icons.check,color: Colors.green,):Icon(Icons.close,color: Colors.red,),
                          list[index].bStatus == 1?Text('Available'):Text('Unavailable')
                        ],
                      ),
                      Text('${list[index].bCategory}'),
                    ],
                  ),
                  trailing:  Icon(Icons.arrow_forward_ios),

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
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    load();
    return list.length%10 == 0 ?true:false;
  }

  Future<void> _refresh() async {
    list.clear();
    load();
  }
}