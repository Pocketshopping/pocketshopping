import 'dart:async';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:ant_icons/ant_icons.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/bottomScreen/unit.dart';
import 'package:pocketshopping/src/admin/finance.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/admin/product/manage.dart';
import 'package:pocketshopping/src/admin/staff/managerTransaction.dart';
import 'package:pocketshopping/src/admin/staff/staffList.dart';
import 'package:pocketshopping/src/bank/BankWithdraw.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/business/mangeBusiness.dart';
import 'package:pocketshopping/src/channels/repository/channelRepo.dart';
import 'package:pocketshopping/src/customerCare/customerCare.dart';
import 'package:pocketshopping/src/logistic/agentCompany/agentList.dart';
import 'package:pocketshopping/src/logistic/agentCompany/automobileList.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/order/bloc/orderBloc.dart';
import 'package:pocketshopping/src/order/logisticBucket.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/payment/topUpPocket.dart';
import 'package:pocketshopping/src/payment/topup.dart';
import 'package:pocketshopping/src/payment/totpupScaffold.dart';
import 'package:pocketshopping/src/pin/repository/pinRepo.dart';
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
import 'package:pocketshopping/src/withdrawal/withdrawalWidget.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';




class DashBoardScreen extends StatefulWidget {
  static String tag = 'DashBoard-page';

  DashBoardScreen();

  @override
  _DashBoardScreenState createState() => new _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final GlobalKey _one = GlobalKey();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Session currentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  Stream<LocalNotification> _notificationsStream;
  StreamSubscription iosSubscription;
  Stream<Wallet> _walletStream;
  //Wallet _wallet;
  final _walletNotifier = ValueNotifier<Wallet>(null);
  final _isOperationalNotifier = ValueNotifier<bool>(true);
  final _orderNotifier = ValueNotifier<List<Order>>([]);
  StreamSubscription orders;
  final report = ValueNotifier<Map<String,dynamic>>({});
  final _agentNotifier = ValueNotifier<int>(0);
  final _bucketCount = ValueNotifier<int>(0);
  final _stockManager = ValueNotifier<List<Stock>>([]);
  StreamSubscription bucket;


  @override
  void initState() {
    currentUser = BlocProvider.of<UserBloc>(context).state.props[0];
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      showBottom();
    });

    WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if (mounted) {
        _walletNotifier.value = wallet;
      }
    });

    StockRepo.getOneStream(currentUser.merchant.mID).listen((event) {

      try{
        _stockManager.value = event;
      }
      catch(_){}
    });


    ChannelRepo.update(currentUser.merchant.mID, currentUser.user.uid);
    _isOperationalNotifier.value=currentUser.merchant.bStatus==1?true:false;
    orders = OrderRepo.agentOrder(currentUser.merchant.mID,whose: 'orderLogistic').listen((event) {
      try{
        if(mounted)
        {
          _orderNotifier.value=[];
          _orderNotifier.value=event;
        }
        OrderBloc.instance.newOrder(event);
      }
      catch(_){}
    });
    LogisticRepo.fetchMyAvailableAgents(currentUser.merchant.mID).listen((event) {_agentNotifier.value = event;});
    StatisticRepo.getTodayStat(currentUser.merchant.mID,'').then((value) {
      try{
        if(mounted)setState(() {report.value = value;});
      }
      catch(_){}
    });

    /*WidgetsBinding.instance.addPostFrameCallback((_) =>
        ShowCaseWidget.of(context).startShowCase([_one,]));*/

    bucket = OrderRepo.logisticBucketCount(currentUser.merchant.mID).listen((event) {
      if(mounted)
      {
        _bucketCount.value=event;
      }

    });

    setMerchant().then((value) {
      AndroidAlarmManager.initialize();
      requestListenerWorker();
    });

    super.initState();
  }

  showBottom() {
    //GetBar(title: 'tdsd',messageText: Text('sdsd'),duration: Duration(seconds: 2),).show();
  }

  Future<bool> setMerchant() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('merchant', currentUser.merchant.mID??"");
    return true;
  }

  static Future<void> backgroundWorker()async{
    //await Workmanager.cancelAll();
    await Workmanager.registerPeriodicTask(
        "AGENTLOCATIONUPDATE", "LocationUpdateTask",
        constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        frequency: Duration(minutes: 15),
        tag: 'LocationUpdateTag',
        inputData: {});

  }

  Future<void> requestListenerWorker()async{
    await AndroidAlarmManager.cancel(requestWorkerID);
    await AndroidAlarmManager.periodic(const Duration(minutes: 2), requestWorkerID, backgroundWorker, rescheduleOnReboot: true, exact: true,);
  }

  @override
  void dispose() {
    _walletNotifier.dispose();
    orders?.cancel();
    iosSubscription?.cancel();
    bucket?.cancel();
    super.dispose();
  }

  void reloadMerchant({bool complete=false}){
    WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
    LogisticRepo.fetchMyAvailableAgents(currentUser.merchant.mID).listen((event) {_agentNotifier.value = event;});
    StatisticRepo.getTodayStat(currentUser.merchant.mID,'').then((value) {if (mounted)setState(() {report.value = value;});});
    if(complete)
    BlocProvider.of<UserBloc>(context).add(LoadUser(currentUser.user.uid));
  }



  @override
  Widget build(BuildContext context) {
    double marginLR = Get.width;
    double gridHeight = Get.height * 0.1;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(Get.height *
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
              Help(page: 'business',),
            ],

              /*Builder(
                builder: (context){
                  return Showcase(
                    key: _one,
                    title: 'How to use pocketshopping',
                    description: 'Click outside to exit',
                    titleTextStyle: TextStyle(fontWeight: FontWeight.normal),
                    descTextStyle: TextStyle(fontWeight: FontWeight.normal),
                    child: IconButton(
                      onPressed: (){
                        //ShowCaseWidget.of(context).startShowCase([_one,]);
                      },
                      color: PRIMARYCOLOR,
                      icon: Icon(Icons.help_outline),
                    ),
                  );
                },
              )*/



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
                      height: Get.height * 0.02,
                    ),
                    Container(
                      color: Colors.white,
                      //margin:  Get.height*0.05,
                      margin: EdgeInsets.only(
                          left: marginLR * 0.01, right: marginLR * 0.01),
                      child: AdminFinance(
                        topUp: (){

                          Get.dialog(
                              TopUpScaffold(
                                user: currentUser.user,
                                wallet: _walletNotifier.value,
                                atm: (){
                                  Get.dialog(TopUp(user: currentUser.user,payType: "TOPUPUNIT",))
                                      .then((value) {
                                    Get.back();});
                                },
                                personal: (){
                                  Get.dialog(TopUpPocket(
                                    user: currentUser.user,
                                    topUp: currentUser.user.walletId,
                                    wallet: _walletNotifier.value,
                                    isPersonal: 3,
                                  )).then((value) {
                                    Get.back();});
                                },
                                business: (){
                                  Get.dialog(TopUpPocket(
                                    user: currentUser.user,
                                    topUp: currentUser.user.walletId,
                                    wallet: _walletNotifier.value,
                                    isPersonal: 1,
                                  )).then((value) {
                                    Get.back();});
                                },
                                delivery: (){
                                  Get.dialog(TopUpPocket(
                                    user: currentUser.user,
                                    topUp: currentUser.user.walletId,
                                    wallet: _walletNotifier.value,
                                    isPersonal: 2,
                                  )).then((value) {
                                    Get.back();});
                                },
                              )
                          ).then((value) {
                            WalletRepo.getWallet(currentUser.merchant.bWallet).then((value) {
                              if (mounted) {
                                _walletNotifier.value = value;
                                setState(() {});
                              }
                            });
                          });
                        
                        },
                        withdraw: (Wallet wallet)async{
                          double total = wallet.merchantBalance + wallet.deliveryBalance;
                          bool canWithdraw = wallet.accountNumber.isNotEmpty;
                          Utility.dialogLoader();
                          bool isSet = await PinRepo.isSet(currentUser.user.walletId);
                          Get.back();
                          if(total > 10){
                            if(currentUser.user.role == 'admin'){
                              if(currentUser.user.uid == currentUser.merchant.bCreator.id){
                                if(isSet){
                                  if(canWithdraw){

                                    Get.dialog(BankWithdraw(wallet: wallet,walletID: currentUser.user.walletId,callBackAction: (){},)).then((value){
                                      WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
                                    });

                                  }
                                  else{
                                    Utility.infoDialogMaker('You can not withdraw without adding your account number.'
                                        ' click on settings on the side menu for adding up bank account',title: 'Withdraw');
                                  }
                                }
                                else{
                                  Utility.infoDialogMaker('You can not withdraw without setting up Pocket PIN.'
                                      ' click on settings on the side menu for setting up Pocket PIN',title: 'Withdraw');
                                }

                              }
                              else{
                                Utility.infoDialogMaker('You are not the owner of this business',title: 'Withdraw');
                              }
                            }
                            else{
                              Utility.infoDialogMaker('You do not have permission to withdraw from this account,',title: 'Withdraw');
                            }
                          }
                          else{
                            Utility.infoDialogMaker('Insufficient Funds for withdrawal',title: 'Withdraw');
                          }

                        },
                      ),
                    ),
                     SizedBox(
                      height: Get.height * 0.02,
                    ),
                  ],
                )),
                SliverGrid.count(crossAxisCount: 3, children: [
                  ValueListenableBuilder(
                    valueListenable: report,
                    builder: (_,Map<String,dynamic> _report,__){
                      return _report != null ?GestureDetector(
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
                      ): const SizedBox.shrink();
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: report,
                    builder: (_,Map<String,dynamic> _report,__){
                      return _report != null ?GestureDetector(
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
                      ): const SizedBox.shrink();
                    },
                  ),
                  ValueListenableBuilder(
                      valueListenable: report,
                      builder: (_,Map<String,dynamic> _report,__){
                        return
                  ValueListenableBuilder(
                      valueListenable: _isOperationalNotifier,
                      builder: (_,available,__){
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
                            child: _report != null
                              ?
                            Utility.isOperational(currentUser.merchant.bOpen, currentUser.merchant.bClose)?
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('${currentUser.merchant.bCategory} is '
                                    '${available?'open':'closed'}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: PRIMARYCOLOR),),
                                FlatButton(
                                  onPressed: ()async{
                                    bool change =!available;
                                    bool result = await  MerchantRepo.update(currentUser.merchant.mID,{'businessStatus':change?1:0});

                                    if(!result)
                                      GetBar(title: 'Error changing your status please try again');
                                    else {
                                      _isOperationalNotifier.value = change;
                                      BlocProvider.of<UserBloc>(context).add(LoadUser(currentUser.user.uid));
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                                    child: const Text('Change',style: TextStyle(color: Colors.white),),
                                  ),
                                  color: PRIMARYCOLOR.withOpacity(0.8),
                                )
                              ],
                            ):Center(
                              child: Text('${currentUser.merchant.bCategory} is Closed for today',style: TextStyle(color: PRIMARYCOLOR),textAlign: TextAlign.center,),
                            ):Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      });
                      }),
                  FutureBuilder(
                    future: Utility.logisticTodayAmount(currentUser.user.walletId),
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
                    height: Get.height * 0.02,
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
                      child: const Text(
                        "Menu",
                        style: const TextStyle(
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
                          AntIcons.shop_outline,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8),
                        ),
                        'Transactions',
                        border: PRIMARYCOLOR,
                        content: Transactions(user: currentUser,title: 'Transactions',),
                        isMultiMenu: false,
                      refresh: reloadMerchant,
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(
                        AntIcons.printer_outline,
                        size: Get.width * 0.1,
                        color: PRIMARYCOLOR.withOpacity(0.8),
                      ),
                      'Point of Sale',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: ProductList(user: currentUser,callBckActionType: 3,route: 1,),
                      refresh: reloadMerchant,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _stockManager,
                      builder: (_,List<Stock>snapshot,__){
                            if(snapshot.isNotEmpty){StockBloc.instance.stocks(snapshot);}
                            return MenuItem(
                              gridHeight,
                              Icon(Icons.calendar_today,
                                  size: Get.width * 0.1,
                                  color: PRIMARYCOLOR.withOpacity(0.8)),
                              'Stock Manager',
                              border: PRIMARYCOLOR,
                              isBadged: true,
                              isMultiMenu: false,
                              openCount: snapshot.isNotEmpty?snapshot.length:0,
                              content: StockManager(user: currentUser,),
                              refresh: reloadMerchant,
                            );
                      },
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.shopping_outline,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Products',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: ManageProduct(user: currentUser,),
                      refresh: reloadMerchant,
                    ),
                    MenuItem(
                        gridHeight,
                        Icon(AntIcons.pie_chart_outline,
                            size: Get.width * 0.1,
                            color: PRIMARYCOLOR.withOpacity(0.8)),
                        'Report',
                        border: PRIMARYCOLOR,

                        content: MerchantStatistic(user: currentUser,title: 'Report',),
                        isMultiMenu: false,
                      refresh: reloadMerchant,
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.user,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Staffs',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: StaffList(user: currentUser,title: 'Manage Staff(s)',callBckActionType: 3,route: 1,),
                      refresh: reloadMerchant,
                    ),
                    MenuItem(
                        gridHeight,
                        Icon(AntIcons.deployment_unit,
                            size: Get.width * 0.1,
                            color: PRIMARYCOLOR.withOpacity(0.8)),
                        'PocketUnit',
                        border: PRIMARYCOLOR,
                        content: UnitBottomPage(user: currentUser,wallet: currentUser.merchant.bWallet,
                        sender:User(currentUser.merchant.mID,role: 'admin',
                            walletId: currentUser.merchant.bWallet,email: currentUser.user.email,fname: currentUser.merchant.bName),
                        ),

                    ),
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.history,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Withdrawal(s)',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: WithdrawalWidget(user: currentUser,),
                      refresh: reloadMerchant,
                    ),
                    /*MenuItem(
                      gridHeight,
                      Icon(Icons.thumb_up,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Reviews',
                      border: PRIMARYCOLOR,
                      isBadged: true,
                      badgeType: 'icon',
                      isMultiMenu: false,
                      openCount: 3,
                      content: Reviews(themeColor: PRIMARYCOLOR),
                    ),*/
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.setting_outline,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Settings',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: ManageBusiness(session: currentUser,),
                      refresh: reloadMerchant,
                    ),
                    /*MenuItem(
                      gridHeight,
                      Icon(AntIcons.home_outline,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Branch',
                      border: PRIMARYCOLOR,
                      content: Text('hello'),
                    ),*/
                      ValueListenableBuilder(
                          valueListenable: _bucketCount,
                          builder: (_, count,__){
                            return
                              MenuItem(
                                gridHeight,
                                Icon(AntIcons.bell_outline,
                                    size: Get.width * 0.1,
                                    color: PRIMARYCOLOR.withOpacity(0.8)),
                                'Request',
                                border: PRIMARYCOLOR,
                                isBadged: true,
                                isMultiMenu: false,
                                openCount: count,
                                content: LogisticBucket(user: currentUser,),
                                refresh: reloadMerchant,
                              );
                          }),
                    ValueListenableBuilder(
                        valueListenable: _orderNotifier,
                        builder: (_, orders,__){
                          return
                            MenuItem(
                              gridHeight,
                              Icon(AntIcons.shopping_outline,
                                  size: Get.width * 0.1,
                                  color: PRIMARYCOLOR.withOpacity(0.8)),
                              'Current Deliveries',
                              border: PRIMARYCOLOR,
                              isBadged: true,
                              isMultiMenu: false,
                              openCount: orders.length,
                              content: MyDelivery(orders: orders,user: currentUser,),
                              refresh: reloadMerchant,
                            );
                        }),
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.pie_chart_outline,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Logistic Report',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: LogisticStatistic(user: currentUser,title: 'Report',),
                      refresh: reloadMerchant,
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.check,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Rider Clearance',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: AgentList(user: currentUser,callBckActionType: 2,title: 'Agent Clearance',),
                      refresh: reloadMerchant,
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.car_outline,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My AutoMobile(s)',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: AutomobileList(user: currentUser,title: 'My Automobile',callBckActionType: 1,),
                      refresh: reloadMerchant,
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.user_add_outline,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My Rider(s)',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: AgentList(user: currentUser,title: 'Manage Rider(s)',callBckActionType: 3,route: 1,),
                      refresh: reloadMerchant,
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.pushpin_outline,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Rider Tracker',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: AgentList(user: currentUser,),
                      refresh: reloadMerchant,
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.smile_outline,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'PocketSense',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: RequestPocketSense(user: currentUser,),
                      refresh: reloadMerchant,
                    ),MenuItem(
                      gridHeight,
                      Icon(AntIcons.customer_service_outline,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Customer Care',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: CustomerCare(session: currentUser,),
                      refresh: reloadMerchant,
                    ),

                    MenuItem(
                      gridHeight,
                      Icon(Icons.help_outline,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Help',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: HelpWebView(page: 'business',),
                    ),
                  ],
                ),
                SliverList(
                    delegate: SliverChildListDelegate(
                  [
                    if(currentUser.merchant.bSocial.isNotEmpty)
                      if(currentUser.merchant.bSocial['url'] != null)
                        Column(
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Center(
                              child: Text('${currentUser.merchant.bName} Url'),
                            ),
                            Center(
                              child: Text('${currentUser.merchant.bSocial['url']}',style: TextStyle(color: PRIMARYCOLOR,fontWeight: FontWeight.bold),),
                            ),
                            Center(
                                child: FlatButton(
                                  onPressed: (){
                                    Share.share('${currentUser.merchant.bSocial['url']}');
                                  },
                                  color: PRIMARYCOLOR,
                                  child: Text('Share Url',style: TextStyle(color: Colors.white),),
                                )
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        )
                      else
                        const SizedBox(
                          height: 20,
                        ),
                  ],
                )),
              ],
            )));
  }

}
