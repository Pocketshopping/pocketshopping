
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navigation_badge/bottom_navigation_badge.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketshopping/page/user/favourite.dart';
import 'package:pocketshopping/page/user/order.dart';
import 'package:flutter/services.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/geofence/geofence.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';

import 'bloc/user.dart';


class AdminScreen extends StatefulWidget {

  final UserRepository _userRepository;

  AdminScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _AdminScreenState createState() => new _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

  int _selectedIndex;
  FirebaseUser CurrentUser;

  BottomNavigationBadge badger = new BottomNavigationBadge(
      backgroundColor: Colors.red,
      badgeShape: BottomNavigationBadgeShape.circle,
      textColor: Colors.white,
      position: BottomNavigationBadgePosition.topRight,
      textSize: 8);
  List<BottomNavigationBarItem>items=
  <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      title: Text('DashBoard'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.place),
      title: Text('Places'),
    ),
    BottomNavigationBarItem(
      title: Text('Favourite'),
      icon: Icon(Icons.favorite),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.folder),
      title: Text('Order'),
    ),
  ];

  @override
  void initState(){
    super.initState();
    _selectedIndex = 0;
    CurrentUser = BlocProvider.of<AuthenticationBloc>(context).state.props[0];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child:
      BlocProvider(
        create: (context) => UserBloc(
          userRepository: UserRepo(),
        )..add(LoadUser(CurrentUser.uid)),
        child: BlocBuilder<UserBloc, UserState>(

            builder: (context, state) {
              if(state is UserLoaded)
              {
                //print('merchant: ${state.user.merchant}');
                return Scaffold(
                  drawer: DrawerScreen(userRepository: widget._userRepository,user: state.user.user,),
                  body: Container(

                      child:Center(
                        child: <Widget>[
                          DashBoardScreen(),
                          GeoFence(),
                          Favourite(),
                          OrderWidget(PRIMARYCOLOR),
                        ].elementAt(_selectedIndex),
                      ),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black54.withOpacity(0.2))))
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    items: items,
                    currentIndex: _selectedIndex,
                    selectedItemColor: PRIMARYCOLOR,
                    unselectedItemColor: Colors.black54,
                    showUnselectedLabels: true,
                    onTap: _onItemTapped,
                  ),
                );
              }
              else{
                return Scaffold(
                  body: Center(
                    child:Image.asset("assets/images/loading.gif",
                      width: MediaQuery.of(context).size.width*0.3,),),
                );
              }



            }
        ),
      )

      ,




    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Warning'),
        content: new Text('Do you want to exit the App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            child: new Text('Yes'),
          ),
        ],
      ),
    ));

  }
}