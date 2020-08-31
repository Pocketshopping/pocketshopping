import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  AuthenticationState get initialState => Started();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    } else if (event is Setup) {
      yield* _mapSetupToState();
    } else if (event is DeepLink) {
      yield* _mapDeepLinkToState(event);
    }else if(event is Verify){
      yield* _mapVerifyAccountToState();
    }
  }

  Stream<AuthenticationState> _mapDeepLinkToState(DeepLink uri) async* {
    SharedPreferences prefs= await SharedPreferences.getInstance();
    yield Started(link: uri.link);
    try {

      final isSignedIn = _userRepository.isSignedIn();
      if (isSignedIn) {
        final user = await _userRepository.getCurrentUser();
        yield DLink(user, uri.link);
      } else {
        if(prefs.containsKey('uid')) yield Unauthenticated(link: uri.link);
        else yield Uninitialized(link: uri.link);
      }
    } catch (_) {
      if(prefs.containsKey('uid')) yield Unauthenticated(link: uri.link);
      else yield Uninitialized(link: uri.link);
    }
  }

  Stream<AuthenticationState> _mapVerifyAccountToState() async* {
    yield VerifyAccount();
  }

  Stream<AuthenticationState> _mapSetupToState() async* {
    final user = await _userRepository.getCurrentUser();
    yield SetupBusiness(user);
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    yield Started();
    SharedPreferences prefs= await SharedPreferences.getInstance();
    try {

      final isSignedIn = _userRepository.isSignedIn();
      if (isSignedIn) {
        final user = await _userRepository.getCurrentUser();
        yield Authenticated(user);
      } else {
        if(prefs.containsKey('uid')) yield Unauthenticated();
        else yield Uninitialized();
      }
    } catch (_) {
      if(prefs.containsKey('uid')) yield Unauthenticated();
      else yield Uninitialized();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {
    yield Authenticated(await _userRepository.getCurrentUser());
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    _userRepository.signOut();
  }

  Future<Uri> handleDynamicLinks() async {
    //print('i am working');
    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(data);
    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
      // 3a. handle link that has been retrieved
      return _handleDeepLink(dynamicLink);
    }, onError: (OnLinkErrorException e) async {
      return null;
    });
    return null;
  }

  Future<Uri> _handleDeepLink(PendingDynamicLinkData data) async {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      //print(deepLink);
      return deepLink;
    } else
      return null;
  }
}
