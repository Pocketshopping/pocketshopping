import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/user/MyOrder/close.dart';
import 'package:pocketshopping/src/user/MyOrder/open.dart';
import 'package:pocketshopping/src/user/package_user.dart';

class MyOrders extends StatefulWidget {
  MyOrders();

  @override
  _OrdersState createState() => new _OrdersState();
}

class _OrdersState extends State<MyOrders> {
  Session CurrentUser;

  @override
  void initState() {
    CurrentUser = BlocProvider.of<UserBloc>(context).state.props[0];
    super.initState();
  }

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
            elevation: 0,
            title: Text(
              "My Order(s)",
              style: TextStyle(color: Colors.black),
            ),
            bottom: TabBar(
              labelColor: PRIMARYCOLOR,
              tabs: [
                Tab(
                  text: "Open Order",
                ),
                Tab(
                  text: "Close Order",
                ),
              ],
            ),
            automaticallyImplyLeading: false,
          ),
        ),
        body: TabBarView(
          children: [
            OpenOrder(user: CurrentUser),
            CloseOrder(user: CurrentUser),
          ],
        ),
      ),
    );
  }
}
