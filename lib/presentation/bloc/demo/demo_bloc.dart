import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../data/models/demo_order_model.dart';
import 'demo_event.dart';
import 'demo_state.dart';

class DemoBloc extends Bloc<DemoEvent, DemoState> {
  DemoBloc() : super(const DemoState()) {
    on<ActivateDemoMode>(_onActivate);
    on<LoadDemoWallet>(_onLoadWallet);
    on<LoadDemoOrders>(_onLoadOrders);
    on<LoadDemoPortfolio>(_onLoadPortfolio);
    on<PlaceDemoOrder>(_onPlaceOrder);
    on<PurchaseCoinPack>(_onPurchaseCoins);
    on<CancelDemoOrder>(_onCancelOrder);
    on<ResetDemoAccount>(_onResetDemo);
    on<ClearDemoMessage>((_, emit) => emit(state.copyWith(
      actionMessage: '',
      actionSuccess: false,
      isActionLoading: false,
      showWelcomeDialog: false,
    )));
  }

  // ── POST /demo/activate ────────────────────────────────────────────────────
  Future<void> _onActivate(ActivateDemoMode event, Emitter<DemoState> emit) async {
    try {
      final r = await ApiHelper.post(ApiEndpoints.demoActivateApi, {});
      if (r != null && r['status'] == true) {
        final d              = r['data'] as Map<String, dynamic>;
        final isFirstTime    = d['isFirstTime'] == true;
        final available      = double.tryParse(d['availableCoins']?.toString()    ?? '0') ?? 0;
        final totalGranted   = double.tryParse(d['totalGrantedCoins']?.toString() ?? '0') ?? 0;
        final packPrice      = double.tryParse(d['coinPackPrice']?.toString()     ?? '100') ?? 100;
        final packCoins      = int.tryParse(d['coinPackCoins']?.toString()        ?? '100000') ?? 100000;

        emit(state.copyWith(
          availableCoins:    available,
          totalGrantedCoins: totalGranted,
          coinPackPrice:     packPrice,
          coinPackCoins:     packCoins,
          showWelcomeDialog: isFirstTime,
        ));

        // Load orders & portfolio in background
        add(const LoadDemoOrders());
        add(const LoadDemoPortfolio());
      }
    } catch (_) {}
  }

  // ── GET /demo/wallet ───────────────────────────────────────────────────────
  Future<void> _onLoadWallet(LoadDemoWallet event, Emitter<DemoState> emit) async {
    try {
      final r = await ApiHelper.get(ApiEndpoints.demoWalletApi);
      if (r != null && r['status'] == true) {
        final d = r['data'] as Map<String, dynamic>;
        emit(state.copyWith(
          availableCoins:    double.tryParse(d['availableCoins']?.toString()    ?? '0') ?? 0,
          totalGrantedCoins: double.tryParse(d['totalGrantedCoins']?.toString() ?? '0') ?? 0,
          coinPackPrice:     double.tryParse(d['coinPackPrice']?.toString()     ?? '100') ?? 100,
          coinPackCoins:     int.tryParse(d['coinPackCoins']?.toString()        ?? '100000') ?? 100000,
        ));
      }
    } catch (_) {}
  }

  // ── GET /demo/orders ───────────────────────────────────────────────────────
  Future<void> _onLoadOrders(LoadDemoOrders event, Emitter<DemoState> emit) async {
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      final r = await ApiHelper.get(ApiEndpoints.demoOrdersApi);
      if (r != null && r['status'] == true) {
        final list = (r['data'] as List? ?? [])
            .map((e) => DemoOrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
        emit(state.copyWith(isLoading: false, orders: list));
      } else {
        emit(state.copyWith(isLoading: false, error: r?['message'] ?? 'Failed'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // ── GET /demo/portfolio ────────────────────────────────────────────────────
  Future<void> _onLoadPortfolio(LoadDemoPortfolio event, Emitter<DemoState> emit) async {
    try {
      final r = await ApiHelper.get(ApiEndpoints.demoPortfolioApi);
      if (r != null && r['status'] == true) {
        // Response is now { positions, realizedPnl, closedToday }
        final data = r['data'] as Map<String, dynamic>? ?? {};

        final positions = (data['positions'] as List? ?? [])
            .map((e) => DemoPositionModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final realizedPnl = double.tryParse(
            data['realizedPnl']?.toString() ?? '0') ?? 0.0;

        final closedToday = (data['closedToday'] as List? ?? [])
            .map((e) => DemoClosedPositionModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final closedAllTime = (data['closedAllTime'] as List? ?? [])
            .map((e) => DemoClosedPositionModel.fromJson(e as Map<String, dynamic>))
            .toList();

        emit(state.copyWith(
          portfolio:    positions,
          realizedPnl:  realizedPnl,
          closedToday:  closedToday,
          closedAllTime: closedAllTime,
        ));
      }
    } catch (_) {}
  }

  // ── POST /demo/order ───────────────────────────────────────────────────────
  Future<void> _onPlaceOrder(PlaceDemoOrder event, Emitter<DemoState> emit) async {
    emit(state.copyWith(isActionLoading: true, actionMessage: ''));
    try {
      final body = {
        'securityId':      event.securityId,
        'tradingSymbol':   event.tradingSymbol,
        'exchangeSegment': event.exchangeSegment,
        'transactionType': event.transactionType,
        'orderType':       event.orderType,
        'productType':     event.productType,
        'quantity':        event.quantity,
        'price':           event.price,
      };
      if (event.targetPrice > 0)   body['targetPrice']   = event.targetPrice;
      if (event.stopLossPrice > 0) body['stopLossPrice'] = event.stopLossPrice;
      if (event.trailingJump > 0)  body['trailingJump']  = event.trailingJump;

      final r = await ApiHelper.post(ApiEndpoints.demoOrderApi, body);
      if (r != null && r['status'] == true) {
        final newCoins = double.tryParse(
            r['data']?['availableCoins']?.toString() ?? '') ?? state.availableCoins;
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess:   true,
          actionMessage:   r['message'] ?? 'Order placed',
          availableCoins:  newCoins,
        ));
        add(const LoadDemoOrders());
        add(const LoadDemoPortfolio());
      } else {
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess:   false,
          actionMessage:   r?['message'] ?? 'Failed to place order',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        actionSuccess:   false,
        actionMessage:   e.toString(),
      ));
    }
  }

  // ── POST /demo/purchase-coins ──────────────────────────────────────────────
  Future<void> _onPurchaseCoins(PurchaseCoinPack event, Emitter<DemoState> emit) async {
    emit(state.copyWith(isActionLoading: true, actionMessage: ''));
    try {
      final r = await ApiHelper.post(ApiEndpoints.demoPurchaseApi, {});
      if (r != null && r['status'] == true) {
        final newCoins = double.tryParse(
            r['data']?['availableCoins']?.toString() ?? '') ?? state.availableCoins;
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess:   true,
          actionMessage:   r['message'] ?? 'Coins added',
          availableCoins:  newCoins,
          totalGrantedCoins: state.totalGrantedCoins + state.coinPackCoins,
        ));
      } else {
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess:   false,
          actionMessage:   r?['message'] ?? 'Purchase failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        actionSuccess:   false,
        actionMessage:   e.toString(),
      ));
    }
  }

  // ── DELETE /demo/order/:id ─────────────────────────────────────────────────
  Future<void> _onCancelOrder(CancelDemoOrder event, Emitter<DemoState> emit) async {
    emit(state.copyWith(isActionLoading: true, actionMessage: ''));
    try {
      final r = await ApiHelper.delete('${ApiEndpoints.demoOrderApi}/${event.orderId}');
      if (r != null && r['status'] == true) {
        final newCoins = double.tryParse(
            r['data']?['availableCoins']?.toString() ?? '') ?? state.availableCoins;
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess:   true,
          actionMessage:   'Demo order cancelled',
          availableCoins:  newCoins,
        ));
        add(const LoadDemoOrders());
        add(const LoadDemoPortfolio());
        add(const LoadDemoWallet());
      } else {
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess:   false,
          actionMessage:   r?['message'] ?? 'Failed to cancel',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        actionSuccess:   false,
        actionMessage:   e.toString(),
      ));
    }
  }

  // ── POST /demo/reset ───────────────────────────────────────────────────────
  Future<void> _onResetDemo(ResetDemoAccount event, Emitter<DemoState> emit) async {
    emit(state.copyWith(isActionLoading: true, actionMessage: ''));
    try {
      final r = await ApiHelper.post(ApiEndpoints.demoResetApi, {});
      if (r != null && r['status'] == true) {
        final newCoins = double.tryParse(
            r['data']?['availableCoins']?.toString() ?? '') ?? state.totalGrantedCoins;
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess:   true,
          actionMessage:   r['message'] ?? 'Demo account reset',
          orders:          [],
          portfolio:       [],
          realizedPnl:     0,
          closedToday:     [],
          availableCoins:  newCoins,
        ));
      } else {
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess:   false,
          actionMessage:   r?['message'] ?? 'Reset failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        actionSuccess:   false,
        actionMessage:   e.toString(),
      ));
    }
  }
}
