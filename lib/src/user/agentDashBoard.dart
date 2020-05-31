import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/channels/repository/channelRepo.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/locRepo.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/order/bloc/orderBloc.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/payment/topup.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/agent/myAuto.dart';
import 'package:pocketshopping/src/user/agent/myDeliveries.dart';
import 'package:pocketshopping/src/user/agentBusiness.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:pocketshopping/widget/reviews.dart';
import 'package:workmanager/workmanager.dart';

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
  StreamSubscription orders;
  Stream<Wallet> _walletStream;
  Stream<List<Order>> _orderStream;
  Wallet _wallet;
  List<Order> newOrders;
  bool available;
  @override
  void initState() {
    newOrders = [];
    CurrentUser = BlocProvider.of<UserBloc>(context).state.props[0];
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      showBottom();
    });

    WalletRepo.getWallet(CurrentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if (mounted) {
        _wallet = wallet;
        setState(() {});
      }
    });

    orders = OrderRepo.agentOrder(CurrentUser.agent.agent).listen((event) {
      if(mounted)
        setState(() {
          if(!newOrders.contains(orders))
            newOrders.addAll(event);
        });
      OrderBloc.instance.newOrder(event);
    });
/*    _orderStream = OrderBloc.instance.orderStream;
    _orderStream.listen((orders) {
      if(mounted)
        setState(() {
          if(!newOrders.contains(orders))
          newOrders.addAll(orders);
        });
    });*/

    if(CurrentUser.agent == null)
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
          'wallet':CurrentUser.user.walletId,
          'agentParent':CurrentUser.agent.agentWorkPlace
        },


    );

    Utility.locationAccess();
    LogisticRepo.getOneAgentLocation(CurrentUser.agent.agentID).then((value){if(value != null) setState(() {available =value.availability;});});
    super.initState();
  }

  showBottom() {
    //GetBar(title: 'tdsd',messageText: Text('sdsd'),duration: Duration(seconds: 2),).show();
  }

  @override
  void dispose() {
    _notificationsStream = null;
    _walletStream = null;
    orders.cancel();
    _orderStream = null;
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
                                                onPressed: ()  {
                                                  //sendAndRetrieveMessage()
                                                  //  .then((value) => null)
                                                  //DynamicLinks
                                                  //  .createLinkWithParams({
                                                  //'merchant': 'rerereg',
                                                  //'OTP':
                                                  //  'randomNumber.toString()',
                                                  //'route': 'branch'
                                                  //}).then((value) => print(value))
                                                  Get.dialog(TopUp(user: CurrentUser.user,payType: "TOPUPUNIT",));

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
                              if(_wallet != null)
                               if (_wallet.pocketUnitBalance < 100)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                child: Text('${'Your PocketUnit is below the expected quota, this means you will be unavaliable for delivery until you topup'}'),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('O',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white,fontSize: 18),),
                          Text('Deliveries Today',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),),
                        ],
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
                          Text('O',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white,fontSize: 18),),
                          Text('Km Covered',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),),
                        ],
                      ),
                    ),
                  ),
                  if(available != null)
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
                          Text('I am currently '
                              '${available?'Available':'Unavailable'}',
                          textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),),
                          FlatButton(
                            onPressed: ()async{
                              bool change =!available;
                              bool result = await LocRepo.updateAvailability(CurrentUser.agent.agentID, change);
                              if(!(change == result))
                                GetBar(title: 'Error changing your status please try again');
                              else
                                setState(() {available = result; });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                              child: Text('Change'),
                            ),
                            color: Colors.white.withOpacity(0.5),
                          )
                        ],
                      ),
                    ),
                  )
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
                      isBadged: true,
                      isMultiMenu: false,
                      openCount: newOrders.length,
                      content: MyDelivery(orders: newOrders,user: CurrentUser,),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.local_taxi,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My AutoMobile',
                      isBadged: false,
                      isMultiMenu: false,
                      border: PRIMARYCOLOR,
                      content: MyAuto(agent: CurrentUser,),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.business_center,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'New Business',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: SetupBusiness(isAgent: true,),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.home,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My Business(es)',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: AgentBusiness(user: CurrentUser,),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.pie_chart,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Statistic',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: Reviews(themeColor: PRIMARYCOLOR),
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
