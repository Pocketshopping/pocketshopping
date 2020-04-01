import 'package:flutter/material.dart';
import 'package:pocketshopping/page/admin/PocketPurchaseHistory.dart';
import 'package:pocketshopping/page/admin/TopUp.dart';
import 'package:pocketshopping/page/admin/itemLister.dart';
import 'package:pocketshopping/page/admin/unitUsage.dart';
import 'package:pocketshopping/widget/bottomSheetMenuItem.dart';


class UnitBottomPage extends StatelessWidget{

  UnitBottomPage({this.themeColor=Colors.black54});
  final Color themeColor;

  @override
  Widget build(BuildContext context) {

    Widget PurchaseHistory({int index}){

      return Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Text("DateOfPurchase",style: TextStyle(fontSize: 18),),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text("123456 PocketUnit"),
                      ),
                      Expanded(
                        child: Text("123456 PocketUnit"),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }



    double marginLR =  MediaQuery.of(context).size.width;
    double  gridHeight = MediaQuery.of(context).size.height*0.1;
    return Container(
      height: MediaQuery.of(context).size.height*0.4,
      width:marginLR ,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverList(
              delegate: SliverChildListDelegate(
                  [Container(height: MediaQuery.of(context).size.height*0.02,),])),
          SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    padding: EdgeInsets.only(left: marginLR*0.04),
                    child:  Column(
                      children: <Widget>[
                        Text("PocketUnit",style: TextStyle(fontSize: 17,),),
                        Text("choose action",style: TextStyle(fontSize: 14,),),
                      ],
                    ),


                  ),
                ],
              )
          ),

          SliverGrid.count(
              crossAxisCount: 3,
              children: [
                BsMenuItem(
                    height:gridHeight,
                    icon:Icon(Icons.add, size: MediaQuery.of(context).size.width*0.16,color: themeColor.withOpacity(0.8),),
                    title:'TopUp',
                  page: TopUp(),
                ),
                
                BsMenuItem(
                    height:gridHeight,
                    icon:Icon(Icons.history, size: MediaQuery.of(context).size.width*0.16,color: themeColor.withOpacity(0.8),),
                    title:'Purchase Histroy',
                  page: PocketPurchaseHistory()

                ),

                BsMenuItem(
                    height:gridHeight,
                    icon:Icon(Icons.insert_chart, size: MediaQuery.of(context).size.width*0.16,color: themeColor.withOpacity(0.8),),
                    title:'Usage',
                  page: UnitUsage(),
                ),

              ]),
        ],
      ),
    );

  }
}