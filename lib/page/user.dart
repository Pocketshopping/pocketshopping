

import 'package:flutter/material.dart';
import 'package:bottom_navigation_badge/bottom_navigation_badge.dart';
import 'package:badges/badges.dart';
import 'package:pocketshopping/page/user/favourite.dart';
import 'package:pocketshopping/page/user/places.dart';
import 'package:pocketshopping/page/user/merchant.dart';
import 'package:pocketshopping/page/user/order.dart';
import 'package:pocketshopping/page/user/drawer.dart';
import 'package:pocketshopping/util/data.dart';
import 'package:pocketshopping/page/user/locations.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:flutter/services.dart';


class UserPage extends StatefulWidget {
  static String tag = 'User-page';
  @override
  _UserPageState createState() => new _UserPageState();
}

class _UserPageState extends State<UserPage> {

int _selectedIndex;
int _cartCount;
Color fabColor;
var _cart;
var _merchant;
//CartCollection _cartCollection;
GlobalKey globalKey = new GlobalKey(debugLabel: '_UserPageState');
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
    _cartCount=0;
    _cart = Map();
    _merchant = Map();
    fabColor = PRIMARYCOLOR;
  }

void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}



void _removeFromCart(String key){
  setState(() {
  _cart.remove(key);
  });
}

bool _addToCart(Map item, String key){

  if(_cart.containsKey(key))
    return false;
  else{
    setState(() {
  _cart[key] = item;
  _cartCount +=1;
  });
    return true;
  }
  
}

Map _getBasket(){
  return _cart;
}

  int _getBasketCount(){
    return _cartCount;
  }

void _setFabColor(Color color){
  setState(() {
    fabColor=color;
  });
}
void _setMerchant(Map merchant){
  setState(() {
  _merchant=merchant;
  });
}

Map _getMerchant(){
  return _merchant;
}





@override
Widget build(BuildContext context) {
  session _session = new session(
    _addToCart,
    _removeFromCart,
    _getBasket,
    _onItemTapped,
    _getMerchant
    ,_setMerchant,
    _setFabColor,
    _getBasketCount,
    );
  //setState(() {
  //items = badger.setBadge(items, "1", _selectedIndex);
//});
//setState(() {
  //items = badger.setBadge(items, "4", 2);
//});
  return WillPopScope(
      onWillPop: _onWillPop,
      child:Scaffold(
    drawer: DrawerWidget(),
    body: Container(
      
      child:Center(
      child: <Widget>[
 LocationUI(themeColor:fabColor),
 Favourite(),
 //MerchantWidget(_session),
 OrderWidget(_session,fabColor),
      ].elementAt(_selectedIndex),
    ),
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black54.withOpacity(0.2))))
    ),
    bottomNavigationBar: BottomNavigationBar(
      key: globalKey,
      items: items,
      currentIndex: _selectedIndex,
      selectedItemColor: fabColor,
      unselectedItemColor: Colors.black54,
      showUnselectedLabels: true,
      onTap: _onItemTapped,
    ),
      )
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