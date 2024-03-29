import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/order/lTracker.dart';
import 'package:pocketshopping/src/order/rTracker.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/tracker/errand/rErrandTracker.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';


class CompletedOrder extends StatefulWidget {
  final Session user;
  CompletedOrder({this.user});
  @override
  _CompletedOrderState createState() => new _CompletedOrderState();
}

class _CompletedOrderState extends State<CompletedOrder> {
  int get count => list.length;

  List<Order> list = [];
  bool _finish;
  bool loading;
  bool empty;

  void initState() {
    _finish = true;
    loading =true;
    empty = false;

    OrderRepo.fetchCompletedOrder(widget.user.agent != null?widget.user.agent.agent:widget.user.merchant.mID
        , null,whose: widget.user.agent != null?'agent':'orderLogistic').then((value){
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
      OrderRepo.fetchCompletedOrder(widget.user.agent != null?widget.user.agent.agent:widget.user.merchant.mID,
          list.last,whose: widget.user.agent != null?'agent':'orderLogistic').then((value) {
                list.addAll(value);
                _finish = value.length == 10 ? false : true;
                if(mounted)
                setState((){ });
      });
    else
      OrderRepo.fetchCompletedOrder(widget.user.agent != null?widget.user.agent.agent:widget.user.merchant.mID,
          null,whose: widget.user.agent != null?'agent':'orderLogistic').then((value) {
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
                          return SingleOrder(order: list[index],user: widget.user,refresh: _refresh,);
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
                              fontSize: Get.height * 0.06),
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
                    fontSize: Get.height * 0.12,
                    color: PRIMARYCOLOR,
                  ),
                )
            ),
          ],
        )
    );
  }

  Future<bool> _loadMore() async {
    //print(list.length);
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
  final Function refresh;
  SingleOrder({this.order,this.user,this.refresh});
  @override
  _SingleOrderState createState() => new _SingleOrderState();
}

class _SingleOrderState extends State<SingleOrder> {
  Merchant merchant;

  @override
  void initState() {
    MerchantRepo.getMerchant(widget.order.orderMerchant).then((value) {
      if(mounted)
        setState((){merchant=value;});
    }
        );
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //return Text('${(_start/60).round()}');
    return Column(
        children:[
          SizedBox(height: 10,),
          if(widget.order.orderMode.mode != 'Errand')
          merchant != null?ListTile(
            onTap: () {
              Get.to(
                  widget.user.user.role == 'rider'?
                  widget.order.orderMode.mode != 'Errand'?
                  RiderTracker(
                    order: widget.order.docID,
                    user: widget.user.user,
                  ):RiderErrandTracker(
                    order: widget.order.docID,
                    user: widget.user.user,
                  )
                      :
                  widget.order.orderMode.mode != 'Errand'?
                  LogisticTracker(
                    order: widget.order.docID,
                    user: widget.user.user,
                  ):
                  LogisticTracker(
                    order: widget.order.docID,
                    user: widget.user.user,
                  )
              ).then((value) {
                if(value == 'Refresh')
                {
                  widget.refresh();

                }

              });
            },
            leading: CircleAvatar(
                radius: 25.0,
                backgroundColor:Colors.white,
                child: Center(child: widget.order.receipt.psStatus == 'success'?Icon(Icons.check,color: Colors.green,):Icon(Icons.close,color: Colors.red,),),
            ),
            title:Text('${merchant != null ? merchant.bName:''}',style: TextStyle(fontSize: 18),),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('${merchant != null ? 'From: ${merchant.bAddress}':''}',),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text("${widget.order.orderItem[0].ProductName} ${widget.order.orderItem.length > 1 ? '+${widget.order.orderItem.length - 1} more' : ''}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text("$CURRENCY${
                        widget.order.orderAmount
                    }")
                  ],
                ),
                if(widget.user.agent == null)
                  Row(
                    children: [
                      Text('Agent: ${widget.order.orderMode.deliveryMan}'),
                      Text('${Utility.presentDate((widget.order.orderCreatedAt as Timestamp).toDate())}')
                    ],
                  ),
                  Row(
                    children: [
                      Text('${Utility.presentDate((widget.order.orderCreatedAt as Timestamp).toDate())}')
                    ],
                  )

              ],
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
          ):Container(
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
          ),
          Divider(),
          if(widget.order.orderMode.mode == 'Errand')
            ListTile(
              onTap: () {
                Get.to(
                    widget.user.user.role == 'rider'?
                    widget.order.orderMode.mode != 'Errand'?
                    RiderTracker(
                      order: widget.order.docID,
                      user: widget.user.user,
                    ):RiderErrandTracker(
                      order: widget.order.docID,
                      user: widget.user.user,
                    )
                        :
                    widget.order.orderMode.mode != 'Errand'?
                    LogisticTracker(
                      order: widget.order.docID,
                      user: widget.user.user,
                    ):
                    LogisticTracker(
                      order: widget.order.docID,
                      user: widget.user.user,
                    )
                ).then((value) {
                  if(value == 'Refresh')
                  {
                    widget.refresh();

                  }

                });
              },
              leading: CircleAvatar(
                radius: 25.0,
                backgroundColor:Colors.white,
                child: Center(child: widget.order.receipt.psStatus == 'success'?Icon(Icons.check,color: Colors.green,):Icon(Icons.close,color: Colors.red,),),
              ),
              title:Text("${'Errand'}", style: const TextStyle(fontWeight: FontWeight.bold),),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      if(widget.user.agent == null)
                        Text('Rider: ${widget.order.orderMode.deliveryMan}'),
                      Text("$CURRENCY${widget.order.orderMode.fee}")
                    ],
                  ),
                  Text('${Utility.presentDate(DateTime.parse((widget.order.orderCreatedAt as Timestamp).toDate().toString()))}'),
                ],
              ),
              trailing: Icon(Icons.keyboard_arrow_right),
            )
        ]
    );
  }
}