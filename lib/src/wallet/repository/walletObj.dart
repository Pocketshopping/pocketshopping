import 'package:meta/meta.dart';

@immutable
class Wallet {
  final double walletBalance;
  final String accountNumber;
  final double deliveryBalance;
  final double refferalBonus;
  final String bankCode;
  final String bankName;
  final double merchantBalance;
  final double pocketUnitBalance;
  final dynamic createdAt;

  Wallet({
    this.walletBalance,
    this.accountNumber,
    this.deliveryBalance,
    this.refferalBonus,
    this.bankCode,
    this.bankName,
    this.merchantBalance,
    this.pocketUnitBalance,
    this.createdAt,
  });

  Wallet copyWith({
    double walletBalance,
    String accountNumber,
    double deliveryBalance,
    double refferalBonus,
    String bankCode,
    String bankName,
    double merchantBalance,
    double pocketUnitBalance,
    dynamic createdAt,
  }) {
    return Wallet(
      walletBalance: walletBalance ?? this.walletBalance,
      accountNumber: accountNumber ?? this.accountNumber,
      deliveryBalance: deliveryBalance ?? this.deliveryBalance,
      refferalBonus: refferalBonus ?? this.refferalBonus,
      bankCode: bankCode ?? this.bankCode,
      bankName: bankName ?? this.bankName,
      merchantBalance: merchantBalance ?? this.merchantBalance,
      pocketUnitBalance: pocketUnitBalance ?? this.pocketUnitBalance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  int get hashCode =>
      walletBalance.hashCode ^
      accountNumber.hashCode ^
      deliveryBalance.hashCode ^
      refferalBonus.hashCode ^
      bankCode.hashCode ^
      bankName.hashCode ^
      merchantBalance.hashCode ^
      pocketUnitBalance.hashCode ^
      createdAt.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wallet &&
          runtimeType == other.runtimeType &&
          walletBalance == other.walletBalance &&
          accountNumber == other.accountNumber &&
          bankCode == other.bankCode &&
          merchantBalance == other.merchantBalance &&
          bankName == other.bankName &&
          createdAt == other.createdAt &&
          deliveryBalance == other.deliveryBalance &&
          refferalBonus == other.refferalBonus;

  @override
  String toString() {
    return '''Instance of Wallet''';
  }

  static Wallet fromMap(Map<String, dynamic> data) {
    return Wallet(
      walletBalance: data['walletBalance']??0,
      accountNumber: data['accountNumber']??"",
      deliveryBalance: data['deliveryBalance']??0,
      refferalBonus: data['RefferalBonus']??0,
      bankCode: data['sortCode']??"",
      bankName: data['bankName']??"",
      merchantBalance: data['merchantBalance']??0,
      pocketUnitBalance: data['pocketBalance']??0,
      createdAt: data['CreatedAt'],
    );
  }
}
