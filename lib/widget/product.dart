import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pocketshopping/page/admin/addProduct.dart';
import 'package:pocketshopping/page/admin/manageProduct.dart';
import 'package:pocketshopping/page/admin/sourceProduct.dart';
import 'package:pocketshopping/widget/bottomSheetMenuItem.dart';

class ProductBottomPage extends StatelessWidget {
  ProductBottomPage({this.themeColor = Colors.black54});

  final Color themeColor;

  @override
  Widget build(BuildContext context) {
    double marginLR = MediaQuery.of(context).size.width;
    double gridHeight = MediaQuery.of(context).size.height * 0.1;


    Widget ProductManageListTemplate({int index}) {
      return GestureDetector(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(1.0),
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.0),
            //color: Colors.white,
            image: DecorationImage(
              image: AssetImage("assets/images/food.jpg"),
              fit: BoxFit.fill,
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(0.2), BlendMode.dstATop),
              //colorFilter: Colors.black.withOpacity(0.4),
            ),
          ),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,

                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Center(
                          child: Text(
                        'Resturant',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                        textAlign: TextAlign.left,
                      )),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 20,
                        ),
                        tooltip: 'View Map and get Direction',
                        onPressed: () {
                          //Navigator.of(context).pushNamed(MerchantMap.tag);
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.info,
                          size: 20,
                          color: Colors.white,
                        ),
                        tooltip: 'Who we are',
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Text(
                    "ProductName",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  RatingBar(
                    onRatingUpdate: (rate) {},
                    initialRating: 3.5,
                    minRating: 1,
                    maxRating: 5,
                    itemSize: MediaQuery.of(context).size.width * 0.04,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  Text(
                    'Price',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  FlatButton(
                    onPressed: () {},
                    textColor: Colors.white,
                    child: Text('Edit',
                        style: TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget ProductManageList({int index}) {
      return SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: MediaQuery.of(context).size.width * 0.5,
          //maxCrossAxisExtent :200,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          childAspectRatio: 1,
        ),
        delegate: new SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return ProductManageListTemplate();
          },
          childCount: 6,
        ),
      );
    }


    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: marginLR,
      child: CustomScrollView(
        slivers: <Widget>[
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
                padding: EdgeInsets.only(left: marginLR * 0.04),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Product",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "choose action",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
          SliverGrid.count(crossAxisCount: 3, children: [
            BsMenuItem(
              height: gridHeight,
              icon: Icon(
                Icons.add,
                size: MediaQuery.of(context).size.width * 0.16,
                color: themeColor.withOpacity(0.8),
              ),
              title: 'Add New Product',
              page: AddProduct(),
            ),
            BsMenuItem(
              height: gridHeight,
              icon: Icon(
                MaterialIcons.arrow_drop_down_circle,
                size: MediaQuery.of(context).size.width * 0.16,
                color: themeColor.withOpacity(0.8),
              ),
              title: 'Add Product From Pool',
              page: SourceProduct(
                themeColor: themeColor,
              ),
            ),
            BsMenuItem(
              height: gridHeight,
              icon: Icon(
                Icons.edit,
                size: MediaQuery.of(context).size.width * 0.16,
                color: themeColor.withOpacity(0.8),
              ),
              title: 'Manage Product',
              page: ManageProduct(),
            ),
          ]),
        ],
      ),
    );
  }
}
