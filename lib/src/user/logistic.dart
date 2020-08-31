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
import 'package:pocketshopping/src/statistic/logisticStat.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/ui/shared/bonusDrawer.dart';
import 'package:pocketshopping/src/ui/shared/help.dart';
import 'package:pocketshopping/src/user/agent/myDeliveries.dart';
import 'package:pocketshopping/src/user/agent/requestPocketSense.dart';
import 'package:pocketshopping/src/user/agentBusiness.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:pocketshopping/src/withdrawal/withdrawalWidget.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';


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
  StreamSubscription bucket;
  Stream<Wallet> _walletStream;
  Wallet _wallet;
  final _agentNotifier = ValueNotifier<int>(0);
  final _isOperationalNotifier = ValueNotifier<bool>(true);
  final _orderNotifier = ValueNotifier<List<Order>>([]);
  StreamSubscription orders;
  final _bucketCount = ValueNotifier<int>(0);


  @override
  void initState() {
    currentUser = BlocProvider.of<UserBloc>(context).state.props[0];
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      showBottom();
    });

    _isOperationalNotifier.value=currentUser.merchant.bStatus==1?true:false;
    WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if (mounted) {
        _wallet = wallet;
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


    LogisticRepo.fetchMyAvailableAgents(currentUser.merchant.mID).listen((event) {
      _agentNotifier.value = event;
    });

    ChannelRepo.update(currentUser.merchant.mID, currentUser.user.uid);
    //Utility.noWorker().then((value) => null);
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

    /*DynamicLinks.createLinkWithParams({
      'merchant': '${currentUser.merchant.mID}',
    }).then((value) {
      print(value);
    });*/

    //print(currentUser.merchant.bSocial['url']);


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
    await AndroidAlarmManager.periodic(const Duration(minutes: 3), requestWorkerID, backgroundWorker, rescheduleOnReboot: true, exact: true,);
  }

  @override
  void dispose() {
    _notificationsStream = null;
    _walletStream = null;
    iosSubscription?.cancel();
    orders?.cancel();
    bucket?.cancel();
    super.dispose();
  }

  void reloadMerchant({bool complete=false}){
    WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
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
              Help(page: 'logistic',),
            ],
          ),
        ),
        body: Container(
            color: Colors.white,
            child: CustomScrollView(
              slivers: <Widget>[
                /*SliverList(
                    delegate: SliverChildListDelegate(
                      [

                        Center(
                            child: SizedBox(
                                height: Get.height*0.3,
                                width: Get.width*0.6,
                                child: GestureDetector(onTap: ()async{
                                  *//*FlutterRingtonePlayer.playNotification();
                              await FlutterRingtonePlayer.play(
                                android: AndroidSounds.notification,
                                ios: IosSounds.glass,
                                looping: false, // Android only - API >= 28
                                volume: 0.1, // Android only - API >= 28
                                asAlarm: false, // Android only - all APIs
                              );
                              FlutterRingtonePlayer.stop();*//*
                                  Get.to(LogisticBucket(user: currentUser,),).then((value) => null);
                                },child: Card(
                                  child: ValueListenableBuilder(
                                    valueListenable: _bucketCount,
                                    builder: (_,count,__){
                                      return
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text('$count',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color:PRIMARYCOLOR,fontSize: 30),),
                                            const Text('Request Bucket',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: PRIMARYCOLOR),),
                                            const Text('click to view',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: PRIMARYCOLOR),),
                                          ],

                                        );
                                    },
                                  ),
                                )
                                )
                            )
                        ),
                        const SizedBox(height: 20,)
                      ],
                    )),*/
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
                      child: AdminFinance(topUp: (){

                        Get.dialog(
                            TopUpScaffold(
                              user: currentUser.user,
                              wallet: _wallet,
                              atm: (){
                                Get.dialog(TopUp(user: currentUser.user,payType: "TOPUPUNIT",))
                                    .then((value) {
                                  Get.back();});
                              },
                              personal: (){
                                Get.dialog(TopUpPocket(
                                  user: currentUser.user,
                                  topUp: currentUser.user.walletId,
                                  wallet: _wallet,
                                  isPersonal: 3,
                                )).then((value) {
                                  Get.back();});
                              },
                              business: (){
                                Get.dialog(TopUpPocket(
                                  user: currentUser.user,
                                  topUp: currentUser.user.walletId,
                                  wallet: _wallet,
                                  isPersonal: 1,
                                )).then((value) {
                                  Get.back();});
                              },
                              delivery: (){
                                Get.dialog(TopUpPocket(
                                  user: currentUser.user,
                                  topUp: currentUser.user.walletId,
                                  wallet: _wallet,
                                  isPersonal: 2,
                                )).then((value) {
                                  Get.back();});
                              },
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

                      withdraw: (Wallet wallet)async{
                        double total = wallet.merchantBalance + wallet.deliveryBalance;
                        bool canWithdraw = wallet.accountNumber.isNotEmpty;
                        bool isSet = await PinRepo.isSet(currentUser.user.walletId);
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
                                      ' click on settings on the side menu for adding up bank account',title: '');
                                }
                              }
                              else{
                                Utility.infoDialogMaker('You can not withdraw without setting up Pocket PIN.'
                                    ' click on settings on the side menu for setting up Pocket PIN',title: '');
                              }

                            }
                            else{
                              Utility.infoDialogMaker('You are not the owner of this business',title: '');
                            }
                          }
                          else{
                            Utility.infoDialogMaker('You do not have permission to withdraw from this account,',title: '');
                          }
                        }
                        else{
                          Utility.infoDialogMaker('Insufficient Funds for withdrawal',title: '');
                        }

                      },
                      ),
                    ),
                    Container(
                      height: Get.height * 0.02,
                    ),
                  ],
                )),
                SliverGrid.count(crossAxisCount: 3, children: [
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
                  ValueListenableBuilder(
                      valueListenable: _isOperationalNotifier,
                      builder: (_,available,__){
                        //print(Utility.isOperational(currentUser.merchant.bOpen, currentUser.merchant.bClose));
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
                            child: Utility.isOperational(currentUser.merchant.bOpen, currentUser.merchant.bClose)?
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('We are currently '
                                    '${available?'Available':'Unavailable'}',
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
                              child: Text('Business is Closed for today',style: TextStyle(color: PRIMARYCOLOR),textAlign: TextAlign.center,),
                            ),
                          ),
                        );
                      })
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
                      Icon(MaterialIcons.check,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Rider Clearance',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: AgentList(user: currentUser,callBckActionType: 2,title: 'Rider Clearance',),
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
                      Icon(AntIcons.bulb_outline,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'New Business',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: SetupBusiness(isAgent: true,agent: User(currentUser.merchant.mID,email: currentUser.user.email),),
                      refresh: reloadMerchant,
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(AntIcons.shop_outline,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My Business(es)',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: AgentBusiness(user: currentUser,),
                      refresh: reloadMerchant,
                    ),
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
                    ),
                    MenuItem(
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
                      Icon(AntIcons.setting_outline,
                          size: Get.width * 0.1,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Settings',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: ManageBusiness(session: currentUser,),
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
                      content: HelpWebView(page: 'logistic',),
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
