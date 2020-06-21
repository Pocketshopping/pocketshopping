import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/component/scanScreen.dart';
import 'package:pocketshopping/page/admin/settings.dart';
import 'package:pocketshopping/page/admin/viewItem.dart';
import 'package:pocketshopping/src/admin/bottomScreen/logisticComponent/AgentBS.dart';
import 'package:pocketshopping/src/admin/bottomScreen/logisticComponent/logisticReport.dart';
import 'package:pocketshopping/src/admin/bottomScreen/logisticComponent/statisticBS.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/business/mangeBusiness.dart';
import 'package:pocketshopping/src/channels/repository/channelRepo.dart';
import 'package:pocketshopping/src/logistic/agentCompany/agentList.dart';
import 'package:pocketshopping/src/logistic/agentCompany/automobileList.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/order/bloc/orderBloc.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/agent/myDeliveries.dart';
import 'package:pocketshopping/src/user/agent/requestPocketSense.dart';
import 'package:pocketshopping/src/user/agentBusiness.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:pocketshopping/widget/account.dart';
import 'package:pocketshopping/widget/reviews.dart';
import 'package:pocketshopping/widget/status.dart';
import 'package:pocketshopping/src/customerCare/customerCare.dart';

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
  final _orderNotifier = ValueNotifier<List<Order>>([]);
  StreamSubscription orders;

  @override
  void initState() {
    currentUser = BlocProvider.of<UserBloc>(context).state.props[0];
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      showBottom();
    });

    _isOperationalNotifier.value=currentUser.merchant.bStatus==1?true:false;

    WalletRepo.getWallet(currentUser.user.walletId)
        .then((value) => WalletBloc.instance.newWallet(value));
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
    orders?.cancel();
    super.dispose();
  }

  void reloadMerchant(){
    BlocProvider.of<UserBloc>(context).add(LoadUser(currentUser.user.uid));
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
                              onTap: (){
                                Get.to(AgentList(user: currentUser,)).then((value) => null);
                              },
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
                        print(Utility.isOperational(currentUser.merchant.bOpen, currentUser.merchant.bClose));
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
                            child: Utility.isOperational(currentUser.merchant.bOpen, currentUser.merchant.bClose)?
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('We are currently '
                                    '${available?'Available':'Unavailable'}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),),
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
                                    child: const Text('Change'),
                                  ),
                                  color: Colors.white.withOpacity(0.5),
                                )
                              ],
                            ):Center(
                              child: Text('Business is Closed for today',style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),
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
                    ValueListenableBuilder(
                        valueListenable: _orderNotifier,
                        builder: (_, orders,__){
                          return
                            MenuItem(
                              gridHeight,
                              Icon(MaterialIcons.local_pizza,
                                  size: MediaQuery.of(context).size.width * 0.12,
                                  color: PRIMARYCOLOR.withOpacity(0.8)),
                              'Deliveries',
                              border: PRIMARYCOLOR,
                              isBadged: true,
                              isMultiMenu: false,
                              openCount: orders.length,
                              content: MyDelivery(orders: orders,user: currentUser,),
                            );
                        }),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.check,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Clearance',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: AgentList(user: currentUser,callBckActionType: 2,title: 'Agent Clearance',),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.pie_chart,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Report',
                      border: PRIMARYCOLOR,
                      content: LogisticReportBottomPage(session: currentUser,),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.local_taxi,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My AutoMobile(s)',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: AutomobileList(user: currentUser,title: 'My Automobile',callBckActionType: 1,),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.motorcycle,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My Agent(s)',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: AgentList(user: currentUser,title: 'Manage Agent(s)',callBckActionType: 3,route: 1,),
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
                      content: SetupBusiness(isAgent: true,agent: User(currentUser.merchant.mID,email: currentUser.user.email),),
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
                      content: AgentBusiness(user: currentUser,),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(MaterialIcons.sentiment_satisfied,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'PocketSense',
                      border: PRIMARYCOLOR,
                      isBadged: false,
                      isMultiMenu: false,
                      openCount: 3,
                      content: RequestPocketSense(user: currentUser,),
                    ),MenuItem(
                      gridHeight,
                      Icon(Icons.add_call,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Customer Care',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: CustomerCare(session: currentUser,),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(Icons.settings,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Settings',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: ManageBusiness(session: currentUser,),
                      refresh: reloadMerchant,
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
