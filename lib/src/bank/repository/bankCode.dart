import 'package:meta/meta.dart';

@immutable
class BankCode {
  final String name;
  final String code;
  final String longCode;
  final int id;

  BankCode({
    this.name,
    this.code,
    this.longCode,
    this.id,
  });

  BankCode copyWith({
    String name,
    String code,
    String longCode,
    int id,

  }) {
    return BankCode(
      name: name ?? this.name,
      code: code ?? this.code,
      longCode: longCode ?? this.longCode,
      id: id ?? this.id,
    );
  }

  @override
  int get hashCode =>
      name.hashCode ^
      code.hashCode ^
      longCode.hashCode ^
      id.hashCode ;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BankCode &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              code == other.code &&
              longCode == other.longCode &&
              id == other.id;

  @override
  String toString() {
    return '''Instance of BankCode''';
  }

  static BankCode fromMap(Map<String, dynamic> data) {
    return BankCode(
      name: data['name'],
      code: data['code'],
      longCode: data['longcode'],
      id: data['id'],
    );
  }

  static List<BankCode> fromListMap(List<Map<String,dynamic>>data){
    return data.map((e) => BankCode.fromMap((Map.castFrom(e)))).toList();
  }
}
