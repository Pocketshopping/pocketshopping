import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/order/tracker.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/ui/shared/infinitScroll/infinite.dart';
import 'package:pocketshopping/src/user/MyOrder/orderGlobal.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:provider/provider.dart';

import 'MyOrderModel.dart';

class OpenOrder extends StatefulWidget {
  final Session user;

  OpenOrder({Key key, this.user}) : super(key: key);

  @override
  _OpenOrderState createState() => new _OpenOrderState();
}

class _OpenOrderState extends State<OpenOrder> {
  bool showBottomDetail = false;
  String callbackVal = "";
  OrderGlobalState odState;

  @override
  void initState() {
    odState = Get.put(OrderGlobalState());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ChangeNotifierProvider<MyOrderModel>(
        create: (context) => MyOrderModel(
            {'uid': widget.user.user.uid, 'category': 'PROCESSING'}),
        child: Consumer<MyOrderModel>(
          builder: (context, model, child) => ListView.builder(
            itemCount: model.items.length,
            itemBuilder: (context, index) => AwareListItem(
              itemCreated: () {
                SchedulerBinding.instance.addPostFrameCallback(
                    (duration) => model.handleItemCreated(index));
              },
              child: ListItem(
                title: model.items[index],
                template: model.items[0] != SearchEmptyOrderIndicatorTitle
                    ? MyOpenOrderIndicatorTitle
                    : SearchEmptyOrderIndicatorTitle,
                callback: (value) {
                  Get.to(OrderTrackerWidget(
                    order: value,
                    user: widget.user.user,
                  ));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
