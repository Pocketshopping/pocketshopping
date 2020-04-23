import 'package:flutter/material.dart';
import 'package:pocketshopping/firebase/BaseAuth.dart';
import 'package:pocketshopping/page/drawer/Business.dart';
import 'package:pocketshopping/page/drawer/aboutus.dart';
import 'package:pocketshopping/page/drawer/notification.dart';
import 'package:pocketshopping/page/drawer/pocket.dart';
import 'package:pocketshopping/page/drawer/profile.dart';
import 'package:pocketshopping/page/drawer/usetting.dart';
import 'package:pocketshopping/page/login.dart';
import 'package:pocketshopping/component/psProvider.dart';

class DrawerWidget extends StatelessWidget {
  var authHandler = new Auth();
  final Color headerColor;
  DrawerWidget({this.headerColor=Colors.white});
  @override
      Widget build(BuildContext context) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                color: headerColor,
                height: MediaQuery.of(context).size.height*0.35,
                child: DrawerHeader(
              
                child: new Center(
            child: new Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                    width: MediaQuery.of(context).size.width*0.3,
                    height: MediaQuery.of(context).size.height*0.15,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(
                                "https://i.imgur.com/BoN9kdC.png")
                        )
                    )),
                new Text("John Doe",
                    textScaleFactor: 1),
                
                new Text("Balance: \u20A6 456.09",
                    textScaleFactor: 1.3),
                Expanded(
                  child: FlatButton(
                    onPressed: (){},
                    color: Colors.white,
                    child: Text("TopUp"),
                  ),
                ),
              ],
            )),
                decoration: BoxDecoration(
                  //color: Colors.green,
                  
                  ),
              ),

              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Profile"),
                
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.attach_money),
                title: Text("Manage Fund"),
                
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PocketPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications_active),
                title: Text("Request"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationPage()));
                },
              ),
              if(psProvider.of(context).value['user']['role']=='user')
              ListTile(
                leading: Icon(Icons.business),
                title: Text("Business"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BusinessPage()));
                },

              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserSettingPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text("AboutUs"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutUsPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.close),
                title: Text("SignOut"),
                onTap: () {
                  authHandler.signOut();
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),
            ],
          ),
        );
        
        }
        }