import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/bank/repository/bankCode.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';

class BankRepo {
  static final databaseReference = Firestore.instance;

  static Future<List<BankCode>> getBankCode() async {
    final response = await http.get("${PaystackAPI}bank",
        headers: {
      'Content-Type': 'application/json',
      "Authorization": PAYSTACK
    }).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );

    if(response != null) {
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return BankCode.fromListMap(List.castFrom(result['data']));
      } else {
        return null;
      }
    }
    else{
      return null;
    }
  }

  static Future<String> verifyBankAccount(String acctNumber,String bankCode) async {
    print(bankCode);
    final response = await http.get("${PaystackAPI}bank/resolve?account_number=$acctNumber&bank_code=$bankCode",
        headers: {
          'Content-Type': 'application/json',
          "Authorization": PAYSTACK
        }).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        throw throw http.ClientException;
      },
    );

    if(response != null) {
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result['data']['account_name'];
      } else {
        throw http.ClientException;
      }
    }
    else{
      throw throw http.ClientException;
    }
  }




}
