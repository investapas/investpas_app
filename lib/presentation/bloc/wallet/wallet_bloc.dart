import 'package:flutter_bloc/flutter_bloc.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(const WalletState()) {

    on<LoadWalletBalance>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final resp = await ApiHelper.get(ApiEndpoints.walletBalanceApi);
        if (resp != null && resp['status'] == true) {
          emit(state.copyWith(
            isLoading: false,
            balance: (resp['data']?['balance'] as num?)?.toInt() ?? 0,
          ));
        } else {
          emit(state.copyWith(isLoading: false));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<AddCoins>((event, emit) async {
      emit(state.copyWith(isAdding: true, message: ''));
      try {
        final resp = await ApiHelper.post(ApiEndpoints.walletAddCoinsApi, {'amount': event.amount});
        if (resp != null && resp['status'] == true) {
          final newBalance = (resp['data']?['balance'] as num?)?.toInt() ?? state.balance;
          emit(state.copyWith(isAdding: false, balance: newBalance, message: ''));
        } else {
          emit(state.copyWith(isAdding: false, message: resp?['message'] ?? 'Failed'));
        }
      } catch (e) {
        emit(state.copyWith(isAdding: false, message: e.toString()));
      }
    });

    on<UpdateBalance>((event, emit) {
      emit(state.copyWith(balance: event.balance));
    });
  }
}
