import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:pocketshopping/page/admin/finStats.dart';
import 'package:pocketshopping/page/admin/productStats.dart';
import 'package:pocketshopping/page/admin/staffStats.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/widget/bottomSheetMenuItem.dart';

class LogisticStatBottomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double marginLR = MediaQuery.of(context).size.width;
    double gridHeight = MediaQuery.of(context).size.height * 0.1;
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
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
                      "Statistics",
                      style: TextStyle(
                        fontSize: 17,
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
                MaterialIcons.pie_chart,
                size: MediaQuery.of(context).size.width * 0.16,
                color: PRIMARYCOLOR.withOpacity(0.8),
              ),
              title: 'General Stats',
              page: FinStats(),
            ),
            BsMenuItem(
              height: gridHeight,
              icon: Icon(
                MaterialIcons.local_taxi,
                size: MediaQuery.of(context).size.width * 0.16,
                color: PRIMARYCOLOR.withOpacity(0.8),
              ),
              title: 'Vehicle Stats',
              page: ProductStats(),
            ),
            BsMenuItem(
              height: gridHeight,
              icon: Icon(
                MaterialIcons.motorcycle,
                size: MediaQuery.of(context).size.width * 0.16,
                color: PRIMARYCOLOR.withOpacity(0.8),
              ),
              title: 'Agent Stats',
              page: StaffStats(),
            ),
          ]),
        ],
      ),
    );
  }
}
