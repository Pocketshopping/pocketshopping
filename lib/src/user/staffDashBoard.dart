import 'dart:async';

import 'package:ant_icons/ant_icons.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/bottomScreen/unit.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/admin/product/manage.dart';
import 'package:pocketshopping/src/admin/staff/managerTransaction.dart';
import 'package:pocketshopping/src/admin/staff/salesTransactions.dart';
import 'package:pocketshopping/src/channels/repository/channelRepo.dart';
import 'package:pocketshopping/src/customerCare/customerCare.dart';
import 'package:pocketshopping/src/logistic/agentCompany/agentList.dart';
import 'package:pocketshopping/src/logistic/agentCompany/automobileList.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/order/bloc/orderBloc.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/payment/topUpPocket.dart';
import 'package:pocketshopping/src/payment/topup.dart';
import 'package:pocketshopping/src/payment/totpupScaffold.dart';
import 'package:pocketshopping/src/pos/productList.dart';
import 'package:pocketshopping/src/statistic/logisticStat.dart';
import 'package:pocketshopping/src/statistic/merchantStat.dart';
import 'package:pocketshopping/src/statistic/repository.dart';
import 'package:pocketshopping/src/stockManager/bloc/stockBloc.dart';
import 'package:pocketshopping/src/stockManager/repository/stock.dart';
import 'package:pocketshopping/src/stockManager/repository/stockRepo.dart';
import 'package:pocketshopping/src/stockManager/stocks.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/ui/shared/bonusDrawer.dart';
import 'package:pocketshopping/src/ui/shared/help.dart';
import 'package:pocketshopping/src/user/agent/myDeliveries.dart';
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
  final report = ValueNotifier<Map<String,dynamic>>({});
  final _orderNotifier = ValueNotifier<List<Order>>([]);
  final key = ValueNotifier<String>('');
  final pWallet = ValueNotifier<Wallet>(null);
  final _agentNotifier = ValueNotifier<int>(0);
  StreamSubscription orders;


  @override
  void initState() {
    currentUser = BlocProvider.of<UserBloc>(context).state.props[0];
    isLocked = (!currentUser.staff.staffPermissions.managers && (!Utility.isOperational(currentUser.merchant.bOpen, currentUser.merchant.bClose) || currentUser.merchant.bStatus != 1)) || !currentUser.staff.parentAllowed;
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      showBottom();
    });

    WalletRepo.getWallet(currentUser.user.walletId).then((value) {WalletBloc.instance.newWallet(value); pWallet.value =value;});
    WalletRepo.getWallet(currentUser.merchant.bWallet).then((value) {
      if (mounted) {
        _wallet = value;
        setState(() {});
      }
    });

    orders = OrderRepo.agentOrder(currentUser.merchant.mID,whose: 'orderLogistic').listen((event) {
      if(mounted)
      {
        _orderNotifier.value=[];
        _orderNotifier.value=event;
      }
      OrderBloc.instance.newOrder(event);
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


      if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.finances){
        StatisticRepo.getTodayStat(currentUser.merchant.mID,'').then((value) {setState(() {report.value = value;});});
      } else{StatisticRepo.getTodayStat(currentUser.merchant.mID,currentUser.user.uid).then((value) {setState(() {report.value = value;});});}

    LogisticRepo.fetchMyAvailableAgents(currentUser.merchant.mID).listen((event) {_agentNotifier.value = event;});
    super.initState();
  }

  showBottom() {
    //GetBar(title: 'tdsd',messageText: Text('sdsd'),duration: Duration(seconds: 2),).show();
  }

  void reloadMerchant({bool complete=false}){
    WalletRepo.getWallet(currentUser.merchant.bWallet).then((value) {
      if (mounted) {
        _wallet = value;
        setState(() {});
      }
    });
    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.finances){
      StatisticRepo.getTodayStat(currentUser.merchant.mID,'').then((value) {setState(() {report.value = value;});});
    } else{StatisticRepo.getTodayStat(currentUser.merchant.mID,currentUser.user.uid).then((value) {setState(() {report.value = value;});});}
    if(complete)
      BlocProvider.of<UserBloc>(context).add(LoadUser(currentUser.user.uid));
  }

  @override
  void dispose() {
    iosSubscription?.cancel();
    orders?.cancel();
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
            leading: BonusDrawerIcon(wallet: currentUser.user.walletId,
            openDrawer: (){Scaffold.of(context).openDrawer();},
            ),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.white,
            title: Text(
              currentUser.merchant.bName ?? "Pocketshopping",
              style: TextStyle(color: PRIMARYCOLOR),
            ),
            automaticallyImplyLeading: false,
            actions: [
              Help(page: 'staff',),
            ],
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
                          child:  Text(
                            '${currentUser.staff.staffPermissions.managers?'Manager':'Staff'}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        if(!currentUser.staff.parentAllowed)
                        const SizedBox(height: 10,),
                        if(!currentUser.staff.parentAllowed)
                        Center(
                          child: Text('Your account has deactivated by ${currentUser.merchant.bName} admin.',style: TextStyle(color: Colors.red),),
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
                if(currentUser.staff.parentAllowed)
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
                                            /*Get.dialog(TopUp(user: User(currentUser.merchant.mID,role: 'staff',walletId: currentUser.merchant.bWallet,email: currentUser.user.email),payType: "TOPUPUNIT",)).then((value) {
                                              WalletRepo.getWallet(currentUser.merchant.bWallet).then((value) {
                                                if (mounted) {
                                                  _wallet = value;
                                                  setState(() {});
                                                }
                                              });
                                            });*/
                                            if(!Get.isDialogOpen)
                                            Get.dialog(
                                              TopUpScaffold(
                                                user: currentUser.user,
                                                wallet: pWallet.value,
                                                atm: (){
                                                  Get.dialog(TopUp(user: User(currentUser.merchant.mID,role: 'staff',walletId: currentUser.merchant.bWallet,email: currentUser.user.email),payType: "TOPUPUNIT",)).then((value) {
                                                    Get.back();});
                                                },
                                                personal: (){
                                                  Get.dialog(TopUpPocket(
                                                    user: currentUser.user,
                                                    topUp: currentUser.merchant.bWallet,
                                                    wallet: pWallet.value,
                                                    isPersonal: 3,
                                                  )).then((value) {
                                                    Get.back();});
                                                },
                                                business: (){},
                                                delivery: (){},
                                              )
                                            ).then((value) {
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
                if(currentUser.staff.parentAllowed)
                SliverGrid.count(crossAxisCount: 3, children: [
                  if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.sales || currentUser.staff.staffPermissions.finances)
                  ValueListenableBuilder(
                    valueListenable: report,
                    builder: (_,Map<String,dynamic> _report,__){
                      return _report != null? GestureDetector(
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
                            child: _report.isNotEmpty?Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('${Utility.numberFormatter(_report['transactionCount'])}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color:PRIMARYCOLOR,fontSize: 25),),
                                const Text('Transaction(s) Today',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: PRIMARYCOLOR),),
                              ],

                            ):Center(
                              child: CircularProgressIndicator(),
                            )

                        ),
                      ):const SizedBox.shrink();
                    },
                  ),
                  if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.sales || currentUser.staff.staffPermissions.finances)
                  ValueListenableBuilder(
                    valueListenable: report,
                    builder: (_,Map<String,dynamic> _report,__){
                      return _report!=null?GestureDetector(
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
                          child: _report.isNotEmpty?Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('$CURRENCY${Utility.numberFormatter(_report['total'])}',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: PRIMARYCOLOR,fontSize: 25),),
                              const Text('Amount Made Today',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: PRIMARYCOLOR),),
                            ],
                          ):Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ):const SizedBox.shrink();;
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: report,
                    builder: (_,Map<String,dynamic> _report,__){
                      return GestureDetector(
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
                          child: _report.isNotEmpty || _report == null ?Column(
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
                          ):Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    },
                  ),
                  if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.logistic || currentUser.staff.staffPermissions.finances)
                  FutureBuilder(
                    future: Utility.logisticTodayAmount(currentUser.merchant.bWallet),
                    builder: (context,AsyncSnapshot<double>amount){
                      if(amount.connectionState == ConnectionState.waiting){
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      else if(amount.hasError){
                        //print(amount.error);
                        return GestureDetector(
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
                                const Text('Amount Made Today(logistic)',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: PRIMARYCOLOR),),
                              ],
                            ),
                          ),
                        );
                      }
                      else{
                        return GestureDetector(
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
                                Text('$CURRENCY ${Utility.numberFormatter(amount.data.round())}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: PRIMARYCOLOR,fontSize: 25),),
                                const Text('Amount Made Today(logistic)',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: PRIMARYCOLOR),),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.logistic)
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
                      child: ValueListenableBuilder(
                        valueListenable: _agentNotifier,
                        builder: (_,agent,__){
                          return GestureDetector(
                              onTap: (){
                                Get.to(AgentList(user: currentUser,)).then((value) => null);
                              },
                              child:
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('$agent',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: PRIMARYCOLOR,fontSize: 18),),
                                  const Text('Available Agent',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: PRIMARYCOLOR,),),
                                  const Text('click for details',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: PRIMARYCOLOR,fontSize: 11),),
                                ],
                              )
                          );
                        },
                      ),
                    ),
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
                       isLocked: isLocked,
                      refresh: reloadMerchant,
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
                      isLocked: isLocked,
                      refresh: reloadMerchant,
                    ),
                    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.products)
                    StreamBuilder(
                      stream: StockRepo.getOneStream(currentUser.merchant.mID),
                      builder: (context,AsyncSnapshot<List<Stock>>snapshot){
                        if(snapshot.hasData){StockBloc.instance.stocks(snapshot.data);}
                        return MenuItem(
                            gridHeight,
                            Icon(Icons.calendar_today,
                                size: MediaQuery.of(context).size.width * 0.1,
                                color: PRIMARYCOLOR.withOpacity(0.8)),
                            'Stock Manager',
                            border: PRIMARYCOLOR,
                            isBadged: true,
                            isMultiMenu: false,
                            openCount: snapshot.hasData?snapshot.data.length:0,
                            content: StockManager(user: currentUser,),
                            isLocked: isLocked,
                          refresh: reloadMerchant,
                        );
                      },
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
                      isLocked: isLocked,
                      refresh: reloadMerchant,
                    ),
                    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.finances)
                    MenuItem(
                        gridHeight,
                        Icon(AntIcons.pie_chart_outline,
                            size: MediaQuery.of(context).size.width * 0.1,
                            color: PRIMARYCOLOR.withOpacity(0.8)),
                        'Report',
                        border: PRIMARYCOLOR,

                        content: MerchantStatistic(user: currentUser,title: 'Report',),
                      isMultiMenu: false,
                      isLocked: isLocked,
                      refresh: reloadMerchant,
                    ),
                    //if(currentUser.staff.staffPermissions.managers)
                    /*MenuItem(
                      gridHeight,
                      Icon(AntIcons.user,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Staffs',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: StaffList(user: currentUser,title: 'Manage Staff(s)',callBckActionType: 3,route: 1,),
                    ),*/
                    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.finances)
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.deployment_unit,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'PocketUnit',
                      border: PRIMARYCOLOR,
                      content: UnitBottomPage(user: currentUser,wallet: currentUser.merchant.bWallet,
                        sender:User(currentUser.merchant.mID,role: 'admin',
                            walletId: currentUser.merchant.bWallet,email: currentUser.user.email,fname: currentUser.merchant.bName),
                      ),
                      isLocked: isLocked,
                      refresh: reloadMerchant,
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
                      isLocked: isLocked,
                      refresh: reloadMerchant,
                    ),
                    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.logistic)
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.pie_chart_outline,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Logistic Report',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: LogisticStatistic(user: currentUser,title: 'Report',),
                      isLocked: isLocked,
                      refresh: reloadMerchant,
                    ),
                    if(currentUser.staff.staffPermissions.managers || currentUser.staff.staffPermissions.logistic)
                    ValueListenableBuilder(
                        valueListenable: _orderNotifier,
                        builder: (_, orders,__){
                          return
                            MenuItem(
                              gridHeight,
                              Icon(AntIcons.shopping_outline,
                                  size: MediaQuery.of(context).size.width * 0.1,
                                  color: PRIMARYCOLOR.withOpacity(0.8)),
                              'Current Deliveries',
                              border: PRIMARYCOLOR,
                              isBadged: true,
                              isMultiMenu: false,
                              openCount: orders.length,
                              content: MyDelivery(orders: orders,user: currentUser,),
                              isLocked: isLocked,
                              refresh: reloadMerchant,
                            );
                        }),
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
                      isLocked: isLocked,
                      refresh: reloadMerchant,
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
                      isLocked: isLocked,
                      refresh: reloadMerchant,
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
                      isLocked: isLocked,
                      refresh: reloadMerchant,
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
                      isLocked: isLocked,
                      refresh: reloadMerchant,
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
                      isLocked: isLocked,
                      refresh: reloadMerchant,
                    ),

                    MenuItem(
                      gridHeight,
                      Icon(Icons.help_outline,
                          size: MediaQuery.of(context).size.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Help',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: HelpWebView(page: 'staff',),
                      isLocked: isLocked,
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
