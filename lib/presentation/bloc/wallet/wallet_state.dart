import 'package:equatable/equatable.dart';

class WalletState extends Equatable {
  final int balance;
  final bool isLoading;
  final bool isAdding;
  final String message;

  const WalletState({
    this.balance = 0,
    this.isLoading = false,
    this.isAdding = false,
    this.message = '',
  });

  WalletState copyWith({int? balance, bool? isLoading, bool? isAdding, String? message}) =>
      WalletState(
        balance: balance ?? this.balance,
        isLoading: isLoading ?? this.isLoading,
        isAdding: isAdding ?? this.isAdding,
        message: message ?? this.message,
      );

  @override
  List<Object> get props => [balance, isLoading, isAdding, message];
}
