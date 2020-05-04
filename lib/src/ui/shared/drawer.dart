import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketshopping/page/drawer/aboutus.dart';
import 'package:pocketshopping/page/drawer/notification.dart';
import 'package:pocketshopping/page/drawer/pocket.dart';
import 'package:pocketshopping/page/drawer/profile.dart';
import 'package:pocketshopping/page/drawer/usetting.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/user/package_user.dart';

class DrawerScreen extends StatelessWidget {
  final UserRepository _userRepository;
  final User user;

  DrawerScreen({Key key, @required UserRepository userRepository, this.user})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.35,
            child: DrawerHeader(
              child: new Center(
                  child: new Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.15,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(
                                  "https://i.imgur.com/BoN9kdC.png")))),
                  new Text(user.fname, textScaleFactor: 1),
                  new Text("Balance: \u20A6 456.09", textScaleFactor: 1.3),
                  Expanded(
                    child: FlatButton(
                      onPressed: () {},
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: Text("Manage Fund"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PocketPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text("Request"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NotificationPage()));
            },
          ),
          if (user.role == 'user')
            ListTile(
              leading: Icon(Icons.business),
              title: Text("Business"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FirstBusinessPage()));
              },
            ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserSettingPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text("AboutUs"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutUsPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.close),
            title: Text("SignOut"),
            onTap: () {
              BlocProvider.of<AuthenticationBloc>(context).add(
                LoggedOut(),
              );
              //Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
