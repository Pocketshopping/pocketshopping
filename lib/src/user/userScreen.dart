
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


class UserScreen extends StatefulWidget {

  final UserRepository _userRepository;

  UserScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _UserScreenState createState() => new _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {

  int _selectedIndex;
  Color fabColor;
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
    fabColor = PRIMARYCOLOR;
    CurrentUser = BlocProvider.of<AuthenticationBloc>(context).state.props[0];

    //CategoryData().getAll().then((value) => psProvider.of(context).value['category']=value);


    /*SchedulerBinding.instance.addPostFrameCallback((_) {

      if(psProvider.of(context).value['user']['fname'] != null) {
        UserData(uid: psProvider
            .of(context)
            .value['uid']).getOne().then((value) =>
        {
          psProvider
              .of(context)
              .value['user'] = value
        });
      }
      NotificationDataModel(uid:psProvider.of(context).value['uid'],nCleared: false).getAll().then((value) => {
        if(value.length>0){
          psProvider.of(context).value['notifications']=value,
          Scaffold.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 5),
                content: Text('You have very important notification that needs your attention'),
                action: SnackBarAction(
                  label: "View Now",
                  textColor: Colors.white,
                  //disabledTextColor: TEXT_BLACK_LIGHT,
                  onPressed: () {
                    print("I know you are testing the action in the SnackBar!");
                  },
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              )
          )
        }
      });
    });*/
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {

    });
    print(CurrentUser.uid);
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
                  print(state.user.user.uid);
                  return Scaffold(
                    drawer: DrawerScreen(userRepository: widget._userRepository,user: state.user.user,),
                    body: Container(

                        child:Center(
                          child: <Widget>[
                            GeoFence(),
                            Favourite(),
                            OrderWidget(fabColor),
                          ].elementAt(_selectedIndex),
                        ),
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black54.withOpacity(0.2))))
                    ),
                    bottomNavigationBar: BottomNavigationBar(
                      items: items,
                      currentIndex: _selectedIndex,
                      selectedItemColor: fabColor,
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