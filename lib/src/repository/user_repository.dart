import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';


class UserRepository {
  final FirebaseAuth _firebaseAuth;


  UserRepository({FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;



  Future<FirebaseUser> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,



    );
    FirebaseUser user = result.user;
    return user;
  }

  Future<String> signUp(String role , String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    upDateUserRole(role);
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {

    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }


  Future<void> signOut() async {
    var result = _firebaseAuth.signOut();
    return result;

  }

  Future<void> upDateUserRole(String role) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    UserUpdateInfo info = UserUpdateInfo();
    info.displayName = role;
    await user.updateProfile(info);

  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }
}