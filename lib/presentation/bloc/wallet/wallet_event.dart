import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override List<Object> get props => [];
}

class LoadWalletBalance extends WalletEvent {
  const LoadWalletBalance();
}

class AddCoins extends WalletEvent {
  final int amount;
  const AddCoins(this.amount);
  @override List<Object> get props => [amount];
}

class UpdateBalance extends WalletEvent {
  final int balance;
  const UpdateBalance(this.balance);
  @override List<Object> get props => [balance];
}
