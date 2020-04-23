import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/page/admin/manageProduct.dart';
import 'package:pocketshopping/page/admin/sourceProduct.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/widget/bottomSheetMenuItem.dart';



class ProductBottomPage extends StatelessWidget{

  ProductBottomPage({this.session});
  final Session session;

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
                        Text("Product",style: TextStyle(fontSize: 14,),),
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
                  icon:Icon(Icons.add, size: MediaQuery.of(context).size.width*0.16,color: PRIMARYCOLOR.withOpacity(0.8),),
                  title:'Add New Product',
                  page:AddProduct(session: session,) ,),

                BsMenuItem(
                    height:gridHeight,
                    icon:Icon(MaterialIcons.arrow_drop_down_circle, size: MediaQuery.of(context).size.width*0.16,color: PRIMARYCOLOR.withOpacity(0.8),),
                    title:'Add Product From Pool',
                    page: SourceProduct(themeColor:PRIMARYCOLOR,),),

                BsMenuItem(
                    height:gridHeight,
                    icon:Icon(Icons.edit, size: MediaQuery.of(context).size.width*0.16,color: PRIMARYCOLOR.withOpacity(0.8),),
                    title:'Manage Product',
                  page: ManageProduct(),),

              ]),
        ],
      ),
    );

  }
}