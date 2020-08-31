import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/bottomScreen/bottomSheetMenuItem.dart';
import 'package:pocketshopping/src/logistic/agentCompany/agentList.dart';
import 'package:pocketshopping/src/logistic/vehicle/newVehicle.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/user/package_user.dart';

class LogisticReportBottomPage extends StatelessWidget {
  LogisticReportBottomPage({this.session});

  final Session session;

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
                          "Report",
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
                  Icons.show_chart,
                  size: Get.width * 0.16,
                  color: PRIMARYCOLOR.withOpacity(0.8),
                ),
                title: 'General Report',
                page: VehicleForm(
                  session: session,
                )),
            BsMenuItem(
              height: gridHeight,
              icon: Icon(
                Icons.person_pin,
                size: Get.width * 0.16,
                color: PRIMARYCOLOR.withOpacity(0.8),
              ),
              title: 'Agent Report',
              page: AgentList(user: session,),
            ),
          ]),
        ],
      ),
    );
  }
}
