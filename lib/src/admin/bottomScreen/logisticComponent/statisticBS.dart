import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/bottomScreen/bottomSheetMenuItem.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';

class LogisticStatBottomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double marginLR = Get.width;
    double gridHeight = Get.height * 0.1;
    return Container(
      height: Get.height * 0.5,
      width: marginLR,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverList(
              delegate: SliverChildListDelegate([
            Container(
              height: Get.height * 0.02,
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
                size: Get.width * 0.16,
                color: PRIMARYCOLOR.withOpacity(0.8),
              ),
              title: 'General Stats',
              page: Container(),
            ),
            BsMenuItem(
              height: gridHeight,
              icon: Icon(
                MaterialIcons.local_taxi,
                size: Get.width * 0.16,
                color: PRIMARYCOLOR.withOpacity(0.8),
              ),
              title: 'Vehicle Stats',
              page: Container(),
            ),
            BsMenuItem(
              height: gridHeight,
              icon: Icon(
                MaterialIcons.motorcycle,
                size: Get.width * 0.16,
                color: PRIMARYCOLOR.withOpacity(0.8),
              ),
              title: 'Agent Stats',
              page: Container(),
            ),
          ]),
        ],
      ),
    );
  }
}
