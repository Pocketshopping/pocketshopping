import 'package:bottom_navigation_badge/bottom_navigation_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pocketshopping/component/psProvider.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/model/DataModel/categoryData.dart';
import 'package:pocketshopping/model/DataModel/notificationDataModel.dart';
import 'package:pocketshopping/model/DataModel/userData.dart';
import 'package:pocketshopping/page/user/drawer.dart';
import 'package:pocketshopping/page/user/favourite.dart';
import 'package:pocketshopping/page/user/locations.dart';
import 'package:pocketshopping/page/user/order.dart';

class UserPage extends StatefulWidget {
  static String tag = 'User-page';

  @override
  _UserPageState createState() => new _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex;
  Color fabColor;

//CartCollection _cartCollection;
  GlobalKey globalKey = new GlobalKey(debugLabel: '_UserPageState');
  BottomNavigationBadge badger = new BottomNavigationBadge(
      backgroundColor: Colors.red,
      badgeShape: BottomNavigationBadgeShape.circle,
      textColor: Colors.white,
      position: BottomNavigationBadgePosition.topRight,
      textSize: 8);
  List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[
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
  void initState() {
    super.initState();
    _selectedIndex = 0;
    fabColor = PRIMARYCOLOR;
    CategoryData()
        .getAll()
        .then((value) => psProvider.of(context).value['category'] = value);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (psProvider.of(context).value['user']['fname'] != null) {
        UserData(uid: psProvider.of(context).value['uid'])
            .getOne()
            .then((value) => {psProvider.of(context).value['user'] = value});
      }
      NotificationDataModel(
              uid: psProvider.of(context).value['uid'], nCleared: false)
          .getAll()
          .then((value) => {
                if (value.length > 0)
                  {
                    psProvider.of(context).value['notifications'] = value,
                    Scaffold.of(context).showSnackBar(SnackBar(
                      duration: Duration(seconds: 5),
                      content: Text(
                          'You have very important notification that needs your attention'),
                      action: SnackBarAction(
                        label: "View Now",
                        textColor: Colors.white,
                        //disabledTextColor: TEXT_BLACK_LIGHT,
                        onPressed: () {
                          print(
                              "I know you are testing the action in the SnackBar!");
                        },
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ))
                  }
              });
    });
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
        child: Scaffold(
          drawer: DrawerWidget(),
          body: Container(
              child: Center(
                child: <Widget>[
                  LocationUI(themeColor: fabColor),
                  Favourite(),
                  OrderWidget(fabColor),
                ].elementAt(_selectedIndex),
              ),
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: Colors.black54.withOpacity(0.2))))),
          bottomNavigationBar: BottomNavigationBar(
            key: globalKey,
            items: items,
            currentIndex: _selectedIndex,
            selectedItemColor: fabColor,
            unselectedItemColor: Colors.black54,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
          ),
        ));
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
            onPressed: () =>
                SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            child: new Text('Yes'),
          ),
        ],
      ),
    ));
  }
}
