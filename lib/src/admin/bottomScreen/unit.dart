import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/bottomScreen/bottomSheetMenuItem.dart';
import 'package:pocketshopping/src/payment/topup.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/user/package_user.dart';

class UnitBottomPage extends StatelessWidget {
  final Session user;
  UnitBottomPage({this.user});

  @override
  Widget build(BuildContext context) {
   double marginLR = MediaQuery.of(context).size.width;
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: marginLR * 0.04),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "PocketUnit",
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
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FlatButton(
                  onPressed: (){
                    Get.dialog(TopUp(user: User(user.merchant.mID,role: 'staff',
                        walletId: user.merchant.bWallet,email: user.user.email),payType: "TOPUPUNIT",));
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: MediaQuery.of(context).size.width * 0.16,
                        color: PRIMARYCOLOR.withOpacity(0.8),
                      ),
                      Text('TopUp'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: FlatButton(
                  onPressed: (){
                    Get.dialog(TopUp(user: User(user.merchant.mID,role: 'staff',
                        walletId: user.merchant.bWallet,email: user.user.email),payType: "TOPUPUNIT",));
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        AntIcons.share_alt,
                        size: MediaQuery.of(context).size.width * 0.16,
                        color: PRIMARYCOLOR.withOpacity(0.8),
                      ),
                      Text('Transfer Unit'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: FlatButton(
                  onPressed: (){
                    Get.dialog(TopUp(user: User(user.merchant.mID,role: 'staff',
                        walletId: user.merchant.bWallet,email: user.user.email),payType: "TOPUPUNIT",));
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        AntIcons.history,
                        size: MediaQuery.of(context).size.width * 0.16,
                        color: PRIMARYCOLOR.withOpacity(0.8),
                      ),
                      Text('Purchase History',textAlign: TextAlign.center,),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
