import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pocketshopping/page/admin/TopUp.dart';
import 'package:pocketshopping/page/admin/menuItem.dart';
import 'package:pocketshopping/page/admin/message.dart';
import 'package:pocketshopping/page/admin/openOrder.dart';
import 'package:pocketshopping/page/admin/settings.dart';
import 'package:pocketshopping/page/admin/viewItem.dart';
import 'package:pocketshopping/page/user/merchant.dart';
import 'package:pocketshopping/util/data.dart';
import 'package:pocketshopping/component/psProvider.dart';
import 'package:pocketshopping/widget/product.dart';
import 'package:pocketshopping/widget/staffs.dart';
import 'package:pocketshopping/widget/unit.dart';
import 'package:pocketshopping/widget/customers.dart';
import 'package:pocketshopping/widget/branch.dart';
import 'package:pocketshopping/widget/manageOrder.dart';
import 'package:pocketshopping/widget/account.dart';
import 'package:pocketshopping/widget/statistic.dart';
import 'package:pocketshopping/widget/reviews.dart';
import 'package:pocketshopping/widget/status.dart';
import 'package:pocketshopping/component/scanScreen.dart';
import 'package:pocketshopping/constants/appColor.dart';

class DashBoardPage extends StatefulWidget {
  static String tag = 'DashBoard-page';
  DashBoardPage();


  @override
  _DashBoardPageState createState() => new _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {



  final GlobalKey<ScaffoldState> scaffoldKey=GlobalKey<ScaffoldState>();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double marginLR =  MediaQuery.of(context).size.width;
    double  gridHeight = MediaQuery.of(context).size.height*0.1;


    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.1), // here the desired height
        child: AppBar(
          leading: IconButton(

            icon: Icon(Icons.menu,color:PRIMARYCOLOR,
              size: marginLR*0.08,),
            onPressed: (){
              Scaffold.of(context).openDrawer();
            },
          ),
          actions: <Widget>[
            IconButton(

              icon: Icon(Icons.notification_important,color:PRIMARYCOLOR,
                size: marginLR*0.08,),
              onPressed: (){
                Scaffold.of(context).openDrawer();
              },
            ),
          ],
          centerTitle: true,
          elevation:0.0,
          backgroundColor: Colors.white,
          title:Text(psProvider.of(context).value['user']['businessName']??"buiness",style: TextStyle(color: PRIMARYCOLOR),),

          automaticallyImplyLeading: false,
        ),
      ),
        body: Container(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(height: MediaQuery.of(context).size.height*0.02,),
                        Container(
                            color: Colors.white,
                            //margin:  MediaQuery.of(context).size.height*0.05,
                          margin: EdgeInsets.only(left: marginLR*0.01,right: marginLR*0.01),
                          child: Column(
                            children: <Widget>[
                               Row(

                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Expanded(
                                      child:  Center(child:Text("PocketUnit: 12345678.90",
                                      style: TextStyle(fontSize:20, fontWeight: FontWeight.bold),)),
                                    ),
                                    Expanded(
                                      flex: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20.0),
                                          border: Border.all(color: PRIMARYCOLOR.withOpacity(0.5)),
                                          color: PRIMARYCOLOR.withOpacity(0.6),
                                        ),
                                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.01),
                                      //width: MediaQuery.of(context).size.width*0.2,
                                      child:FlatButton(
                                        onPressed: () => {

                                        Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                        builder: (context) =>TopUp()    ))

                                      },
                                        child:  Center(child:Text("TopUp",style: TextStyle(color: Colors.white),)),
                                      ),
                                    )
                                    ),
                                  ],
                                ),

                            ],
                          ),


                        ),
                        Container(height: MediaQuery.of(context).size.height*0.02,),
                      ],
                    )
                ),
                SliverGrid.count(
                    crossAxisCount: 3,
                    children: [
                      ViewItem(
                        gridHeight,
                        Header: '0',
                        actionText: 'click to extend screen',
                        subHeader: 'Open Order(s)',
                        skey:scaffoldKey,
                        bgColor: PRIMARYCOLOR.withOpacity(0.8),
                        content: ScanScreen(PRIMARYCOLOR.withOpacity(0.8)),

                      ),

                      ViewItem(
                        gridHeight,
                        Header: 'Open',
                        subHeader: 'Store Status',
                        actionText: 'click to Change',
                        skey:scaffoldKey,
                        bgColor: PRIMARYCOLOR.withOpacity(0.8),
                        content: StatusBottomPage(themeColor: PRIMARYCOLOR.withOpacity(0.8)),
                      ),

                    ]
                ),
    SliverList(
    delegate: SliverChildListDelegate(
    [Container(height: MediaQuery.of(context).size.height*0.02,),])),
                SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(width: 0.5, color: PRIMARYCOLOR.withOpacity(0.5)),
                              ),
                              color: Colors.white),
                          padding: EdgeInsets.only(left: marginLR*0.04),
                          child:  Text("Menu",style: TextStyle(fontSize: 17,),),


                        ),
                      ],
                    )
                ),


                SliverGrid.count(
                  crossAxisCount: 3,
                  children: [
                    MenuItem(gridHeight,Icon(
                      Icons.folder_open,
                      size: MediaQuery.of(context).size.width*0.16,color: PRIMARYCOLOR.withOpacity(0.8),)
                        ,'Open Orders',border:PRIMARYCOLOR, isBadged: true,
                      openCount: 3,
                      isMultiMenu: false,
                      content: Orders(),
                    ),

                    MenuItem(gridHeight,Icon(
                      Icons.folder,
                      size: MediaQuery.of(context).size.width*0.16,color: PRIMARYCOLOR.withOpacity(0.8),)
                        ,'Manage Orders',
                      border:PRIMARYCOLOR,
                      content: ManageOrder(themeColor: PRIMARYCOLOR,),
                      isMultiMenu: false,),

                    MenuItem(gridHeight,Icon(
                      Icons.person_pin,
                      size: MediaQuery.of(context).size.width*0.16,color: PRIMARYCOLOR.withOpacity(0.8),)
                        ,'Place Order For Customer',border:PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: MerchantWidget(),
                    ),

                    MenuItem(gridHeight,Icon(
                        Icons.message, size: MediaQuery.of(context).size.width*0.12,
                        color: PRIMARYCOLOR.withOpacity(0.8)),
                      'Customer Message',border:PRIMARYCOLOR,
                      isBadged: true,openCount: 3,
                      isMultiMenu: false,
                      content: Message(themeColor: PRIMARYCOLOR,),

                        ),

                    MenuItem(gridHeight,Icon(
                        Icons.fastfood, size: MediaQuery.of(context).size.width*0.12,
                        color: PRIMARYCOLOR.withOpacity(0.8)),
                        'Products',border:PRIMARYCOLOR, content: ProductBottomPage(themeColor: PRIMARYCOLOR,),),

                    MenuItem(gridHeight,Icon(
                        Icons.show_chart, size: MediaQuery.of(context).size.width*0.12,
                        color: PRIMARYCOLOR.withOpacity(0.8)),
                        'Statistic',border:PRIMARYCOLOR, content: StatisticBottomPage(themeColor: PRIMARYCOLOR,),),

                    MenuItem(gridHeight,Icon(
                        Icons.people, size: MediaQuery.of(context).size.width*0.12,
                        color: PRIMARYCOLOR.withOpacity(0.8)),
                        'Staffs',border:PRIMARYCOLOR, content: StaffBottomPage(themeColor: PRIMARYCOLOR,),),

                    MenuItem(gridHeight,Icon(
                        Icons.credit_card, size: MediaQuery.of(context).size.width*0.12,
                        color: PRIMARYCOLOR.withOpacity(0.8)),
                        'PocketUnit',border:PRIMARYCOLOR, content: UnitBottomPage(themeColor: PRIMARYCOLOR,),),

                    MenuItem(gridHeight,Icon(
                        Icons.thumb_up, size: MediaQuery.of(context).size.width*0.12,
                        color: PRIMARYCOLOR.withOpacity(0.8)),
                        'Reviews',border:PRIMARYCOLOR, isBadged: true,
                        badgeType:'icon',
                      isMultiMenu: false,
                      openCount: 3,
                      content: Reviews(themeColor: PRIMARYCOLOR),),

                    MenuItem(gridHeight,Icon(
                        Icons.people_outline, size: MediaQuery.of(context).size.width*0.12,
                        color: PRIMARYCOLOR.withOpacity(0.8)),
                        'Customers',border:PRIMARYCOLOR,
                      isMultiMenu: false,
                      content: Customer(themeColor: PRIMARYCOLOR,),),

                    MenuItem(gridHeight,Icon(
                        Icons.settings, size: MediaQuery.of(context).size.width*0.12,
                        color: PRIMARYCOLOR.withOpacity(0.8)),
                        'Settings',
                      border:PRIMARYCOLOR,
                      isMultiMenu: false,
                    content: Settings(),),



                    if(true)
                    MenuItem(gridHeight,Icon(
                        Icons.business, size: MediaQuery.of(context).size.width*0.12,
                        color: PRIMARYCOLOR.withOpacity(0.8)),
                        'Branch',border:PRIMARYCOLOR, content: BranchBottomPage(themeColor: PRIMARYCOLOR,),),

                    MenuItem(gridHeight,Icon(
                        Icons.account_box, size: MediaQuery.of(context).size.width*0.12,
                        color: PRIMARYCOLOR.withOpacity(0.8)),
                        'Account',border:PRIMARYCOLOR,
                      content: AccountPage(themeColor: PRIMARYCOLOR,),
                        isMultiMenu: false,),





                  ],
                ),
                SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height*0.1,


                        ),
                      ],
                    )
                ),
              ],
            )
        )
    );
  }
}
