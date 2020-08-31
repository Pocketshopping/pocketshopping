

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/server/bloc/serverBloc.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/withdrawal/repository/withdrawalObj.dart';

class WithdrawalRepo {
  final databaseReference = FirebaseFirestore.instance;

  static Future<List<Withdrawal>> withdrawReport({String wid}) async {
    DateTime dateTime=DateTime.now().subtract(Duration(days: 29));
    String from = '${dateTime.month}-${dateTime.day}-${dateTime.year}';
    String to = DateTime.now().toString();
    final response = await http.get("${WALLETAPI}Withdraw?from=$from&to=$to&pocket=$wid&pageNumber=1&_pageSize=50&pageSize=50",
        headers: {
          'Content-Type': 'application/json',
          'ApiKey':await ServerBloc.instance.getServerKey(),
        }).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
    if(response != null)
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        List<Map<String,dynamic>> withdrawals=[];
        withdrawals.addAll(List.castFrom(result));
        print(Withdrawal.fromListMap(withdrawals));
        return withdrawals.isNotEmpty?Withdrawal.fromListMap(withdrawals):[];
      } else {
        throw http.ClientException;
      }
    else
      throw http.ClientException;
  }



  static Future<bool> withdrawFunds({String wid, int type=1 }) async {
    final response = await http.post("${WALLETAPI}Withdraw",
        headers: {
          'Content-Type': 'application/json',
          'ApiKey':await ServerBloc.instance.getServerKey(),
        },
        body: jsonEncode(
          <String, dynamic>{
            "walletID": wid,
            "type": type,
          },
        )).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
    if(response != null)
      if (response.statusCode == 200) {
        return true;
      } else {
        print(response.statusCode);
        print(response.body);
        return false;
      }
    else {
      print('response: ${response.statusCode}');
      return false;
    }
  }

}

