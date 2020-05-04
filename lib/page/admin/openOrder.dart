import 'package:flutter/material.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/page/admin/HomeDelivery.dart';
import 'package:pocketshopping/page/admin/inHouseOrder.dart';

class Orders extends StatefulWidget {
  Orders({this.themeColor});

  final Color themeColor;

  @override
  _OrdersState createState() => new _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
              0.15), // here the desired height
          child: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: PRIMARYCOLOR,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            elevation: 0,
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.screen_share,
                  color: PRIMARYCOLOR,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
            title: Text(
              " Open Order(s)",
              style: TextStyle(color: PRIMARYCOLOR),
            ),
            bottom: TabBar(
              labelColor: PRIMARYCOLOR,
              tabs: [
                Tab(
                  text: "In-House Order",
                ),
                Tab(
                  text: "Home Delivery",
                ),
              ],
            ),
            automaticallyImplyLeading: false,
          ),
        ),
        body: TabBarView(
          children: [
            InHouseOrder(),
            HomeDeliveryOrder(),
          ],
        ),
      ),
    );
  }
}
