import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;


@immutable
class Receipt {


  final String PsStatus;
  final String reference;


  Receipt({
    this.PsStatus,
    this.reference,
  });

  Receipt copyWith({
    String PsStatus,
    String reference,
  }) {
    return Receipt(
        PsStatus: PsStatus??this.PsStatus,
        reference: reference??this.reference,
    );
  }


  @override
  int get hashCode =>
      PsStatus.hashCode ^ PsStatus.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Receipt &&
              runtimeType == other.runtimeType &&
              PsStatus == other.PsStatus &&
              reference == other.reference;



  @override
  String toString() {
    return '''Receipt {reference: $reference,}''';
  }

  Future<http.Response> receiptDetail() async {


    final response = await http.get('https://api.paystack.co/transaction/verify/${reference}', headers: {"Accept":"application/json",
      "Authorization":"Bearer sk_test_8c0cf47e2e690e41c984c7caca0966e763121968"},);
    if (response.statusCode == 200) {
      return response;
    } else {
      print(response.body);
    }
  }

  Map<String,dynamic> toMap(){
    return {
      'PsStatus': PsStatus,
      'reference': reference,
    };
  }

  static Receipt fromMap(Map<String,dynamic> receipt){
    return Receipt(
      PsStatus: receipt['PsStatus'],
      reference: receipt['reference'],
    );
  }

}