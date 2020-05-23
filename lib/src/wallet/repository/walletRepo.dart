import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';

class WalletRepo {
  static final databaseReference = Firestore.instance;

  static Future<Wallet> getWallet(String wid) async {
    //print(pid);
    final response = await http.get("${WALLETAPI}pocket/detail/$wid", headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return Wallet.fromMap(result['pocketdetail']);
    } else {
      return null;
    }
  }
}
