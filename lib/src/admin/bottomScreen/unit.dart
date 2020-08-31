import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/pocketPay/unitHistory.dart';
import 'package:pocketshopping/src/pocketPay/unitTransfer.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/user/package_user.dart';

class UnitBottomPage extends StatelessWidget {
  final Session user;
  final String wallet;
  final User sender;
  UnitBottomPage({this.user,this.wallet,this.sender});

  @override
  Widget build(BuildContext context) {
   double marginLR = Get.width;
    return Container(
      height: Get.height * 0.4,
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Container(
                  height: Get.height * 0.02,
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
              /*Expanded(
                child: FlatButton(
                  onPressed: (){
                    Get.dialog(TopUp(user: sender,payType: "TOPUPUNIT",));
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: Get.width * 0.16,
                        color: PRIMARYCOLOR.withOpacity(0.8),
                      ),
                      Text('TopUp'),
                    ],
                  ),
                ),
              ),*/
              Expanded(
                child: FlatButton(
                  onPressed: (){
                    Get.dialog(PocketUnitTransfer(
                      user: sender,
                      wallet: wallet,
                      sender: user.user.walletId,
                    )
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        AntIcons.share_alt,
                        size: Get.width * 0.16,
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
                    Get.dialog(UnitHistory(user: user,));
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        AntIcons.history,
                        size: Get.width * 0.16,
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
