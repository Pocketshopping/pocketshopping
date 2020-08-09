import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/ui/shared/bonusDrawer.dart';
import 'package:pocketshopping/src/ui/shared/help.dart';
import 'package:pocketshopping/src/user/fav/faq.dart';
import 'package:pocketshopping/src/user/fav/fav.dart';
import 'package:pocketshopping/src/user/package_user.dart';

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
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
              0.15), // here the desired height
          child: AppBar(
            leading: BonusDrawerIcon(wallet: currentUser.user.walletId,
              openDrawer: (){Scaffold.of(context).openDrawer();},
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
                  text: "FAQ",
                ),
              ],
            ),
            automaticallyImplyLeading: false,
            actions: [
              Help(page: 'user',),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FavoriteWidget(user: currentUser,),
            FaqWidget(),
          ],
        ),
      ),
    );
  }
}
