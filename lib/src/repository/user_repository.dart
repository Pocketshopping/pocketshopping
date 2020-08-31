import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:pocketshopping/src/user/package_user.dart' as ps;
import 'package:pocketshopping/src/utility/utility.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;



  UserRepository({FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<User> signIn(String email, String password) async {
    try{
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );


      if (result.user.emailVerified) {
        ps.User u = await ps.UserRepo.getOneUsingUID(result.user.uid);
        User user = result.user;
       await upDateUserRole(u.role, user);
       Utility.updateWalletPassword(uid:u.walletId,password: password);
       //user.reload();
        //print(user.displayName);

        return user;
      }
      await result.user.sendEmailVerification();
      throw("EMAIL UNVERIFIED");
    }catch(e){
      throw(e);
    }
  }

  Future<String> signUp({String role, String email, String password}) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    User user = result.user;
    await upDateUserRole(role, user);
    try {await user.sendEmailVerification();} catch (e) {}
    return user.uid;
  }

  Future<User> getCurrentUser() async {
    User user = _firebaseAuth.currentUser;
    try{
      await user.reload();
    }
    catch(_){}
    return user;
  }

  Future<void> signOut() async {
    var result = _firebaseAuth.signOut();
    return result;
  }

  Future<void> changeRole(String role) async {
    User user = await getCurrentUser();
    await user.updateProfile(displayName: role);
  }

  Future<void> upDateUserRole(String role, User user) async {
    await user.updateProfile(displayName: role);
  }

  void sendEmailVerification()  {
    User user = _firebaseAuth.currentUser;
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    User user = _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  bool isSignedIn() {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null && currentUser.emailVerified;
  }

  Future<int> passwordReset(String email) async {
    try{
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return 1;
    }on PlatformException catch(_){

      if(_.code == 'ERROR_USER_NOT_FOUND'){
        //debugPrint(_.code);
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
