

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/server/bloc/serverBloc.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';

class FaqRepo {
  final databaseReference = Firestore.instance;

  static Future<List<Map<String,dynamic>>> faq() async {
    final response = await http.get("${WALLETAPI}faq/fetch?id=all",
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
        return withdrawals.reversed.toList();
      } else {
        throw http.ClientException;
      }
    else
      throw http.ClientException;
  }

}

