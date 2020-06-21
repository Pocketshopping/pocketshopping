import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/page/admin/openOrder.dart';
import 'package:pocketshopping/page/admin/settings.dart';
import 'package:pocketshopping/page/user/merchant.dart';
import 'package:pocketshopping/src/admin/bottomScreen/logisticComponent/AgentBS.dart';
import 'package:pocketshopping/src/admin/bottomScreen/logisticComponent/logisticReport.dart';
import 'package:pocketshopping/src/admin/bottomScreen/logisticComponent/vehicleBS.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/admin/product/manage.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/business/mangeBusiness.dart';
import 'package:pocketshopping/src/channels/repository/channelRepo.dart';
import 'package:pocketshopping/src/customerCare/customerCare.dart';
import 'package:pocketshopping/src/logistic/agentCompany/agentList.dart';
import 'package:pocketshopping/src/logistic/agentCompany/automobileList.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/payment/topup.dart';
import 'package:pocketshopping/src/pos/productList.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/agent/requestPocketSense.dart';
import 'package:pocketshopping/src/user/agentBusiness.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:pocketshopping/widget/branch.dart';
import 'package:pocketshopping/widget/customers.dart';
import 'package:pocketshopping/widget/manageOrder.dart';
import 'package:pocketshopping/widget/staffs.dart';
import 'package:pocketshopping/widget/statistic.dart';
import 'package:pocketshopping/widget/unit.dart';
import 'package:workmanager/workmanager.dart';

class DashBoardScreen extends StatefulWidget {
  static String tag = 'DashBoard-page';

  DashBoardScreen();

  @override
  _DashBoardScreenState createState() => new _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Session currentUser;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  Stream<LocalNotification> _notificationsStream;
  StreamSubscription iosSubscription;
  Stream<Wallet> _walletStream;
  //Wallet _wallet;
  final _walletNotifier = ValueNotifier<Wallet>(null);

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
      if (mounted) {
        _walletNotifier.value = wallet;
      }
    });
    ChannelRepo.update(currentUser.merchant.mID, currentUser.user.uid);
    Workmanager.cancelAll();
    super.initState();
  }

  showBottom() {
    //GetBar(title: 'tdsd',messageText: Text('sdsd'),duration: Duration(seconds: 2),).show();
  }

  @override
  void dispose() {
    _walletNotifier.dispose();
    _notificationsStream = null;
    _walletStream = null;
    iosSubscription?.cancel();
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
                      child: ValueListenableBuilder(
                        valueListenable: _walletNotifier,
                        builder: (_,wallet,__){
                        if(wallet != null)
                          return Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[

                                  Expanded(
                                      flex: 1,
                                      child: Column(
                                        children: [
                                          Center(
                                              child: const Text(
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
                                                "\u20A6 ${wallet.merchantBalance}",
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
                                              onPressed: () => {

                                              },
                                              child: const Center(
                                                  child:  const Text(
                                                    "Withdraw",
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  )),
                                            ),
                                          )
                                        ],
                                      )),
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
                                              )),
                                          Center(
                                              child: Text(
                                                "1.00 unit = ${CURRENCY}1.00",
                                                style: TextStyle(
                                                    fontSize: 11),
                                              )),
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
                                      )),
                                ],
                              ),
                              const SizedBox(height: 20,),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Column(
                                        children: [
                                          const Center(
                                              child: const Text(
                                                "Delivery Revenue",
                                                style: const TextStyle(
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
                                                "\u20A6 ${wallet.deliveryBalance}",
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
                                              onPressed: () => {
                                              },
                                              child: const Center(
                                                  child: const Text(
                                                    "Withdraw",
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  )),
                                            ),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                            ],
                          );
                        else
                          return const SizedBox.shrink();
                        } ,
                      )


                    ),
                     SizedBox(
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
                          const Text('Open Order(s)',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),),
                          const Text('click to extend screen',
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
                          Text('Store is '
                              '${true?'Open':'Close'}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),),
                          FlatButton(
                            onPressed: ()async{
                              /*bool change =!available;
                              bool result = await LocRepo.updateAvailability(currentUser.agent.agentID, change);
                              if(!(change == result))
                                GetBar(title: 'Error changing your status please try again');
                              else
                                setState(() {available = result; });*/
                            },
                            child: const Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                              child: const Text('Change'),
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
                        Icons.attach_money,
                        size: MediaQuery.of(context).size.width * 0.16,
                        color: PRIMARYCOLOR.withOpacity(0.8),
                      ),
                      'Point of Sale',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: ProductList(user: currentUser,callBckActionType: 3,route: 1,),
                    ),
                    MenuItem(
                      gridHeight,
                      Icon(Icons.fastfood,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Products',
                      border: PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: ManageProduct(user: currentUser,),
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
                    /*MenuItem(
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
                    ),*/
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
                      content: ManageBusiness(session: currentUser,),
                      refresh: reloadMerchant,
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
                  ],
                ),
                SliverList(
                    delegate: SliverChildListDelegate(
                  [
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )),
              ],
            )));
  }

}
