
import 'dart:async';

import 'package:ant_icons/ant_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/order/bloc/trackerBloc.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/tracker/customer/cdTracker.dart';
import 'package:pocketshopping/src/order/tracker/customer/ceTracker.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';

class OpenOrder extends StatefulWidget {
  final Session user;
  OpenOrder({this.user});
  @override
  _OpenOrderState createState() => new _OpenOrderState();
}

class _OpenOrderState extends State<OpenOrder> {
  int get count => list.length;

  List<Order> list = [];
  bool _finish;
  bool loading;
  bool empty;
  Stream<LocalNotification> _notificationsStream;


  void initState() {
    _finish = true;
    loading =true;
    empty = false;
    OrderRepo.get(null,0, widget.user.user.uid).then((value){
      list=value;
      loading =false;
      _finish=value.length == 10?false:true;
      empty = value.isEmpty;
      if(mounted)
        setState((){ });

    });
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      if(mounted)
      _refresh();
    });

    super.initState();
  }

  void load({int source=0}) {

    if(list.isNotEmpty)
      OrderRepo.get(list.last,0, widget.user.user.uid,source: source).then((value) {
        list.addAll(value);
        _finish = value.length == 10 ? false : true;
        loading =false;
        if(mounted)
          setState((){ });

      });
    else
      OrderRepo.get(null,0, widget.user.user.uid,source: source).then((value) {
        list=value;
        _finish = value.length == 10 ? false : true;
        empty=value.isEmpty?true:false;
        loading = false;
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
                  title:  Image.asset('assets/images/empty.gif'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: const Text(
                          'Empty',
                          style: const TextStyle(
                              fontSize: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: const Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: const Text(
                                "No Open Order",
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
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    load();
    return list.length%10 == 0 ?true:false;
  }

  Future<void> _refresh() async {
    if(mounted)
    {
      setState(() {
        list.clear();
        loading=true;
      });
      load(source: 1);
    }
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
  Timer _timer;
  Stream<Map<String,Timestamp>> _trackerStream;

  @override
  void initState() {
    _start = Utility.setStartCount(widget.order.orderCreatedAt, widget.order.orderETA);
    startTimer();

    _trackerStream = TrackerBloc.instance.trackerStream;
    _trackerStream.listen((dateTime) {
      if(dateTime.containsKey(widget.order.receipt.collectionID) && _start == 0){
        _start =Utility.setStartCount(dateTime[widget.order.receipt.collectionID], 600);
        startTimer();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //return Text('${(_start/60).round()}');
    return Column(
        children:[
          const SizedBox(height: 10,),
          ListTile(
            onTap: () {
              //print(widget.order.docID);
              Get.to(
                  widget.order.orderMode.mode != 'Errand'?
                  CustomerDeliveryTrackerWidget(
                    order: widget.order.docID,
                    user: widget.user.user,
                    isActive: true,

                  )
                      :
                  CustomerErrandTrackerWidget(
                    user: widget.user.user,
                    order: widget.order.docID,
                    isActive: true,
                  )
              ).then((value) {
                widget.refresh();
              });
            },
            leading: widget.order.orderMode.mode == 'Errand'?
            CircleAvatar(
                radius: 25.0,
                backgroundColor: Colors.grey.withOpacity(0.5),
                child: Icon(AntIcons.clock_circle_outline,color: Colors.black54,))
            :CircleAvatar(
                radius: 25.0,
                backgroundColor: (_start/60).round()>0?Colors.green:Colors.red,
                child: Text('${(_start/60).round()}min',style: const TextStyle(color: Colors.white,fontSize: 14),)),
             title: widget.order.orderMode.mode != 'Errand'?
             Text("${widget.order.orderItem[0].ProductName} ${widget.order.orderItem.length > 1 ? '+${widget.order.orderItem.length - 1} more' : ''}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ):
             Text("${'Errand'}",
               style: const TextStyle(fontWeight: FontWeight.bold),
             ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("${widget.order.orderMode.mode == 'Errand'?'Rider: ${widget.order.orderMode.deliveryMan}':widget.order.orderMode.mode}"),
                    Text("$CURRENCY${widget.order.orderMode.mode == 'Errand'?widget.order.orderMode.fee:
                    widget.order.orderMode.mode == 'Delivery'?
                    (widget.order.orderMode.fee + widget.order.orderAmount):widget.order.orderAmount
                    }"),

                  ],
                ),
                if(widget.order.orderMode.mode != 'Errand')
                  FutureBuilder(
                    future: MerchantRepo.getMerchant(widget.order.orderMerchant),
                    builder: (c,AsyncSnapshot<Merchant>merchant){
                      if(merchant.hasData){
                        return Text("${merchant.data.bName}") ;
                      }
                      else return const SizedBox.shrink();
                    },
                  ),
                Text('${Utility.presentDate(DateTime.parse((widget.order.orderCreatedAt as Timestamp).toDate().toString()))}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    (_start/60).round() == 0?
                     Expanded (
                      child: widget.order.orderMode.mode != 'Errand'?
                      const Text("${'Have you collected your package. click here to take further action'}"):
                      const Text("") ,
                    ):const SizedBox.shrink()
                  ],
                ),

              ],
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
          ),
          const Divider(),
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

