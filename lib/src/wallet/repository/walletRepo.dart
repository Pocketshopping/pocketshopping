import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';

class WalletRepo {
  static final databaseReference = Firestore.instance;

  static Future<Wallet> getWallet(String wid) async {
    //print(pid);
    final response = await http.get("${WALLETAPI}wallets/$wid", headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      print(result);
      return Wallet.fromMap(result);
    } else {
      return null;
    }
  }
}
