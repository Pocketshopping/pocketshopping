import 'package:meta/meta.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/user/package_user.dart';

@immutable
class Session {
  final User user;
  final Merchant merchant;

  Session({this.user, this.merchant});

  Session copyWith({
    User user,
    Merchant merchant,
  }) {
    return Session(
      user: user ?? this.user,
      merchant: merchant ?? this.merchant,
    );
  }

  @override
  int get hashCode => user.hashCode ^ merchant.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          merchant == other.merchant;

  @override
  String toString() {
    return '''Session {
        user: $user,
    merchnant: $merchant,
    }''';
  }
}
