import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:badges/badges.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/payment/topup.dart';
import 'package:pocketshopping/src/profile/settings.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/request/bloc/requestBloc.dart';
import 'package:pocketshopping/src/request/request.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/ui/shared/businessSetup.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:workmanager/workmanager.dart';

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
  final _walletNotifier = ValueNotifier<Wallet>(null);

  Stream<int> _requestCounterStream;
  final _requestCounter = ValueNotifier<int>(0);
  @override

  void initState() {
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if (mounted) {
        _walletNotifier.value=null;
        _walletNotifier.value = wallet;

      }
    });

    _requestCounterStream = RequestBloc.instance.requestCounter;
    _requestCounterStream.listen((event) {
      _requestCounter.value=0;
      _requestCounter.value=event;
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
            height: MediaQuery.of(context).size.height * 0.42,
            child: DrawerHeader(
              child: Center(
                  child: Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                 //Expanded(
                  // child:
                  CircularProfileAvatar(
                    widget.user.profile.isNotEmpty?widget.user.profile:PocketShoppingDefaultAvatar,
                    radius:  MediaQuery.of(context).size.height * 0.1,
                    backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
                    borderWidth: 5,  // sets border, default 0.0
                    initialsText: Text(
                      "${widget.user.fname[0].toUpperCase()}",
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                    borderColor: const Color.fromRGBO(245, 245, 245, 1), // sets border color, default Colors.white
                    elevation: 5.0, // sets elevation (shadow of the profile picture), default value is 0.0
                    foregroundColor: Colors.brown.withOpacity(0.5), //sets foreground colour, it works if showInitialTextAbovePicture = true , default Colors.transparent
                    cacheImage: true,
                    onTap: () {
                      print('adil');
                    }, // sets on tap
                    showInitialTextAbovePicture: true,
                  ),
                // ),
                  Expanded(
                    flex:0,
                    child: Text(widget.user.fname, textScaleFactor: 1),
                  ),
                  Expanded(
                    flex:0,
                    child: ValueListenableBuilder(
                      valueListenable: _walletNotifier,
                      builder: (_,Wallet wallet,__){
                        if(wallet != null){
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("PocketBalance: $CURRENCY ${wallet.walletBalance}",
                                  textScaleFactor: 1.3),
                              FlatButton(
                                onPressed: () {Get.dialog(TopUp(user: widget.user,));},
                                color: PRIMARYCOLOR,
                                child: const Text(
                                  "TopUp",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        }
                        else{return const SizedBox.shrink();}
                      },
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
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text("Request"),
            onTap: () {
              Navigator.pop(context);
              Get.to(RequestScreen(requests: [],uid: widget.user.uid,));
            },
            trailing: ValueListenableBuilder(
              valueListenable: _requestCounter,
              builder: (_,int count,__){
                return Badge(badgeContent: Text('$count',style: TextStyle(color: Colors.white),),
                showBadge: count>0,
                );
              },
            )
          ),
          if (widget.user.role == 'user')
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text("Business"),
              onTap: () {
                Get.back();
                Get.to(FirstBusinessPage());
              },
            ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Get.back();
              Get.to(Settings(user: widget.user,));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("AboutUs"),
            onTap: () {
              Get.back();
              Get.to(BSetup(
                userRepository: widget._userRepository,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text("SignOut"),
            onTap: ()async {
              await Utility.stopAllService();
              BlocProvider.of<AuthenticationBloc>(context).add(
                LoggedOut(),
              );
              //Navigator.pop(context);
            },
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              decoration: new BoxDecoration(
                //color: Colors.white,
                image: new DecorationImage(
                  fit: BoxFit.contain,
                  colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.2), BlendMode.dstATop),
                  image: AssetImage('assets/images/blogo.png',),
                ),
              ),
              height: 100,
              width: 200,
              //child:
            )
          )
        ],
      ),

    );
  }
}
