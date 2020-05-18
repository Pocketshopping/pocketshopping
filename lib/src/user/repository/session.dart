import 'package:meta/meta.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffObj.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/user/package_user.dart';

@immutable
class Session {
  final User user;
  final Merchant merchant;
  final Agent agent;
  final Staff staff;

  Session({this.user, this.merchant, this.agent, this.staff});

  Session copyWith({User user, Merchant merchant, Agent agent, Staff staff}) {
    return Session(
      user: user ?? this.user,
      merchant: merchant ?? this.merchant,
      agent: agent ?? this.agent,
      staff: staff ?? this.staff,
    );
  }

  @override
  int get hashCode =>
      user.hashCode ^ merchant.hashCode ^ agent.hashCode ^ staff.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          merchant == other.merchant &&
          agent == other.agent &&
          staff == other.staff;

  @override
  String toString() {
    return '''Session {user:${user.uid}''';
  }
}
