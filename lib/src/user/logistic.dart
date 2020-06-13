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
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
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
  Session CurrentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  Stream<LocalNotification> _notificationsStream;
  StreamSubscription iosSubscription;
  Stream<Wallet> _walletStream;
  Wallet _wallet;

  @override
  void initState() {
    CurrentUser = BlocProvider.of<UserBloc>(context).state.props[0];
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      showBottom();
    });

    WalletRepo.getWallet(CurrentUser.user.walletId)
        .then((value) => WalletBloc.instance.newWallet(value));
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if (mounted) {
        _wallet = wallet;
        setState(() {});
      }
    });

    ChannelRepo.update(CurrentUser.merchant.mID, CurrentUser.user.uid);
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
              CurrentUser.merchant.bName ?? "Pocketshopping",
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
                                        SizedBox(
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
                                        Container(
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
                                    )),
                                Expanded(
                                  flex: 0,
                                  child: SizedBox(
                                    width: 10,
                                  ),
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
                  ViewItem(
                    gridHeight,
                    Header: '0',
                    actionText: 'Agent Currently Running',
                    subHeader: '',
                    skey: scaffoldKey,
                    bgColor: PRIMARYCOLOR.withOpacity(0.8),
                    content: ScanScreen(PRIMARYCOLOR.withOpacity(0.8)),
                  ),
                  ViewItem(
                    gridHeight,
                    Header: '0',
                    subHeader: '',
                    actionText: 'Km Covered Today',
                    skey: scaffoldKey,
                    bgColor: PRIMARYCOLOR.withOpacity(0.8),
                    content: StatusBottomPage(
                        themeColor: PRIMARYCOLOR.withOpacity(0.8)),
                  ),
                  ViewItem(
                    gridHeight,
                    Header: '0',
                    actionText: 'Amount Generated Today',
                    subHeader: '',
                    skey: scaffoldKey,
                    bgColor: PRIMARYCOLOR.withOpacity(0.8),
                    content: ScanScreen(PRIMARYCOLOR.withOpacity(0.8)),
                  ),
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
                      'Statistic and Analysis',
                      border: PRIMARYCOLOR,
                      content: LogisticStatBottomPage(),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.local_taxi,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'AutoMobile(s)',
                      border: PRIMARYCOLOR,
                      content: VehicleBottomPage(
                        session: CurrentUser,
                      ),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.motorcycle,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Agent',
                      border: PRIMARYCOLOR,
                      content: AgentBottomPage(
                        session: CurrentUser,
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
