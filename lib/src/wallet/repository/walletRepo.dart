import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/server/bloc/serverBloc.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';

class WalletRepo {
  static final databaseReference = FirebaseFirestore.instance;

  static Future<Wallet> getWallet(String wid,{String key=''}) async {
    //print(await ServerBloc.instance.getServerKey());
    final response = await http.get("${WALLETAPI}wallets/$wid",
        headers: {
          'Content-Type': 'application/json',
          'ApiKey': key.isNotEmpty?key:await ServerBloc.instance.getServerKey(),
        }).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );

    if(response != null) {
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return Wallet.fromMap(result);
      } else {
        return null;
      }
    }
    else{
      return null;
    }
  }

}
