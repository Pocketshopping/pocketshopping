import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/bottomScreen/bottomSheetMenuItem.dart';

class StaffBottomPage extends StatelessWidget {
  StaffBottomPage({this.themeColor = Colors.black54});

  final Color themeColor;

  @override
  Widget build(BuildContext context) {
    double marginLR = Get.width;
    double gridHeight = Get.height * 0.1;
    return Container(
      height: Get.height * 0.4,
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
                      "Staff",
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
                  Icons.person_add,
                  size: Get.width * 0.16,
                  color: themeColor.withOpacity(0.8),
                ),
                title: 'Add Staff',
                page: Container()),
            BsMenuItem(
              height: gridHeight,
              icon: Icon(
                Icons.edit,
                size: Get.width * 0.16,
                color: themeColor.withOpacity(0.8),
              ),
              title: 'Manage Staffs',
              page: Container(),
            ),
          ]),
        ],
      ),
    );
  }
}
