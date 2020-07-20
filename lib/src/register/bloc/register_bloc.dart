import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/register/register.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserRepository _userRepository;

  RegisterBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  RegisterState get initialState => RegisterState.empty();

/*  @override
  Stream<Transition<RegisterEvent, RegisterState>> transformEvents(
    Stream<RegisterEvent> events,
    TransitionFunction<RegisterEvent, RegisterState> transitionFn,
  ) {
    final nonDebounceStream = events.where((event) {
      return (event is! EmailChanged &&
          event is! PasswordChanged &&
          event is! NameChanged &&
          event is! TelephoneChanged &&
          event is! ConfirmPasswordChanged &&
          event is! AgreedChanged);
    });
    final debounceStream = events.where((event) {
      return (event is EmailChanged ||
          event is PasswordChanged ||
          event is NameChanged ||
          event is TelephoneChanged ||
          event is ConfirmPasswordChanged ||
          event is AgreedChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith([debounceStream]),
      transitionFn,
    );
  }*/

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is ConfirmPasswordChanged) {
      yield* _mapConfirmPasswordChangedToState(event.confirmpassword);
    } else if (event is AgreedChanged) {
      yield* _mapAgreedChangedToState(event.agreed);
    } else if (event is NameChanged) {
      yield* _mapNameChangedToState(event.name);
    } else if (event is TelephoneChanged) {
      yield* _mapTelephoneChangedToState(event.telephone);
    } else if (event is CountryCodeChanged) {
      yield* _mapCountryCodeChangedToState(event.country);
    } else if (event is Submitted) {
      yield* _mapFormSubmittedToState(event.email, event.password, event.name,
          event.telephone, event.referral);
    }
  }

  Stream<RegisterState> _mapCountryCodeChangedToState(String country) async* {
    yield state.update(code: country);
  }

  Stream<RegisterState> _mapAgreedChangedToState(bool agreed) async* {
    yield state.update(isAgreedValid: agreed);
  }

  Stream<RegisterState> _mapEmailChangedToState(String email) async* {
    bool isEmailValid = Validators.isValidEmail(email);
    if (isEmailValid) {
      bool isNew = await UserRepo().isNew(email);
      yield state.update(
        isEmailValid: Validators.isValidEmail(email),
        isNewUser: isNew,
      );
    } else {
      yield state.update(
        isEmailValid: Validators.isValidEmail(email),
        isNewUser: true,
      );
    }
  }

  Stream<RegisterState> _mapConfirmPasswordChangedToState(
      String password) async* {
    yield state.update(
      isConfirmPasswordValid:
          Validators.isValidConfirmPassword(password, state.password),
    );
  }

  Stream<RegisterState> _mapPasswordChangedToState(String password) async* {
    yield state.update(
      isPasswordValid: Validators.isValidPassword(password),
      password: password,
    );
  }

  Stream<RegisterState> _mapNameChangedToState(String name) async* {
    yield state.update(
      isNameValid: Validators.isValidName(name),
    );
  }

  Stream<RegisterState> _mapTelephoneChangedToState(String telephone) async* {
    yield state.update(
      isTelephoneValid:
          Validators.isValidTelephone(telephone, ccode: state.code),
    );
  }

  Stream<RegisterState> _mapFormSubmittedToState(
    String email,
    String password,
    String name,
    String telephone,
    String referral,
  ) async* {
    yield RegisterState.loading(code: state.code);
    try {
      var wID = await makeWallet(name, email, telephone, referral,password);
      if (wID.isNotEmpty) {
        var uid = await _userRepository.signUp(role: 'user', email: email, password: password,);
        if(uid != null){
          User user = User(
            uid,
            fname: name,
            email: email,
            telephone: state.code + (telephone.substring(1)),
            bid: Firestore.instance.document('merchants/null'),
            behaviour: Firestore.instance.document('userBehaviour/null'),
            profile: PocketShoppingDefaultAvatar,
            role: "user",
            defaultAddress: '',
            country: 'NG',//await Utility.getCountryCode(),
            walletId: wID,
          );
          await UserRepo().save(user);
          SharedPreferences prefs= await SharedPreferences.getInstance();
          if(!prefs.containsKey('uid'))prefs.setString('uid', 'loggedInBefore');
          yield RegisterState.success();
        }
        else RegisterState.failure(code: state.code);}
      else {yield RegisterState.failure(code: state.code);}
    } catch (_) {yield RegisterState.failure(code: state.code);}
  }

  Future<String> makeWallet(
      String name, String email, String telephone, String refferal,String password) async {
    try{
      final response = await http.post("${WALLETAPI}Users/register",
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(
            <String, dynamic>{
              "email": "$email",
              "name": "$name",
              "password": "$password",
              "typeId": 2,
              //"Refferal": "$refferal",
            },
          ));
      if(response != null){
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          return result['walletID'].toString();
        } else {
          return '';
        }
      }
      else{
        return '';
      }
    }
    catch(_){
      return '';
    }
  }
}
