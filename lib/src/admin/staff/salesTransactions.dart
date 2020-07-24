import 'dart:async';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/order/repository/cartObj.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/tracker/delivery/rDeliveryTracker.dart';
import 'package:pocketshopping/src/payment/topup.dart';
import 'package:pocketshopping/src/pos/checkOut.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';

class SalesTransactions extends StatefulWidget {
  final Session user;
  final String title;
  SalesTransactions({this.user,this.title});
  @override
  _SalesTransactionsState createState() => new _SalesTransactionsState();
}

class _SalesTransactionsState extends State<SalesTransactions> {
  int get count => list.length;

  List<Order> list = [];
  bool _finish;
  bool loading;
  bool empty;
  String address ;
  List<String> category;
  String selectedCategory;



  void initState() {
    _finish = true;
    loading =true;
    empty = false;
    OrderRepo.fetchStaffOrder(widget.user.user.uid,widget.user.merchant.mID, null).then((value){
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
        OrderRepo.fetchStaffOrder(widget.user.user.uid,widget.user.merchant.mID, list.last).then((value) {
          loading=false;
          if(mounted)
            if(value.isNotEmpty)
              setState((){
                //empty = false;
                list.addAll(value);
                if(list.length >= 10)
                  _finish=false;
                else
                  _finish=true;
              });
            else
              setState(() {
                _finish=true;
                if(list.isEmpty)
                  empty=true;
              });

        });
    else
      OrderRepo.fetchStaffOrder(widget.user.user.uid,widget.user.merchant.mID, null).then((value) {
        loading=false;
        if(mounted)
          if(value.isNotEmpty)
            setState((){
              //empty = false;
              list.addAll(value);
              if(list.length >= 10)
                _finish=false;
              else
                _finish=true;
            });
          else
            setState(() {
              _finish=true;
              if(list.isEmpty)
                empty=true;
            });

      });
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
            backgroundColor: Color.fromRGBO(255, 255, 255, 1),
            appBar: AppBar(
              title: Text(widget.title==null?'${widget.user.merchant.bName} Transaction(s)':widget.title,style: TextStyle(color: PRIMARYCOLOR),),
              centerTitle: true,
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
            body: Column(
              children: [
                Expanded(flex:0,child: SizedBox(height: 10,)),
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
                              return ListTile(
                                onTap: ()async {
                                  Get.to(RiderDeliveryTracker(order: list[index].docID,user: widget.user.user,)).then((value) {
                                    _refresh();
                                  });
                                },
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey.withOpacity(0.2),
                                  child: Text('$CURRENCY'),
                                ),
                                title: Text("${list[index].orderItem[0].ProductName} ${list[index].orderItem.length > 1 ? '+${list[index].orderItem.length - 1} more' : ''}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Row(
                                  children: [
                                    Expanded(
                                      child: Text('$CURRENCY${list[index].orderAmount}'),
                                    ),
                                    Expanded(
                                      child: Text('${Utility.presentDate((list[index].orderCreatedAt as Timestamp).toDate())}'),
                                    ),
                                  ],
                                ),
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
                                    "No Transaction(s) to display",
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
            ),
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








}
