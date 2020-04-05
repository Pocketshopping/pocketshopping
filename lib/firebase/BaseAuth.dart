import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocketshopping/model/DataModel/userData.dart';

class Auth  with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  Future<FirebaseUser> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,



    );
    FirebaseUser user = result.user;
    notifyListeners();
    return user;
  }

  Future<String> signUp(String role , String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    upDateUserRole(role);
    notifyListeners();
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {

    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }


  Future<void> signOut() async {
    var result = _firebaseAuth.signOut();
    notifyListeners();
    return result;

  }

  Future<void> upDateUserRole(String role) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    notifyListeners();
    UserUpdateInfo info = UserUpdateInfo();
    info.displayName = role;
    notifyListeners();
    await user.updateProfile(info);

  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    notifyListeners();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    notifyListeners();
    return user.isEmailVerified;
  }
}