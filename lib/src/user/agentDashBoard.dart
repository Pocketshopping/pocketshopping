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
import 'package:pocketshopping/src/user/agent/requestPocketSense.dart';
import 'package:pocketshopping/src/user/agentBusiness.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:pocketshopping/widget/reviews.dart';
import 'package:workmanager/workmanager.dart';

class AgentDashBoardScreen extends StatefulWidget {
  static String tag = 'Agent Dashboard';
  @override
  _AgentDashBoardScreenState createState() => new _AgentDashBoardScreenState();
}

class _AgentDashBoardScreenState extends State<AgentDashBoardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Session currentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  Stream<LocalNotification> _notificationsStream;
  StreamSubscription iosSubscription;
  StreamSubscription orders;
  Stream<Wallet> _walletStream;

  final _isAvailableNotifier = ValueNotifier<bool>(true);
  final _walletNotifier = ValueNotifier<Wallet>(null);
  final _OrderNotifier = ValueNotifier<List<Order>>([]);


  @override
  void initState() {
    currentUser = BlocProvider.of<UserBloc>(context).state.props[0];
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      showBottom();
    });

    WalletRepo.getWallet(currentUser.user.walletId).
    then((value) => WalletBloc.instance.newWallet(value));
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {

        _walletNotifier.value = wallet;

    });

    orders = OrderRepo.agentOrder(currentUser.agent.agent).listen((event) {
      if(mounted)
        {
          _OrderNotifier.value=[];
          _OrderNotifier.value=event;
        }
      OrderBloc.instance.newOrder(event);
    });
    backgroundWorker();
    if(currentUser.agent == null)
    ChannelRepo.update(currentUser.merchant.mID, currentUser.user.uid);
    Utility.locationAccess();
    LogisticRepo.getOneAgentLocation(currentUser.agent.agentID).then((value){if(value != null) _isAvailableNotifier.value =value.availability;});
    super.initState();
  }

  Future<void> backgroundWorker(){
    Workmanager.cancelAll();
    Workmanager.registerPeriodicTask(
        "AGENTLOCATIONUPDATE", "LocationUpdateTask",
        frequency: Duration(minutes: 15),
        inputData: {
          'agentID': currentUser.agent.agentID,
          'agentAutomobile': currentUser.agent.autoType,
          'availability': true,
          'agentTelephone': currentUser.user.telephone,
          'agentName': currentUser.user.fname,
          'wallet':currentUser.user.walletId,
          'agentParent':currentUser.agent.agentWorkPlace
        });


  }

  showBottom() {
   // GetBar(title: 'tdsd',messageText: Text('sdsd'),duration: Duration(seconds: 2),).show();
  }

  @override
  void dispose() {
    _OrderNotifier.dispose();
    _walletNotifier.dispose();
    _notificationsStream = null;
    _walletStream = null;
    orders.cancel();
    iosSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double marginLR = MediaQuery.of(context).size.width;
    double gridHeight = MediaQuery.of(context).size.height * 0.1;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.1), // here the desired height
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
              style: const TextStyle(color: PRIMARYCOLOR),
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
                        'Agent',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 20,)
                  ],
                )),
                SliverList(
                    delegate: SliverChildListDelegate(
                      [

                        Container(
                            color: Colors.white,
                            //margin:  MediaQuery.of(context).size.height*0.05,
                            margin: EdgeInsets.only(
                                left: marginLR * 0.01, right: marginLR * 0.01),
                            child: ValueListenableBuilder(
                              valueListenable: _walletNotifier,
                              builder: (_,Wallet wallet,__){
                                if(wallet != null)
                                  return Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          const Expanded(
                                            flex: 0,
                                            child: const SizedBox(
                                              width: 10,
                                            ),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Column(
                                                children: [
                                                  Center(
                                                      child: const Text(
                                                        "PocketUnit",
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight.bold),
                                                      )
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Center(
                                                      child: Text(
                                                        "${wallet.pocketUnitBalance}",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold),
                                                      )),
                                                  const SizedBox(
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
                                                        Get.dialog(TopUp(user: currentUser.user,payType: "TOPUPUNIT",));

                                                      },
                                                      child: const Center(
                                                          child: const Text(
                                                            "TopUp",
                                                            style: const TextStyle(
                                                                color: Colors.white),
                                                          )),
                                                    ),
                                                  )
                                                ],
                                              )
                                          ),
                                          if (wallet.pocketUnitBalance<100)
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                                  child: Text('${'Your PocketUnit is below the expected quota, this means you will be unavaliable for delivery until you Topup'}'),
                                                ),
                                              )

                                        ],
                                      ),

                                    ],
                                  );
                                else
                                  return const SizedBox.shrink();
                              } ,
                            )


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
                          const Text('Deliveries Today',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),),
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
                         const Text('Km Covered Today',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),),
                        ],
                      ),
                    ),
                  ),
                  ValueListenableBuilder(
                     valueListenable: _isAvailableNotifier,
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
                               Text('I am currently '
                                   '${available?'Available':'Unavailable'}',
                                 textAlign: TextAlign.center,
                                 style: TextStyle(color: Colors.white),),
                               FlatButton(
                                 onPressed: ()async{
                                   bool change =!available;
                                   bool result = await LocRepo.updateAvailability(currentUser.agent.agentID, change);
                                   if(!(change == result))
                                     GetBar(title: 'Error changing your status please try again');
                                   else
                                     _isAvailableNotifier.value = result;
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
                      child: const Text(
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
                      valueListenable: _OrderNotifier,
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
                      Icon(MaterialIcons.local_taxi,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'My AutoMobile',
                      isBadged: false,
                      isMultiMenu: false,
                      border: PRIMARYCOLOR,
                      content: MyAuto(agent: currentUser,),
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
                    ),
                  ],
                ),
                SliverList(
                    delegate: SliverChildListDelegate(
                  [
                    const SizedBox(height: 20,),
                  ],
                )),
              ],
            )));
  }
}
