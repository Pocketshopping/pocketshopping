import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/bank/repository/bankCode.dart';
import 'package:pocketshopping/src/bank/repository/bankRepo.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/tracker.dart';
import 'package:pocketshopping/src/payment/topup.dart';
import 'package:pocketshopping/src/profile/pinTester.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:flutter/services.dart';
import 'package:pocketshopping/src/pin/repository/pinRepo.dart';
import 'package:pocketshopping/src/pin/repository/pinObj.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class AdminFinance extends StatefulWidget {
  final Function topUp;
  final Function withdraw;
  AdminFinance({this.topUp,this.withdraw});
  @override
  _AdminFinanceState createState() => new _AdminFinanceState();
}

class _AdminFinanceState extends State<AdminFinance> {

  final _walletNotifier = ValueNotifier<Wallet>(null);
  Stream<Wallet> _walletStream;

  @override
  void initState() {
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if(mounted) {
        updateWallet(wallet);
      }
    });
    super.initState();
  }

  Future<bool> updateWallet(Wallet wallet){
    _walletNotifier.value=null;
    _walletNotifier.value = wallet;
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: ValueListenableBuilder(
        valueListenable: _walletNotifier,
        builder: (_,Wallet wallet,__){
          if(wallet != null){
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Center(
                                child: Text(
                                  "Business Revenue",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                )),
                            Center(
                                child: Text(
                                  "collected by pocketshopping",
                                  style: TextStyle(
                                      fontSize: 11),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                                child: Text(
                                  "\u20A6 ${wallet.merchantBalance}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                )),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        )
                    ),
                    const Expanded(
                      flex: 0,
                      child: SizedBox(
                        width: 10,
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Center(
                                child: Text(
                                  "Delivery Revenue",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                )),
                            const Center(
                                child: Text(
                                  "collected by pocketshopping",
                                  style: TextStyle(
                                      fontSize: 11),
                                )),
                            const  SizedBox(
                              height: 10,
                            ),
                            Center(
                                child: Text(
                                  "\u20A6 ${wallet.deliveryBalance}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        )
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Container(
                  width: double.maxFinite,
                  color: PRIMARYCOLOR.withOpacity(0.8),
                  child: FlatButton(
                    onPressed: (){
                      if(widget.topUp != null)
                        widget.withdraw(wallet);
                    },
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text('Withdraw( $CURRENCY${(wallet.deliveryBalance + wallet.merchantBalance)} )',style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  )
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Center(
                                child: const Text(
                                  "PocketUnit",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )
                            ),
                            Center(
                                child: Text(
                                  "1.00 unit = ${CURRENCY}1.00",
                                  style: TextStyle(
                                      fontSize: 11),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                                child: Text(
                                  "${wallet.pocketUnitBalance}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: PRIMARYCOLOR
                                        .withOpacity(0.5)),
                                color:
                                PRIMARYCOLOR.withOpacity(0.8),
                              ),
                              child: FlatButton(
                                onPressed: ()  {
                                  if(widget.topUp != null)
                                  widget.topUp();

                                },
                                child: const Center(
                                    child: const Text(
                                      "TopUp",
                                      style: const TextStyle(
                                          color: Colors.white),
                                    )),
                              ),
                            )
                          ],
                        )
                    ),
                  ],
                )
              ],
            );
          }
          else{
            return Center(child: Text('No internet connection.'),);
          }
        },
      ),
    );

  }
}