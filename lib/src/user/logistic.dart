import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/component/scanScreen.dart';
import 'package:pocketshopping/page/admin/settings.dart';
import 'package:pocketshopping/page/admin/viewItem.dart';
import 'package:pocketshopping/src/admin/bottomScreen/logisticComponent/AgentBS.dart';
import 'package:pocketshopping/src/admin/bottomScreen/logisticComponent/statisticBS.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/channels/repository/channelRepo.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:pocketshopping/widget/account.dart';
import 'package:pocketshopping/widget/reviews.dart';
import 'package:pocketshopping/widget/status.dart';

import 'file:///C:/dev/others/pocketshopping/lib/src/admin/bottomScreen/logisticComponent/vehicleBS.dart';

class LogisticDashBoardScreen extends StatefulWidget {
  LogisticDashBoardScreen();

  @override
  _LogisticDashBoardScreenState createState() =>
      new _LogisticDashBoardScreenState();
}

class _LogisticDashBoardScreenState extends State<LogisticDashBoardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Session currentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  Stream<LocalNotification> _notificationsStream;
  StreamSubscription iosSubscription;
  Stream<Wallet> _walletStream;
  Wallet _wallet;
  final _agentNotifier = ValueNotifier<int>(0);
  final _isOperationalNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    currentUser = BlocProvider.of<UserBloc>(context).state.props[0];
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      showBottom();
    });

    WalletRepo.getWallet(currentUser.user.walletId)
        .then((value) => WalletBloc.instance.newWallet(value));
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if (mounted) {
        _wallet = wallet;
        setState(() {});
      }
    });

    LogisticRepo.fetchMyAvailableAgents(currentUser.merchant.mID).listen((event) {

      _agentNotifier.value = event;
    });

    ChannelRepo.update(currentUser.merchant.mID, currentUser.user.uid);

    Utility.noWorker().then((value) => null);
    super.initState();
  }

  showBottom() {
    //GetBar(title: 'tdsd',messageText: Text('sdsd'),duration: Duration(seconds: 2),).show();
  }

  @override
  void dispose() {
    _notificationsStream = null;
    _walletStream = null;
    iosSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double marginLR = MediaQuery.of(context).size.width;
    double gridHeight = MediaQuery.of(context).size.height * 0.1;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
              0.1), // here the desired height
          child: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: PRIMARYCOLOR,
                size: marginLR * 0.08,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.notification_important,
                  color: PRIMARYCOLOR,
                  size: marginLR * 0.08,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ],
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.white,
            title: Text(
              currentUser.merchant.bName ?? "Pocketshopping",
              style: TextStyle(color: PRIMARYCOLOR),
            ),
            automaticallyImplyLeading: false,
          ),
        ),
        body: Container(
            color: Colors.white,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                    delegate: SliverChildListDelegate(
                  [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Container(
                      color: Colors.white,
                      //margin:  MediaQuery.of(context).size.height*0.05,
                      margin: EdgeInsets.only(
                          left: marginLR * 0.01, right: marginLR * 0.01),
                      child: Column(
                        children: <Widget>[
                          if (_wallet != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Center(
                                            child: Text(
                                          "Business Revenue",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        Center(
                                            child: Text(
                                              "collected by pocketshopping",
                                              style: TextStyle(
                                                  fontSize: 11),
                                            )),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Center(
                                            child: Text(
                                          "\u20A6 ${_wallet.merchantBalance}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        if(_wallet.deliveryBalance>100) Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: PRIMARYCOLOR
                                                    .withOpacity(0.5)),
                                            color:
                                                PRIMARYCOLOR.withOpacity(0.5),
                                          ),
                                          child: FlatButton(
                                            onPressed: () => {
                                              sendAndRetrieveMessage()
                                                  .then((value) => null)
                                            },
                                            child: Center(
                                                child: Text(
                                              "Withdraw",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                          ),
                                        )
                                      ],
                                    )
                                ),
                               const Expanded(
                                  flex: 0,
                                  child: SizedBox(
                                    width: 10,
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Center(
                                            child: Text(
                                              "Delivery Revenue",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        const Center(
                                            child: Text(
                                              "collected by pocketshopping",
                                              style: TextStyle(
                                                  fontSize: 11),
                                            )),
                                       const  SizedBox(
                                          height: 10,
                                        ),
                                        Center(
                                            child: Text(
                                              "\u20A6 ${_wallet.deliveryBalance}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        if(_wallet.deliveryBalance>100)Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: PRIMARYCOLOR
                                                    .withOpacity(0.5)),
                                            color:
                                            PRIMARYCOLOR.withOpacity(0.5),
                                          ),
                                          child: FlatButton(
                                            onPressed: () => {
                                              sendAndRetrieveMessage()
                                                  .then((value) => null)
                                            },
                                            child: Center(
                                                child: Text(
                                                  "Withdraw",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          ),
                                        )
                                      ],
                                    )
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ],
                )),
                SliverGrid.count(crossAxisCount: 3, children: [
                  GestureDetector(
                    onTap: (){},
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                      decoration: BoxDecoration(
                        color: PRIMARYCOLOR.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            //offset: Offset(1.0, 0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: _agentNotifier,
                        builder: (_,agent,__){
                          return GestureDetector(
                              onTap: (){},
                              child:
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('${agent}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white,fontSize: 18),),
                                  const Text('Available Agent',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white),),
                                  const Text('click for details',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white,fontSize: 11),),
                                ],
                              )
                          );
                        },
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){},
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                      decoration: BoxDecoration(
                        color: PRIMARYCOLOR.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            //offset: Offset(1.0, 0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('$CURRENCY O',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white,fontSize: 18),),
                          const Text('Amount Made Today',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),),
                          const Text('click for more',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white,fontSize: 11),),
                        ],
                      ),
                    ),
                  ),
                  ValueListenableBuilder(
                      valueListenable: _isOperationalNotifier,
                      builder: (_,available,__){
                        return GestureDetector(
                          onTap: (){},
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                            decoration: BoxDecoration(
                              color: PRIMARYCOLOR.withOpacity(0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  //offset: Offset(1.0, 0), //(x,y)
                                  blurRadius: 6.0,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('We are currently '
                                    '${available?'Operational':'Unoperational'}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),),
                                FlatButton(
                                  onPressed: ()async{
                                    /*bool change =!available;
                                    bool result = await LocRepo.updateAvailability(currentUser.agent.agentID, change);
                                    if(!(change == result))
                                      GetBar(title: 'Error changing your status please try again');
                                    else
                                      _isAvailableNotifier.value = result;*/
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                    child: const Text('Change'),
                                  ),
                                  color: Colors.white.withOpacity(0.5),
                                )
                              ],
                            ),
                          ),
                        );
                      })
                ]),
                SliverList(
                    delegate: SliverChildListDelegate([
                  Container(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ])),
                SliverList(
                    delegate: SliverChildListDelegate(
                  [
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 0.5,
                                color: PRIMARYCOLOR.withOpacity(0.5)),
                          ),
                          color: Colors.white),
                      padding: EdgeInsets.only(left: marginLR * 0.04),
                      child: Text(
                        "Menu",
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                )),
                SliverGrid.count(
                  crossAxisCount: 3,
                  children: [
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.pie_chart,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Report',
                      border: PRIMARYCOLOR,
                      content: LogisticStatBottomPage(),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.local_taxi,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My AutoMobile(s)',
                      border: PRIMARYCOLOR,
                      content: VehicleBottomPage(
                        session: currentUser,
                      ),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.motorcycle,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My Agent(s)',
                      border: PRIMARYCOLOR,
                      content: AgentBottomPage(
                        session: currentUser,
                      ),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.local_pizza,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Deliveries',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: Reviews(themeColor: PRIMARYCOLOR),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(Icons.settings,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Settings',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: Settings(),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(Icons.account_box,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Business Account',
                      border: PRIMARYCOLOR,
                      content: AccountPage(
                        themeColor: PRIMARYCOLOR,
                      ),
                      isMultiMenu: false,
                    ),
                  ],
                ),
                SliverList(
                    delegate: SliverChildListDelegate(
                  [
                    Container(
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                  ],
                )),
              ],
            )));
  }

  Future<void> sendAndRetrieveMessage() async {
    print('team meeting');
    await _fcm.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );
    var response = await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'big body',
            'title': 'titler'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': ['route', 'heart']
          },
          'registration_ids': [
            'dI7Jp8onQPi2icNicdNqMU:APA91bFUZEsW-z2Vo5dMjeyqd2mY3No20gmCBoCZZkeKD58fzBKnAEehiZvTmYuYVNwUKSvozpUuCZadGvBrN2HdoXlY6BsCsblf0QaF10fBmxuJrKz1OB4NbpG9i5r8ABLdUON2wUqg',
            'cjFv_dGURZGxSJnBnHL3YU:APA91bECZPoh-OPVxk9QMkieFLXu9TBOKAw2MkfRmBkp8aOeMhnEtc_f7kgSxJCX5GNkV75300HLebhpLQ-vYn_VVwi1fMm9IMvwqfJlx3HPFewM4L56j24xklA8JP9qQaq6ooi_xxoZ'
          ],
        }));

    if (response.statusCode == 200) {
      print("Notification send !");
    } else {
      print("false");
    }
  }
}
