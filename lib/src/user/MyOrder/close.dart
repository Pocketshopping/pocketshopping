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

class CloseOrder extends StatefulWidget {
  final Session user;

  CloseOrder({Key key, this.user}) : super(key: key);

  @override
  _CloseOrderState createState() => new _CloseOrderState();
}

class _CloseOrderState extends State<CloseOrder> {
  bool showBottomDetail = false;
  String callbackVal = "";
  OrderGlobalState odState;

  @override
  void initState() {
    //print(odState);
    odState = Get.put(OrderGlobalState());
    //odState.adder('uyrturuy', {'jhjh':'yiugi'});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //print("callbackVal $callbackVal");
    void detail(String name) {
      showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheetTemplate(
            height: MediaQuery.of(context).size.height * 0.6,
            opacity: 0.2,
            child: Container()),
        isScrollControlled: true,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: ChangeNotifierProvider<MyOrderModel>(
        create: (context) => MyOrderModel(
            {'uid': widget.user.user.uid, 'category': 'COMPLETED'}),
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
                    ? MyClosedOrderIndicatorTitle
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
