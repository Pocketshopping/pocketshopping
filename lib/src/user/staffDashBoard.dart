import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/component/scanScreen.dart';
import 'package:pocketshopping/page/admin/message.dart';
import 'package:pocketshopping/page/admin/openOrder.dart';
import 'package:pocketshopping/page/admin/settings.dart';
import 'package:pocketshopping/page/admin/viewItem.dart';
import 'package:pocketshopping/page/user/merchant.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/channels/repository/channelRepo.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/widget/account.dart';
import 'package:pocketshopping/widget/branch.dart';
import 'package:pocketshopping/widget/customers.dart';
import 'package:pocketshopping/widget/manageOrder.dart';
import 'package:pocketshopping/widget/reviews.dart';
import 'package:pocketshopping/widget/staffs.dart';
import 'package:pocketshopping/widget/statistic.dart';
import 'package:pocketshopping/widget/status.dart';
import 'package:pocketshopping/widget/unit.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:pocketshopping/src/ui/shared/dynamicLinks.dart';
import 'package:workmanager/workmanager.dart';

class StaffDashBoardScreen extends StatefulWidget {
  @override
  _StaffDashBoardScreenState createState() => new _StaffDashBoardScreenState();
}

class _StaffDashBoardScreenState extends State<StaffDashBoardScreen> {
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
    Workmanager.cancelAll();
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
                                          "\u20A6 ${_wallet.businessMoney}",
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
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Center(
                                            child: Text(
                                          "PocketUnit",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Center(
                                            child: Text(
                                          "${_wallet.pocketUnitBalance}",
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
                                              //sendAndRetrieveMessage()
                                              //  .then((value) => null)
                                              DynamicLinks
                                                  .createLinkWithParams({
                                                'merchant': 'rerereg',
                                                'OTP':
                                                    'randomNumber.toString()',
                                                'route': 'branch'
                                              }).then((value) => print(value))
                                            },
                                            child: Center(
                                                child: Text(
                                              "TopUp",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                          ),
                                        )
                                      ],
                                    )),
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
                    actionText: 'click to extend screen',
                    subHeader: 'Open Order(s)',
                    skey: scaffoldKey,
                    bgColor: PRIMARYCOLOR.withOpacity(0.8),
                    content: ScanScreen(PRIMARYCOLOR.withOpacity(0.8)),
                  ),
                  ViewItem(
                    gridHeight,
                    Header: 'Open',
                    subHeader: 'Store Status',
                    actionText: 'click to Change',
                    skey: scaffoldKey,
                    bgColor: PRIMARYCOLOR.withOpacity(0.8),
                    content: StatusBottomPage(
                        themeColor: PRIMARYCOLOR.withOpacity(0.8)),
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
                      Icon(
                        Icons.folder_open,
                        size: MediaQuery.of(context).size.width * 0.16,
                        color: PRIMARYCOLOR.withOpacity(0.8),
                      ),
                      'Open Orders',
                      border: PRIMARYCOLOR,
                      isBadged: true,
                      openCount: 3,
                      isMultiMenu: false,
                      content: Orders(),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(
                        Icons.folder,
                        size: MediaQuery.of(context).size.width * 0.16,
                        color: PRIMARYCOLOR.withOpacity(0.8),
                      ),
                      'Manage Orders',
                      border: PRIMARYCOLOR,
                      content: ManageOrder(
                        themeColor: PRIMARYCOLOR,
                      ),
                      isMultiMenu: false,
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(
                        Icons.person_pin,
                        size: MediaQuery.of(context).size.width * 0.16,
                        color: PRIMARYCOLOR.withOpacity(0.8),
                      ),
                      'Place Order For Customer',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: MerchantWidget(),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(Icons.message,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Customer Message',
                      border: PRIMARYCOLOR,
                      isBadged: true,
                      openCount: 3,
                      isMultiMenu: false,
                      content: Message(
                        themeColor: PRIMARYCOLOR,
                      ),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(Icons.fastfood,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Products',
                      border: PRIMARYCOLOR,
                      content: ProductBottomPage(
                        session: CurrentUser,
                      ),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(Icons.show_chart,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Statistic',
                      border: PRIMARYCOLOR,
                      content: StatisticBottomPage(
                        themeColor: PRIMARYCOLOR,
                      ),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(Icons.people,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Staffs',
                      border: PRIMARYCOLOR,
                      content: StaffBottomPage(
                        themeColor: PRIMARYCOLOR,
                      ),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(Icons.credit_card,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'PocketUnit',
                      border: PRIMARYCOLOR,
                      content: UnitBottomPage(
                        themeColor: PRIMARYCOLOR,
                      ),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(Icons.thumb_up,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Reviews',
                      border: PRIMARYCOLOR,
                      isBadged: true,
                      badgeType: 'icon',
                      isMultiMenu: false,
                      openCount: 3,
                      content: Reviews(themeColor: PRIMARYCOLOR),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(Icons.people_outline,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Customers',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: Customer(
                        themeColor: PRIMARYCOLOR,
                      ),
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
                      Icon(Icons.business,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Branch',
                      border: PRIMARYCOLOR,
                      content: BranchBottomPage(
                        themeColor: PRIMARYCOLOR,
                      ),
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
