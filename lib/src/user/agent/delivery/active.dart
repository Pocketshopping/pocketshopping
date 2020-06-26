import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/order/bloc/orderBloc.dart';
import 'package:pocketshopping/src/order/deliveryTracker.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/MyOrder/orderGlobal.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';

class ActiveOrder extends StatefulWidget {
  final Session user;
  ActiveOrder({this.user});
  @override
  _ActiveOrderState createState() => new _ActiveOrderState();
}

class _ActiveOrderState extends State<ActiveOrder> {
  int get count => list.length;

  final _search = TextEditingController();
  List<Order> list = [];
  bool _finish;
  bool loading;
  bool empty;
  Stream<List<Order>> _orderStream;
  OrderGlobalState odState;
  bool searchStarted;

  void initState() {
    _finish = true;
    searchStarted= false;
    loading =false;//list.isEmpty;
    empty = list.isEmpty;
    _orderStream = OrderBloc.instance.orderStream;
    _orderStream.listen((orders) {
      if(mounted) {
        //if(searchStarted) {
          list.clear();
          setState(() {
            if (!list.contains(orders))
              list.addAll(orders);
            empty = list.isEmpty;
          });
       // }
      }
    });
    try {odState = Get.find();}catch(_){odState = Get.put(OrderGlobalState());}
    super.initState();
  }

  @override
  void dispose() {
    _orderStream = null;
    super.dispose();
  }

  void load() {

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              MediaQuery.of(context).size.height *
                  0.09),
          child: widget.user.agent  == null ?AppBar(
            elevation: 0.0,
            backgroundColor: Colors.white,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(
                    MediaQuery.of(context).size.height *
                        0.09),
                child: widget.user.agent  == null ?Container(
                    child: TextFormField(
                      controller: _search,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search open orders',
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
                        if(value.length > 0 )
                          setState(() {searchStarted = true; });
                        else
                          {
                            _refresh();
                            setState(() {searchStarted = false; });
                          }


                      }
                    )

                ):const SizedBox.shrink(),

              )
          ):const SizedBox.shrink(),
        ),
        body: !searchStarted?Column(
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
                                "No New Order",
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
        ):StreamBuilder<List<Order>>(
            stream: OrderRepo.searchAgentOrder(widget.user.merchant.mID,_search.text,whose: 'orderLogistic'),
            builder: (BuildContext context, AsyncSnapshot<List<Order>> snapshot) {
              if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: JumpingDotsProgressIndicator(
                      fontSize: MediaQuery.of(context).size.height * 0.12,
                      color: PRIMARYCOLOR,
                    ),
                  );
                default:
                  return snapshot.data.isNotEmpty?Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(10.0),
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return SingleOrder(order: snapshot.data[index],user: widget.user,refresh: _refresh,);
                            //return buildUserRow(snapshot.data.documents[index]);
                          },
                          separatorBuilder: (context, index) {
                            return Divider();
                          },
                        ),
                      ],
                    ),
                  ):ListTile(
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
                                  "No Such Order",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
              }
            })
    );
  }

  Future<bool> _loadMore() async {
    load();
    return true;
  }

  Future<void> _refresh() async {
    empty = list.isEmpty;
    setState(() {});
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
  int _start;
  Merchant merchant;
  Timer _timer;
  OrderGlobalState odState;

  @override
  void initState() {
    try {odState = Get.find();}catch(_){odState = Get.put(OrderGlobalState());}
    _start =isNotEmpty(widget.order.docID)?Utility.setStartCount(getItem("eDelayTime",widget.order.docID), (getItem("eMoreSec",widget.order.docID)*60)) : Utility.setStartCount(widget.order.orderCreatedAt, widget.order.orderETA);
    MerchantRepo.getMerchant(widget.order.orderMerchant).then((value) { if(mounted)setState((){merchant=value;});});
    startTimer();
    super.initState();
  }

  dynamic getItem(String key,String oid) => odState.order['e_'+oid][key];
  bool isNotEmpty(String oid) => odState.order.containsKey('e_'+oid);

  @override
  Widget build(BuildContext context) {
    //return Text('${(_start/60).round()}');
    return Column(
        children:[
          SizedBox(height: 10,),
          merchant != null?ListTile(
      onTap: () {
        Get.to(DeliveryTrackerWidget(
          order: widget.order,
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
          backgroundColor: (_start/60).round()>0?Colors.green:Colors.red,
          child: Text('${(_start/60).round()}min',style: TextStyle(color: Colors.white,fontSize: 14),)),
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
              Text('Agent: ${widget.order.orderMode.deliveryMan}')
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
    ]
    );
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => {
        if (mounted)
          {
            setState(
                  () {
                if (_start < 1) {
                  timer.cancel();
                }
                else {
                  _start = _start - 1;
                }
              },
            )
          }
      },
    );
  }
}

