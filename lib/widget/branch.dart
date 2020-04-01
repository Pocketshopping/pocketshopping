import 'package:flutter/material.dart';
import 'package:pocketshopping/page/admin/manageBranch.dart';
import 'package:pocketshopping/widget/bottomSheetMenuItem.dart';
import 'package:pocketshopping/page/admin/addBranch.dart';


class BranchBottomPage extends StatelessWidget{

  BranchBottomPage({this.themeColor=Colors.black54});
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
                        Text("Branch(es)",style: TextStyle(fontSize: 17,),),
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
                    title:'Create Branch',
                    page:AddBranch(color: themeColor,
                    coverUrl: 'https://scontent-los2-1.xx.fbcdn.net/v/t1.0-9/13015366_962282610522031_7032913772865906850_n.jpg?_nc_cat=110&_nc_sid=dd9801&_nc_ohc=2tFLxKELYhUAX9UaXox&_nc_ht=scontent-los2-1.xx&oh=f4372b89baf627b42395be5d593f81ca&oe=5EA6150F',) ),

                BsMenuItem(
                    height:gridHeight,
                    icon:Icon(Icons.edit,size: MediaQuery.of(context).size.width*0.16,color: themeColor.withOpacity(0.8),),
                    title:'Manage Branch(es)',
                page: ManageBranch(),),

              ]),
        ],
      ),
    );

  }
}