import 'package:flutter/material.dart';
import 'package:pocketshopping/page/admin/manageStaff.dart';
import 'package:pocketshopping/src/logistic/agent/newAgent.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/widget/bottomSheetMenuItem.dart';

class AgentBottomPage extends StatelessWidget {
  AgentBottomPage({this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    double marginLR = MediaQuery.of(context).size.width;
    double gridHeight = MediaQuery.of(context).size.height * 0.1;
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
                      "Agent",
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
                  size: MediaQuery.of(context).size.width * 0.16,
                  color: PRIMARYCOLOR.withOpacity(0.8),
                ),
                title: 'Add Agent',
                page: AgentForm(
                  session: session,
                )),
            BsMenuItem(
              height: gridHeight,
              icon: Icon(
                Icons.edit,
                size: MediaQuery.of(context).size.width * 0.16,
                color: PRIMARYCOLOR.withOpacity(0.8),
              ),
              title: 'Manage Agent',
              page: ManageStaff(),
            ),
          ]),
        ],
      ),
    );
  }
}
