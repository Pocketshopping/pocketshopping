import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/register/register.dart';
import 'package:pocketshopping/src/validators.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserRepository _userRepository;

  RegisterBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  RegisterState get initialState => RegisterState.empty();

  @override
  Stream<Transition<RegisterEvent, RegisterState>> transformEvents(
    Stream<RegisterEvent> events,
    TransitionFunction<RegisterEvent, RegisterState> transitionFn,
  ) {
    final nonDebounceStream = events.where((event) {
      return (event is! EmailChanged && event is! PasswordChanged && event is!
      NameChanged && event is! TelephoneChanged && event is! ConfirmPasswordChanged
          && event is! AgreedChanged);
    });
    final debounceStream = events.where((event) {
      return (event is EmailChanged || event is PasswordChanged || event is NameChanged ||event is TelephoneChanged || event is ConfirmPasswordChanged
          || event is AgreedChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith([debounceStream]),
      transitionFn,
    );
  }

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    }else if (event is ConfirmPasswordChanged) {
      yield* _mapConfirmPasswordChangedToState(event.confirmpassword);
    }
    else if (event is AgreedChanged) {
      yield* _mapAgreedChangedToState(event.agreed);
    }
    else if (event is NameChanged) {
      yield* _mapNameChangedToState(event.name);
    }else if (event is TelephoneChanged) {
      yield* _mapTelephoneChangedToState(event.telephone);
    }
    else if (event is CountryCodeChanged) {
      yield* _mapCountryCodeChangedToState(event.country);
    }
    else if (event is Submitted) {
      yield* _mapFormSubmittedToState(
          event.email,
          event.password,
        event.name,
        event.telephone
      );
    }
  }

  Stream<RegisterState> _mapCountryCodeChangedToState(String country) async* {
    yield state.update(
        code: country
    );
  }

  Stream<RegisterState> _mapAgreedChangedToState(bool agreed) async* {
    yield state.update(
      isAgreedValid: agreed
    );
  }

  Stream<RegisterState> _mapEmailChangedToState(String email) async* {
    bool isEmailValid = Validators.isValidEmail(email);
    if(isEmailValid){
      bool isNew = await UserRepo().IsNew(email);
      yield state.update(
        isEmailValid: Validators.isValidEmail(email),
        isNewUser: isNew,
      );
    }
    else{
      yield state.update(
        isEmailValid: Validators.isValidEmail(email),
        isNewUser:true,
      );
    }

  }

  Stream<RegisterState> _mapConfirmPasswordChangedToState(String password) async* {
    yield state.update(
      isConfirmPasswordValid: Validators.isValidConfirmPassword(password,state.password),
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
      isTelephoneValid: Validators.isValidTelephone(telephone,ccode: state.code),
    );
  }

  Stream<RegisterState> _mapFormSubmittedToState(
    String email,
    String password,
    String name,
    String telephone,
  ) async* {
    yield RegisterState.loading(code: state.code);
    try {

      var uid = await _userRepository.signUp(
        role:'user',
        email: email,
        password: password,
      );
      User user =User(uid,
          fname: name,
        email: email,
        telephone: state.code+(telephone.substring(1)),
        bid: Firestore.instance.document('merchants/null'),
        behaviour: Firestore.instance.document('userBehaviour/null'),
        profile: "",
        role: "user",
        defaultAddress: '',
        country: await Devicelocale.currentLocale
      );
      await UserRepo().save(user);
      yield RegisterState.success();
    } catch (_) {
      print(_.toString());
      yield RegisterState.failure(code: state.code);
    }
  }
}