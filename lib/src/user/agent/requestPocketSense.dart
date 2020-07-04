import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/user/agent/requestPocketSense/today.dart';
import 'package:pocketshopping/src/user/agent/requestPocketSense/yesterday.dart';
import 'package:pocketshopping/src/user/package_user.dart';

class RequestPocketSense extends StatelessWidget{
  final Session user;
  RequestPocketSense({this.user});


  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
        length: 2,
        child:Scaffold(
            backgroundColor: Color.fromRGBO(245, 245, 245, 1),
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(245, 245, 245, 1),
              title: const Text('PocketSense',style: TextStyle(color: PRIMARYCOLOR),),
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
                 const Tab(text: "Today",),
                  const Tab(text: "Yesterday",),

                ],
                isScrollable: false,

              ),

              automaticallyImplyLeading: false,
            ),
            body: TabBarView(
              children: [
                TodayMisses(user: user,),
                YesterdayMisses(user: user,)
              ],
              physics: NeverScrollableScrollPhysics(),
            )
        )
    );
  }
}