import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/src/order/bloc/orderBloc.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/user/agent/delivery/active.dart';
import 'package:pocketshopping/src/user/agent/delivery/completed.dart';
import 'package:pocketshopping/src/user/package_user.dart';

class MyDelivery extends StatefulWidget{
  final List<Order> orders;
  final Session user;
  MyDelivery({this.orders,this.user});
  @override
  _MyDeliveryState createState() => new _MyDeliveryState();
}

class _MyDeliveryState extends State<MyDelivery>{

  List<Order> newOrders;
  Stream<List<Order>> _orderStream;
  @override
  void initState() {
    newOrders = [];
    _orderStream = OrderBloc.instance.orderStream;
    _orderStream.listen((orders) {
      if(mounted)
        setState(() {
          newOrders.clear();
          if(!newOrders.contains(orders))
          newOrders.addAll(orders);
        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
        length: 2,
        child:Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Delivery',style: TextStyle(color: PRIMARYCOLOR),),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: false,
        elevation: 0.0,
        bottom: TabBar(
          labelColor: PRIMARYCOLOR,
          tabs: [
            newOrders.length>0?
            Badge(
              child: Tab(
                text: "Active Delivery",
              ),
              badgeContent: Text('${newOrders.length}',style: TextStyle(color: Colors.white),),
            ):
            Tab(text: "Active Delivery",),
            Tab(text: "Completed Delivery",),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: TabBarView(
      children: [
      ActiveOrder(user: widget.user,),
      CompletedOrder(user: widget.user,)
    ],
        physics: NeverScrollableScrollPhysics(),
    )
    )
    );
  }
}