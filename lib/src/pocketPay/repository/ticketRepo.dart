import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/pocketPay/repository/ticketObj.dart';
import 'package:pocketshopping/src/server/bloc/serverBloc.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class TicketRepo {
  static final databaseReference = FirebaseFirestore.instance;

  static Future<bool> saveTicket({String customerID,String category, String complain}) async {
    //print(await ServerBloc.instance.getServerKey());
    final response = await http.post("${WALLETAPI}ticket/add",
        headers: {
          'Content-Type': 'application/json',
          'ApiKey': await ServerBloc.instance.getServerKey(),
        },
        body: jsonEncode(
          <String, dynamic>{
            "complain": "$complain",
            "category": category,
            "customerID": customerID,
          })).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );

    if(response != null) {
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }
    else{
      return false;
    }
  }

  static Future<List<Ticket>> ticketHistory({String pocket,int pNumber=1,int pSize=20,}) async {
    DateTime thirty = DateTime.now();
    var to = '${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().year} 23:59:59';
    var from = '${thirty.month}-${thirty.day}-${thirty.year} 00:00:00';
    final response = await http.get("${WALLETAPI}ticket/bycustomerid?pocket=$pocket&from=$from&to=$to&pageNumber=$pNumber",
        headers: {
          'Content-Type': 'application/json',
          'ApiKey':await ServerBloc.instance.getServerKey(),
        }).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        Utility.noInternet();
        return null;
      },
    );
    if(response != null)
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return Ticket.fromListMap(List.castFrom(result));
      } else {
        return [];
      }
    else
      return [];
  }

}
