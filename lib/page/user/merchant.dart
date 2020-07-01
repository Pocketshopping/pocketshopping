import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:pocketshopping/component/dialog.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/page/map.dart';
import 'package:pocketshopping/page/user/drawer.dart';
import 'package:pocketshopping/page/user/menu.dart';
import 'package:pocketshopping/page/user/product.dart';
import 'package:pocketshopping/widget/bSheetCartWidget.dart';
import 'package:pocketshopping/widget/bSheetMapTemplate.dart';
import 'package:pocketshopping/widget/bSheetMessageWidget.dart';
import 'package:pocketshopping/widget/bSheetReviewWidget.dart';
import 'package:pocketshopping/widget/bSheetSocialWidget.dart';

class MerchantWidget extends StatefulWidget {
  static String tag = 'Merchant-page';

  MerchantWidget({
    this.data,
    this.page,
  });

  final Map data;
  final Function page;

  @override
  _MerchantWidget createState() => new _MerchantWidget();
}

class _MerchantWidget extends State<MerchantWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}
