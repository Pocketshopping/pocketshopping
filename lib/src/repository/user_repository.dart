import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;


  UserRepository({FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<FirebaseUser> signIn(String email, String password) async {
    try{
      AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );


      if (result.user.isEmailVerified) {
        FirebaseUser user = result.user;
        return user;
      }
      throw("EMAIL UNVERIFIED");
    }catch(e){
      throw(e);
    }
  }

  Future<String> signUp({String role, String email, String password}) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    FirebaseUser user = result.user;
    await upDateUserRole(role, user);

    try {await user.sendEmailVerification();} catch (e) {
     // print(e);
    }

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

  Future<void> changeRole(String role) async {
    FirebaseUser user = await getCurrentUser();
    UserUpdateInfo info = UserUpdateInfo();
    info.displayName = role;
    await user.updateProfile(info);
  }

  Future<void> upDateUserRole(String role, FirebaseUser user) async {
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

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null && currentUser.isEmailVerified;
  }

  Future<int> passwordReset(String email) async {
    try{
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return 1;
    }on PlatformException catch(_){

      if(_.code == 'ERROR_USER_NOT_FOUND'){
        debugPrint(_.code);
        return 2;
      }
      else{
        return 3;
      }
      }
      catch(_){
      return 0;
      }
  }


}
