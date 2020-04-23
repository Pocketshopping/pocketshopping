import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/user/repository/userEntity.dart';

@immutable
class User {

  final String fname;
  final String email;
  final String telephone;
  final String role;
  final String notificationID;
  final String defaultAddress;
  final String profile;
  final String uid;
  final DocumentReference bid;
  final DocumentReference behaviour;
  final Timestamp createdat;
  final String country;




  User(this.uid, {
    this.fname = "",
    this.email="",
    this.telephone="",
    this.notificationID="",
    this.defaultAddress="",
    this.profile="",
    this.bid,
    this.role="",
    this.behaviour,
    this.country="NG",
    this.createdat
  });

  User copyWith({
     String fname,
     String email,
     String telephone,
     String role,
     String notificationID,
     String defaultAddress,
     String profile,
    DocumentReference bid,
    String uid,
    DocumentReference behaviour,
     String country,
    DateTime createdat,

  }) {
    return User(
      uid ?? this.uid,
      fname: fname ?? this.fname,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      notificationID: notificationID ?? this.notificationID,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      profile: profile ?? this.profile,
      bid: bid ?? this.bid,
      role: role ?? this.role,
      behaviour: behaviour ?? this.behaviour,
      country: country ?? this.country,
      createdat: createdat ?? this.createdat
    );
  }


  @override
  int get hashCode =>
      uid.hashCode ^ fname.hashCode ^ email.hashCode ^ telephone.hashCode ^ notificationID.hashCode ^
  defaultAddress.hashCode ^ profile.hashCode ^ bid.hashCode ^ role.hashCode ^ behaviour.hashCode ^ country.hashCode ^
  createdat.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is User &&
              runtimeType == other.runtimeType &&
              uid == other.uid &&
              fname == other.fname &&
              email == other.email &&
              telephone == other.telephone &&
              notificationID == other.notificationID &&
              defaultAddress == other.defaultAddress &&
              profile == other.profile &&
              bid == other.bid &&
              role == other.role &&
              behaviour == other.behaviour &&
              country == other.country &&
              createdat == other.createdat;


  @override
  String toString() {
    return '''User {
        fname: $fname,
    email: $email,
    telephone: $telephone,
    profile:$profile,
    notificationID:$notificationID,
    defaultAddress:$defaultAddress,
    role:$role,
    business:$bid,
    createdAt:$createdat,
    behaviour:$behaviour,
    country:$country}''';
  }

  UserEntity toEntity() {
    return UserEntity(
      uid,
      fname,
      email,
      telephone,
      profile,
      notificationID,
      defaultAddress,
      role,
      bid,
      createdat,
      behaviour,
      country,



    );
  }

  static User fromEntity(UserEntity user) {
    return User(
      user.uid,
        fname: user.fname ?? 'user',
        email: user.email ?? '',
        telephone: user.telephone ?? '',
        notificationID: user.notificationID ?? '',
        defaultAddress: user.defaultAddress ?? '',
        profile: user.profile ?? '',
        bid: user.bid,
        role: user.role ?? '',
        behaviour: user.behaviour,
        country: user.country ?? '',
        createdat: user.createdat
    );
  }


  }