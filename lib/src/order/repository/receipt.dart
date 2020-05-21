import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

@immutable
class Receipt {
  final String PsStatus;
  final String reference;
  final String type;
  final String pRef;

  Receipt({
    this.PsStatus,
    this.reference,
    this.type,
    this.pRef
  });

  Receipt copyWith({
    String PsStatus,
    String reference,
    String type,
    String pRef
  }) {
    return Receipt(
      PsStatus: PsStatus ?? this.PsStatus,
      reference: reference ?? this.reference,
      type: type??this.type,
      pRef: pRef??this.pRef,
    );
  }

  @override
  int get hashCode => PsStatus.hashCode ^ PsStatus.hashCode ^ type.hashCode ^ pRef.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Receipt &&
          runtimeType == other.runtimeType &&
          PsStatus == other.PsStatus &&
          reference == other.reference &&
          type == other.type &&
          pRef == other.pRef;

  @override
  String toString() {
    return '''Instance of Receipt''';
  }

  Future<http.Response> receiptDetail() async {
    final response = await http.get(
      'https://api.paystack.co/transaction/verify/${reference}',
      headers: {
        "Accept": "application/json",
        "Authorization":
            "Bearer sk_test_8c0cf47e2e690e41c984c7caca0966e763121968"
      },
    );
    if (response.statusCode == 200) {
      return response;
    } else {
      print(response.body);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'PsStatus': PsStatus,
      'reference': reference,
      'type':type,
      'pRef':pRef
    };
  }

  static Receipt fromMap(Map<String, dynamic> receipt) {
    return Receipt(
      PsStatus: receipt['PsStatus'],
      reference: receipt['reference'],
      type: receipt['type']??'',
      pRef: receipt['pRef']??""
    );
  }
}
