import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/user/repository/userEntity.dart';

@immutable
class Wallet {
  final double pocketBalance;
  final String accountNumber;
  final double deliveryBalance;
  final double refferalBonus;
  final String bankCode;
  final String bankName;
  final double businessMoney;
  final double pocketUnitBalance;
  final dynamic createdAt;


  Wallet({

    this.pocketBalance,
    this.accountNumber,
    this.deliveryBalance,
    this.refferalBonus,
    this.bankCode,
    this.bankName,
    this.businessMoney,
    this.pocketUnitBalance,
    this.createdAt,

      });

  Wallet copyWith({
    double pocketBalance,
    String accountNumber,
    double deliveryBalance,
    double refferalBonus,
    String bankCode,
    String bankName,
    double businessMoney,
    double pocketUnitBalance,
    dynamic createdAt,
  }) {
    return Wallet(
      pocketBalance:pocketBalance??this.pocketBalance,
      accountNumber:accountNumber??this.accountNumber,
      deliveryBalance:deliveryBalance??this.deliveryBalance,
      refferalBonus:refferalBonus??this.refferalBonus,
      bankCode:bankCode??this.bankCode,
      bankName:bankName??this.bankName,
      businessMoney:businessMoney??this.businessMoney,
      pocketUnitBalance:pocketUnitBalance??this.pocketUnitBalance,
      createdAt:createdAt??this.createdAt,
    );
  }

  @override
  int get hashCode =>
      pocketBalance.hashCode ^
      accountNumber.hashCode ^
      deliveryBalance.hashCode ^
      refferalBonus.hashCode ^
      bankCode.hashCode ^
      bankName.hashCode ^
      businessMoney.hashCode ^
      pocketUnitBalance.hashCode ^
      createdAt.hashCode;



  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Wallet &&
              runtimeType == other.runtimeType &&
              pocketBalance == other.pocketBalance &&
              accountNumber == other.accountNumber &&
              bankCode == other.bankCode &&
              businessMoney == other.businessMoney &&
              bankName == other.bankName &&
              createdAt == other.createdAt &&
              deliveryBalance == other.deliveryBalance &&
              refferalBonus == other.refferalBonus;

  @override
  String toString() {
    return '''Wallet {pocketBalance: $pocketBalance,}''';
  }

  static Wallet fromMap(Map<String,dynamic> data) {
    return Wallet(
      pocketBalance:data['PocketBalance'],
      accountNumber:data['AccountNumber'],
      deliveryBalance:data['DeliveryBalance'],
      refferalBonus:data['RefferalBonus'],
      bankCode:data['BankCode'],
      bankName:data['FirstBank'],
      businessMoney:data['BusinessMoney'],
      pocketUnitBalance:data['PocketUnitBalance'],
      createdAt:data['CreatedAt'],

    );
  }
}
