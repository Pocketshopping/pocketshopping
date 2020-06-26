import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/user/MyOrder/close.dart';
import 'package:pocketshopping/src/user/MyOrder/open.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/pocketPay/pocketMenu.dart';
import 'package:pocketshopping/src/pocketPay/history.dart';

class PocketPay extends StatefulWidget {
  @override
  _PocketPayState createState() => new _PocketPayState();
}

class _PocketPayState extends State<PocketPay> {
  Session currentUser;

  @override
  void initState() {
    currentUser = BlocProvider.of<UserBloc>(context).state.props[0];
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
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: PRIMARYCOLOR,
              ),
              onPressed: () {
                //print("your menu action here");
                Scaffold.of(context).openDrawer();
              },
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "My Pocket",
              style: TextStyle(color: Colors.black),
            ),
            bottom: TabBar(
              labelColor: PRIMARYCOLOR,
              tabs: [
                Tab(
                  text: "Pocket",
                ),
                Tab(
                  text: "History",
                ),
              ],
            ),
            automaticallyImplyLeading: false,
          ),
        ),
        body: TabBarView(
          children: [
            PocketMenu(user: currentUser),
            PocketHistory(user: currentUser),
          ],
        ),
      ),
    );
  }
}
