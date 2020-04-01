import 'package:flutter/material.dart';

class TopTabBar extends StatelessWidget {

  TopTabBar(this.themeColor);
  final Color themeColor;

  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.1), // here the desired height
            child: AppBar(
            backgroundColor: themeColor,
            leading: IconButton(

              icon: Icon(Icons.menu,color:Colors.white,
              ),
              onPressed: (){
                Scaffold.of(context).openDrawer();
              },
            ) ,

            title: Text(" My Order(s)"),

            bottom: TabBar(
              tabs: [
                Tab(text: "Open",),
                Tab(text: "Pending",),
                Tab(text: "Close",),
                Tab(text: "Cancelled",),
              ],
            ),


            automaticallyImplyLeading: false,
          ),
        ),
          body: TabBarView(
            children: [
              Icon(Icons.directions_car),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
              Icon(Icons.directions_bike),
            ],
          ),
        ),

    );
  }
}
