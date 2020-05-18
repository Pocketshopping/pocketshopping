import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:pocketshopping/component/scanScreen.dart';
import 'package:pocketshopping/page/admin/message.dart';
import 'package:pocketshopping/page/admin/openOrder.dart';
import 'package:pocketshopping/page/admin/settings.dart';
import 'package:pocketshopping/page/admin/viewItem.dart';
import 'package:pocketshopping/page/user/merchant.dart';
import 'package:pocketshopping/src/admin/bottomScreen/logisticComponent/AgentBS.dart';
import 'package:pocketshopping/src/admin/bottomScreen/logisticComponent/statisticBS.dart';
import 'file:///C:/dev/others/pocketshopping/lib/src/admin/bottomScreen/logisticComponent/vehicleBS.dart';
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
import 'package:pocketshopping/src/utility/utility.dart';

class AgentDashBoardScreen extends StatefulWidget {
  @override
  _AgentDashBoardScreenState createState() => new _AgentDashBoardScreenState();
}

class _AgentDashBoardScreenState extends State<AgentDashBoardScreen> {
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
    Workmanager.registerPeriodicTask(
        "AGENTLOCATIONUPDATE", "LocationUpdateTask",
        frequency: Duration(minutes: 15),
        inputData: {
          'agentID': CurrentUser.agent.agentID,
          'agentAutomobile': CurrentUser.agent.autoType,
          'availability': true,
          'agentTelephone': CurrentUser.user.telephone,
          'agentName': CurrentUser.user.fname,
        });

    Utility.locationAccess();
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
                    Center(
                      child: Text(
                        'Agent',
                        style: TextStyle(fontSize: 20),
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
                    actionText: 'Deliveries today',
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
                      Icon(MaterialIcons.local_taxi,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My AutoMobile',
                      border: PRIMARYCOLOR,
                      content: VehicleBottomPage(
                        session: CurrentUser,
                      ),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(Icons.settings,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My Account',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: Settings(),
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
}
