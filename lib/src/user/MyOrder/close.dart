import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/tracker.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:progress_indicators/progress_indicators.dart';

class CloseOrder extends StatefulWidget {
  final Session user;
  CloseOrder({this.user});
  @override
  _CloseOrderState createState() => new _CloseOrderState();
}

class _CloseOrderState extends State<CloseOrder> {
  int get count => list.length;

  List<Order> list = [];
  bool _finish;
  bool loading;
  bool empty;

  void initState() {
    _finish = true;
    loading =true;
    empty = false;
    OrderRepo.getCompleted(null, widget.user.user.uid).then((value){
      //print(value);
      list=value;
      loading =false;
      _finish=value.length == 10?false:true;
      empty = value.isEmpty;
      if(mounted)
        setState((){ });
    });
    super.initState();
  }

  void load() {

    if(list.isNotEmpty)
      OrderRepo.getCompleted(list.last, widget.user.user.uid).then((value) {
        list.addAll(value);
        _finish = value.length == 10 ? false : true;
        if(mounted)
          setState((){ });

      });
    else
      OrderRepo.getCompleted(null, widget.user.user.uid).then((value) {
        list=value;
        _finish = value.length == 10 ? false : true;
        empty=value.isEmpty?true:false;
        if(mounted)
          setState((){ });

      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
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
                          return SingleOrder(order: list[index],user: widget.user,);
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
                                "No Completed Order",
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
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    load();
    return list.length%10 == 0 ?true:false;
  }

  Future<void> _refresh() async {
    setState(() {list.clear();});
    load();
  }
}

class SingleOrder extends StatefulWidget {
  final Order order;
  final Session user;
  SingleOrder({this.order,this.user});
  @override
  _SingleOrderState createState() => new _SingleOrderState();
}

class _SingleOrderState extends State<SingleOrder> {


  @override
  void initState() {
   super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //return Text('${(_start/60).round()}');
    return Column(
        children:[
          SizedBox(height: 10,),
          ListTile(
            onTap: () {
              Get.to(OrderTrackerWidget(
                order: widget.order,
                user: widget.user.user,
              )
              );
            },
            leading:CircleAvatar(
                radius: 30.0,
                backgroundColor: Colors.white,
                child: Center(child: widget.order.receipt.psStatus == 'success'?Icon(Icons.check,color: Colors.green,):Icon(Icons.close,color: Colors.red,),),
            ),
            title: Text("${widget.order.orderItem[0].ProductName} ${widget.order.orderItem.length > 1 ? '+${widget.order.orderItem.length - 1} more' : ''}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("${widget.order.orderMode.mode}"),
                    Text("$CURRENCY${(widget.order.orderAmount+widget.order.orderMode.fee)}")
                  ],
                ),
              ],
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
          ),
          Divider(),
        ]
    );
  }
}



