import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:pocketshopping/page/user/place.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/widget/bSheetSearchWidget.dart';
import 'package:pocketshopping/src/user/fav/fav.dart';
import 'package:pocketshopping/src/user/fav/repository/favObj.dart' as favObj;
import 'package:pocketshopping/src/user/fav/repository/favRepo.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Favourite extends StatefulWidget {
  @override
  _FavouriteState createState() => new _FavouriteState();
}

class _FavouriteState extends State<Favourite> {


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
              "Pocketshopping",
              style: TextStyle(color: Colors.black),
            ),
            bottom: TabBar(
              labelColor: PRIMARYCOLOR,
              tabs: [
                Tab(
                  text: "Favourite",
                ),
                Tab(
                  text: "Reviews",
                ),
              ],
            ),
            automaticallyImplyLeading: false,
          ),
        ),
        body: TabBarView(
          children: [
            FavoriteWidget(user: currentUser,),
            Text('Ur mind'),
          ],
        ),
      ),
    );
  }
}