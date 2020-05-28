import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/page/drawer/notification.dart';
import 'package:pocketshopping/page/drawer/pocket.dart';
import 'package:pocketshopping/page/drawer/profile.dart';
import 'package:pocketshopping/page/drawer/usetting.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/ui/shared/businessSetup.dart';
import 'package:pocketshopping/src/ui/shared/drawer/referral.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/payment/topup.dart';

class DrawerScreen extends StatefulWidget {
  final UserRepository _userRepository;
  final User user;

  DrawerScreen({Key key, @required UserRepository userRepository, this.user})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  _DrawerScreenState createState() => new _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  Stream<Wallet> _walletStream;
  Wallet _wallet;

  @override
  void initState() {
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if (mounted) {
        _wallet = wallet;
        if (mounted) setState(() {});
      }
    });
    super.initState();
  }

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
              child: Center(
                  child: Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.15,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(
                                  "https://i.imgur.com/BoN9kdC.png")))),
                  Text(widget.user.fname, textScaleFactor: 1),
                  if (_wallet != null)
                    Text("PocketBalance: \u20A6 ${_wallet.pocketBalance}",
                        textScaleFactor: 1.3),
                  if (_wallet != null)
                    Expanded(
                      child: FlatButton(
                        onPressed: () {Get.dialog(TopUp(user: widget.user,));},
                        color: PRIMARYCOLOR,
                        child: Text(
                          "TopUp",
                          style: TextStyle(color: Colors.white),
                        ),
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
          //if(_wallet != null)
          ListTile(
            leading: Icon(Icons.people),
            title: Text("referral"),
            onTap: () {
              Get.back();
              Get.to(Referral(walletId: widget.user.walletId));
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
          if (widget.user.role == 'user')
            ListTile(
              leading: Icon(Icons.business),
              title: Text("Business"),
              onTap: () {
                Get.back();
                Get.to(FirstBusinessPage());
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
              Get.back();
              Get.to(BSetup(
                userRepository: widget._userRepository,
              ));
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
