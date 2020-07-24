import 'dart:async';
import 'dart:convert';

import 'package:ant_icons/ant_icons.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/admin/product/manage.dart';
import 'package:pocketshopping/src/admin/staff/managerTransaction.dart';
import 'package:pocketshopping/src/admin/staff/salesTransactions.dart';
import 'package:pocketshopping/src/admin/staff/staffList.dart';
import 'package:pocketshopping/src/business/mangeBusiness.dart';
import 'package:pocketshopping/src/channels/repository/channelRepo.dart';
import 'package:pocketshopping/src/customerCare/customerCare.dart';
import 'package:pocketshopping/src/logistic/agentCompany/agentList.dart';
import 'package:pocketshopping/src/logistic/agentCompany/automobileList.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/payment/topup.dart';
import 'package:pocketshopping/src/pos/productList.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/ui/shared/dynamicLinks.dart';
import 'package:pocketshopping/src/user/agent/requestPocketSense.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:workmanager/workmanager.dart';

class StaffDashBoardScreen extends StatefulWidget {
  @override
  _StaffDashBoardScreenState createState() => new _StaffDashBoardScreenState();
}

class _StaffDashBoardScreenState extends State<StaffDashBoardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Session currentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  Stream<LocalNotification> _notificationsStream;
  StreamSubscription iosSubscription;
  Stream<Wallet> _walletStream;
  Wallet _wallet;
  bool isLocked;

  @override
  void initState() {
    currentUser = BlocProvider.of<UserBloc>(context).state.props[0];
    isLocked = (!currentUser.staff.staffPermissions.managers && (!Utility.isOperational(currentUser.merchant.bOpen, currentUser.merchant.bClose) || currentUser.merchant.bStatus != 1)) || !currentUser.staff.parentAllowed;
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      showBottom();
    });
    WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
    WalletRepo.getWallet(currentUser.merchant.bWallet).then((value) {
      if (mounted) {
        _wallet = value;
        setState(() {});
      }
    });
/*    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if (mounted) {
        _wallet = wallet;
        setState(() {});
      }
    });*/
    ChannelRepo.update(currentUser.merchant.mID, currentUser.user.uid);
    Workmanager.cancelAll();
    super.initState();
  }

  showBottom() {
    //GetBar(title: 'tdsd',messageText: Text('sdsd'),duration: Duration(seconds: 2),).show();
  }

  void reloadMerchant(){
    BlocProvider.of<UserBloc>(context).add(LoadUser(currentUser.user.uid));
  }

  @override
  void dispose() {
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

                        Center(
                          child: const Text(
                            'Staff',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        if(!currentUser.staff.staffPermissions.managers && currentUser.staff.staffPermissions.sales)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Card(
                              child: MenuItem(
                                  MediaQuery.of(context).size.height*0.25,
                                  Icon(
                                    AntIcons.printer_outline,
                                    size: MediaQuery.of(context).size.width * 0.3,
                                    color: PRIMARYCOLOR.withOpacity(0.8),
                                  ),
                                  'Point of Sale',
                                  border: PRIMARYCOLOR,
                                  isMultiMenu: false,
                                  content: ProductList(user: currentUser,callBckActionType: 3,route: 1,),
                                  isLocked: isLocked
                              ),
                            ),
                          )
                        )
                      ],
                    )),
                if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.finances || currentUser.staff.staffPermissions.sales)
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
                                          "PocketUnit",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        Center(
                                            child: Text(
                                              "1.00 unit = ${CURRENCY}1.00",
                                              style: TextStyle(
                                                  fontSize: 11),
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
                                        if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.finances)
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: PRIMARYCOLOR
                                                    .withOpacity(0.5)),
                                            color:
                                                PRIMARYCOLOR.withOpacity(0.8),
                                          ),
                                          child: FlatButton(
                                            onPressed: ()  {
                                            //FocusScope.of(context).requestFocus(FocusNode()),
                                            Get.dialog(TopUp(user: User(currentUser.merchant.mID,role: 'staff',walletId: currentUser.merchant.bWallet,email: currentUser.user.email),payType: "TOPUPUNIT",)).then((value) {
                                              WalletRepo.getWallet(currentUser.merchant.bWallet).then((value) {
                                                if (mounted) {
                                                  _wallet = value;
                                                  setState(() {});
                                                }
                                              });
                                            });
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
                  GestureDetector(
                    onTap: (){
                      //print(currentUser.agent.agentID);
                      //Get.to(MyDelivery(orders: orders,user: currentUser,)).then((value) => null);
                    },
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('${1+1}',
                              textAlign: TextAlign.center,
                              style: TextStyle(color:PRIMARYCOLOR,fontSize: 25),),
                            const Text('Transaction(s) Today',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: PRIMARYCOLOR),),
                          ],

                        )

                    ),
                  ),
                  GestureDetector(
                    onTap: (){},
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('$CURRENCY ${Utility.numberFormatter(0)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: PRIMARYCOLOR,fontSize: 25),),
                          const Text('Amount Made Today',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: PRIMARYCOLOR),),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){},
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if(Utility.isOperational(currentUser.merchant.bOpen, currentUser.merchant.bClose) && currentUser.merchant.bStatus == 1)
                          Text('${currentUser.merchant.bCategory} is open ',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: PRIMARYCOLOR),),
                          if(!(Utility.isOperational(currentUser.merchant.bOpen, currentUser.merchant.bClose)) || currentUser.merchant.bStatus != 1)
                            Text('${currentUser.merchant.bCategory} is closed ',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: PRIMARYCOLOR),),
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
                    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.sales)
                    MenuItem(
                      gridHeight,
                      Icon(
                        AntIcons.shop_outline,
                        size: MediaQuery.of(context).size.width * 0.1,
                        color: PRIMARYCOLOR.withOpacity(0.8),
                      ),
                      'Transactions',
                      border: PRIMARYCOLOR,
                      content: (!currentUser.staff.staffPermissions.managers && currentUser.staff.staffPermissions.sales)?SalesTransactions(user: currentUser,title: 'Transactions',):Transactions(user: currentUser,title: 'Transactions',),
                      isMultiMenu: false,
                       isLocked: isLocked
                    ),
                    if(currentUser.staff.staffPermissions.managers)
                    MenuItem(
                      gridHeight,
                      Icon(
                        AntIcons.printer_outline,
                        size: MediaQuery.of(context).size.width * 0.1,
                        color: PRIMARYCOLOR.withOpacity(0.8),
                      ),
                      'Point of Sale',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: ProductList(user: currentUser,callBckActionType: 3,route: 1,),
                      isLocked: isLocked
                    ),
                    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.products)
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.shopping_outline,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Products',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: ManageProduct(user: currentUser,),
                      isLocked: isLocked
                    ),
                    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.finances)
                    MenuItem(
                        gridHeight,
                        Icon(AntIcons.pie_chart_outline,
                            size: MediaQuery.of(context).size.width * 0.1,
                            color: PRIMARYCOLOR.withOpacity(0.8)),
                        'Statistic',
                        border: PRIMARYCOLOR,

                        content: Text('hello'),
                      isLocked: isLocked
                    ),
                    //if(currentUser.staff.staffPermissions.managers)
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.user,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Staffs',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: StaffList(user: currentUser,title: 'Manage Staff(s)',callBckActionType: 3,route: 1,),
                    ),
                    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.finances)
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.deployment_unit,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'PocketUnit',
                      border: PRIMARYCOLOR,
                      content: Text('hello'),
                      isLocked: isLocked
                    ),
                    /*MenuItem(
                      gridHeight,
                      Icon(AntIcons.history,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Withdrawal(s)',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: AgentList(user: currentUser,title: 'Manage Agent(s)',callBckActionType: 3,route: 1,),
                    ),*/
                    /*MenuItem(
                      gridHeight,
                      Icon(Icons.thumb_up,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Reviews',
                      border: PRIMARYCOLOR,
                      isBadged: true,
                      badgeType: 'icon',
                      isMultiMenu: false,
                      openCount: 3,
                      content: Reviews(themeColor: PRIMARYCOLOR),
                    ),*/
                    /*if(currentUser.staff.staffPermissions.managers)
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.setting_outline,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Settings',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: ManageBusiness(session: currentUser,),
                      refresh: reloadMerchant,
                    ),*/
                    /*MenuItem(
                      gridHeight,
                      Icon(AntIcons.home_outline,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Branch',
                      border: PRIMARYCOLOR,
                      content: Text('hello'),
                    ),*/

                    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.logistic)
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.check,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Rider Clearance',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: AgentList(user: currentUser,callBckActionType: 2,title: 'Agent Clearance',),
                      isLocked: isLocked
                    ),
                    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.logistic)
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.car_outline,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My AutoMobile(s)',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: AutomobileList(user: currentUser,title: 'My Automobile',callBckActionType: 1,),
                      isLocked: isLocked
                    ),
                    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.logistic)
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.user_add_outline,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My Rider(s)',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: AgentList(user: currentUser,title: 'Manage Rider(s)',callBckActionType: 3,route: 1,),
                      isLocked: isLocked
                    ),
                    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.logistic)
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.pushpin_outline,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Rider Tracker',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: AgentList(user: currentUser,),
                      isLocked: isLocked
                    ),
                    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.logistic)
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.smile_outline,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'PocketSense',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: RequestPocketSense(user: currentUser,),
                      isLocked: isLocked
                    ),
                    if(currentUser.staff.staffPermissions.managers)
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.customer_service_outline,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Customer Care',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: CustomerCare(session: currentUser,),
                      isLocked: isLocked
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
