import 'package:rxdart/rxdart.dart';

import '../repository/walletObj.dart';

class WalletBloc {
  WalletBloc._internal();

  static final WalletBloc instance = WalletBloc._internal();

  BehaviorSubject<Wallet> _walletStreamController = BehaviorSubject<Wallet>();

  Stream<Wallet> get walletStream {
    return _walletStreamController;
  }

  void newWallet(Wallet wallet) {
    _walletStreamController.sink.add(wallet);
  }

  void clearWallet() {
    _walletStreamController.sink.add(null);
  }

  void dispose() {
    _walletStreamController?.close();
  }
}
