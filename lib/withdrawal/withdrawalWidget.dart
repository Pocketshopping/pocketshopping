import 'dart:async';

import 'package:badges/badges.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/order/repository/cartObj.dart';
import 'package:pocketshopping/src/payment/topup.dart';
import 'package:pocketshopping/src/pos/checkOut.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';

class Withdrawal extends StatefulWidget {
  final Session user;
  Withdrawal({this.user,});
  @override
  _WithdrawalState createState() => new _WithdrawalState();
}

class _WithdrawalState extends State<Withdrawal> {


  void initState() {
    super.initState();
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
            MediaQuery.of(context).size.height *
                0.22),
        child: AppBar(
          title: Text('Withdrawals',style: TextStyle(color: PRIMARYCOLOR),),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.grey,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          elevation: 0.0,
        ),
      ),
      body: Column(
        children: [
          Expanded(flex:0,child: SizedBox(height: 10,)),
          Expanded(
              flex:3,
              Container(
                child: RefreshIndicator(
                  child: FutureBuilder(),
                  onRefresh: _refresh,
                ),
              ):
              ListTile(
                title: Image.asset('assets/images/empty.gif'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Empty',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.06),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "No Product added yet",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
                  :
              Center(
                child: JumpingDotsProgressIndicator(
                  fontSize: MediaQuery.of(context).size.height * 0.12,
                  color: PRIMARYCOLOR,
                ),
              )
          ),
        ],
      ),

    );
  }



  Future<void> _refresh() async {

  }










}
