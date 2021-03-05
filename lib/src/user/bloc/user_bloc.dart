import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/user/bloc/user_event.dart';
import 'package:pocketshopping/src/user/bloc/user_state.dart';
import 'package:pocketshopping/src/user/repository/userRepo.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepo _userRepository;
  StreamSubscription _userSubscription;

  UserBloc({@required UserRepo userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  UserState get initialState => UserLoading();

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is LoadUser) {
      yield* _mapLoadUserToState(event);
    } else if (event is AddUser) {
      yield* _mapAddUserToState(event);
    } else if (event is UpdateUser) {
      yield* _mapUpdateUserToState(event);
    } else if (event is DeleteUser) {
      yield* _mapDeleteUserToState(event);
    } else if (event is UserUpdated) {
      yield* _mapUserUpdatedToState(event);
    }
  }

  Stream<UserState> _mapLoadUserToState(LoadUser event) async* {
    _userSubscription?.cancel();
    var user = await _userRepository.getOne(uid: event.uid);
    try {
      add(UserUpdated(user));
    } catch (_) {}
  }

  Stream<UserState> _mapAddUserToState(AddUser event) async* {
    _userRepository.save(event.user);
  }

  Stream<UserState> _mapUpdateUserToState(UpdateUser event) async* {
    //_userRepository.updateUser(event.user);
  }

  Stream<UserState> _mapDeleteUserToState(DeleteUser event) async* {
    //_userRepository.deleteTodo(event.user);
  }

  Stream<UserState> _mapUserUpdatedToState(UserUpdated event) async* {
    yield UserLoaded(event.user);
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
