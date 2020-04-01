import 'package:flutter/material.dart';
import 'package:pocketshopping/page/admin/customerStats.dart';
import 'package:pocketshopping/page/admin/finStats.dart';
import 'package:pocketshopping/page/admin/orderStats.dart';
import 'package:pocketshopping/page/admin/productStats.dart';
import 'package:pocketshopping/page/admin/staffStats.dart';
import 'package:pocketshopping/widget/bottomSheetMenuItem.dart';


class StatisticBottomPage extends StatelessWidget{

  StatisticBottomPage({this.themeColor=Colors.black54});
  final Color themeColor;

  @override
  Widget build(BuildContext context) {
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
                        Text("Statistics",style: TextStyle(fontSize: 17,),),
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
                    icon:Icon(Icons.show_chart, size: MediaQuery.of(context).size.width*0.16,color: themeColor.withOpacity(0.8),),
                    title:'Financial Stats',
                page: FinStats(),),

                BsMenuItem(
                    height:gridHeight,
                    icon:Icon(Icons.fastfood, size: MediaQuery.of(context).size.width*0.16,color: themeColor.withOpacity(0.8),),
                    title:'Product Stats',
                page: ProductStats(),),

                BsMenuItem(
                    height:gridHeight,
                    icon:Icon(Icons.supervisor_account, size: MediaQuery.of(context).size.width*0.16,color: themeColor.withOpacity(0.8),),
                    title:'Staffs Stats',
                page: StaffStats(),),

                BsMenuItem(
                    height:gridHeight,
                    icon:Icon(Icons.people_outline, size: MediaQuery.of(context).size.width*0.16,color: themeColor.withOpacity(0.8),),
                    title:'Customer Stats',
                  page: CustomerStats(),
                ),

                BsMenuItem(
                    height:gridHeight,
                    icon:Icon(Icons.folder_special, size: MediaQuery.of(context).size.width*0.16,color: themeColor.withOpacity(0.8),),
                    title:'Orders Stats',
                page: OrderStats(),),



              ]),
        ],
      ),
    );

  }
}