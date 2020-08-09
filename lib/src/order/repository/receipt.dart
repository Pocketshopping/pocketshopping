import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

@immutable
class Receipt {
  final String psStatus;
  final String reference;
  final String type;
  final String pRef;
  final String collectionID;

  Receipt({
    this.psStatus,
    this.reference,
    this.type,
    this.pRef,
    this.collectionID
  });

  Receipt copyWith({
    String psStatus,
    String reference,
    String type,
    String pRef,
    String collectionID,
  }) {
    return Receipt(
      psStatus: psStatus ?? this.psStatus,
      reference: reference ?? this.reference,
      type: type??this.type,
      pRef: pRef??this.pRef,
      collectionID: collectionID??this.collectionID
    );
  }

  @override
  int get hashCode => psStatus.hashCode ^ psStatus.hashCode ^ type.hashCode ^ pRef.hashCode ^ collectionID.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Receipt &&
          runtimeType == other.runtimeType &&
          psStatus == other.psStatus &&
          reference == other.reference &&
          type == other.type &&
          pRef == other.pRef &&
          collectionID == other.collectionID;

  @override
  String toString() {
    return '''Instance of Receipt''';
  }

  Future<http.Response> receiptDetail() async {
    final response = await http.get(
      'https://api.paystack.co/transaction/verify/$reference',
      headers: {
        "Accept": "application/json",
        "Authorization":
            "Bearer sk_test_8c0cf47e2e690e41c984c7caca0966e763121968"
      },
    );
    if (response.statusCode == 200) {
      return response;
    } else {
      //print(response.body);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'psStatus': psStatus??'',
      'reference': reference??'',
      'type':type??'',
      'pRef':pRef??'',
      'collectionID':collectionID??'',
    };
  }

  static Receipt fromMap(Map<String, dynamic> receipt) {
    return Receipt(
      psStatus: receipt['psStatus'],
      reference: receipt['reference'],
      type: receipt['type']??'',
      pRef: receipt['pRef']??"",
      collectionID: receipt['collectionID']??""
    );
  }
}
