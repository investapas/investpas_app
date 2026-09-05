import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../data/models/order_model.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final SharedPrefsHelper _prefs = SharedPrefsHelper();

  OrderBloc() : super(const OrderState()) {
    on<LoadOrders>(_onLoadOrders);
    on<LoadSuperOrders>(_onLoadSuperOrders);
    on<ChangeOrderTab>((event, emit) => emit(state.copyWith(activeTab: event.tab)));
    on<CancelOrderLeg>(_onCancelOrderLeg);
    on<CancelOrder>(_onCancelOrder);
    on<ModifySuperOrder>(_onModifySuperOrder);
    on<ModifyOrder>(_onModifyOrder);
    on<RefreshSingleOrder>(_onRefreshSingleOrder);
    on<ClearActionMessage>((event, emit) => emit(state.copyWith(
      actionMessage: '',
      actionSuccess: false,
      isActionLoading: false,
      clearRefreshedOrder: true,
    )));
  }

  // GET /dhan/orders
  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      final accessToken = await _prefs.getAccessToken() ?? '';
      final response = await ApiHelper.get(
        ApiEndpoints.ordersApi,
        body: {"mode": "REAL", "dhanAccessToken": accessToken},
      );
      if (response != null && response["status"] == true) {
        final List data = response["data"] ?? [];
        final orders = data
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
        emit(state.copyWith(isLoading: false, allOrders: orders));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: response?["message"] ?? "Failed to load orders",
        ));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // GET /dhan/super-orders
  Future<void> _onLoadSuperOrders(LoadSuperOrders event, Emitter<OrderState> emit) async {
    try {
      final accessToken = await _prefs.getAccessToken() ?? '';
      final response = await ApiHelper.get(
        ApiEndpoints.superOrdersApi,
        body: {"dhanAccessToken": accessToken},
      );
      if (response == null) return;

      List rawData = [];

      if (response is List) {
        // Server returned a raw array directly
        rawData = response;
      } else if (response is Map && response["status"] == true) {
        rawData = response["data"] ?? [];
      }

      final superOrders = rawData
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>, isSuperOrder: true))
          .toList();
      emit(state.copyWith(superOrders: superOrders));
    } catch (_) {}
  }

  // DELETE /dhan/super-orders/:orderId/:legName
  Future<void> _onCancelOrderLeg(CancelOrderLeg event, Emitter<OrderState> emit) async {
    emit(state.copyWith(isActionLoading: true, actionMessage: ''));
    try {
      final accessToken = await _prefs.getAccessToken() ?? '';
      final response = await ApiHelper.delete(
        "${ApiEndpoints.superOrdersApi}/${event.orderId}/${event.orderLeg}",
        body: {"dhanAccessToken": accessToken},
      );
      if (response != null && response["status"] == true) {
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess: true,
          actionMessage: "Order leg cancelled successfully",
        ));
        _reloadAll();
        add(RefreshSingleOrder(orderId: event.orderId, isSuperOrder: true));
      } else {
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess: false,
          actionMessage: response?["message"] ?? "Failed to cancel order leg",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        actionSuccess: false,
        actionMessage: e.toString(),
      ));
    }
  }

  // DELETE /dhan/order/:orderId
  Future<void> _onCancelOrder(CancelOrder event, Emitter<OrderState> emit) async {
    emit(state.copyWith(isActionLoading: true, actionMessage: ''));
    try {
      final accessToken = await _prefs.getAccessToken() ?? '';
      final response = await ApiHelper.delete(
        "${ApiEndpoints.orderApi}/${event.orderId}",
        body: {"mode": "REAL", "dhanAccessToken": accessToken},
      );
      if (response != null && response["status"] == true) {
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess: true,
          actionMessage: "Order cancelled successfully",
        ));
        _reloadAll();
        add(RefreshSingleOrder(orderId: event.orderId, isSuperOrder: false));
      } else {
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess: false,
          actionMessage: response?["message"] ?? "Failed to cancel order",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        actionSuccess: false,
        actionMessage: e.toString(),
      ));
    }
  }

  // PUT /dhan/super-orders/:orderId
  Future<void> _onModifySuperOrder(ModifySuperOrder event, Emitter<OrderState> emit) async {
    emit(state.copyWith(isActionLoading: true, actionMessage: ''));
    try {
      final accessToken = await _prefs.getAccessToken() ?? '';
      final payload = {...event.payload, "dhanAccessToken": accessToken};
      final response = await ApiHelper.put(
        "${ApiEndpoints.superOrdersApi}/${event.orderId}",
        payload,
      );
      if (response != null && response["status"] == true) {
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess: true,
          actionMessage: "Order modified successfully",
        ));
        _reloadAll();
        add(RefreshSingleOrder(orderId: event.orderId, isSuperOrder: true));
      } else {
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess: false,
          actionMessage: response?["message"] ?? "Failed to modify order",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        actionSuccess: false,
        actionMessage: e.toString(),
      ));
    }
  }

  // PUT /dhan/order/:orderId
  Future<void> _onModifyOrder(ModifyOrder event, Emitter<OrderState> emit) async {
    emit(state.copyWith(isActionLoading: true, actionMessage: ''));
    try {
      final accessToken = await _prefs.getAccessToken() ?? '';
      final payload = {
        ...event.payload,
        "mode": "REAL",
        "dhanAccessToken": accessToken,
      };
      final response = await ApiHelper.put(
        "${ApiEndpoints.orderApi}/${event.orderId}",
        payload,
      );
      if (response != null && response["status"] == true) {
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess: true,
          actionMessage: "Order modified successfully",
        ));
        _reloadAll();
        add(RefreshSingleOrder(orderId: event.orderId, isSuperOrder: false));
      } else {
        emit(state.copyWith(
          isActionLoading: false,
          actionSuccess: false,
          actionMessage: response?["message"] ?? "Failed to modify order",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        actionSuccess: false,
        actionMessage: e.toString(),
      ));
    }
  }

  // GET /dhan/order/:orderId — fetch latest order data and store in refreshedOrder
  Future<void> _onRefreshSingleOrder(
      RefreshSingleOrder event, Emitter<OrderState> emit) async {
    try {
      final accessToken = await _prefs.getAccessToken() ?? '';
      final response = await ApiHelper.get(
        "${ApiEndpoints.orderApi}/${event.orderId}",
        body: {"mode": "REAL", "dhanAccessToken": accessToken},
      );
      if (response != null && response["status"] == true && response["data"] != null) {
        final updated = OrderModel.fromJson(
          response["data"] as Map<String, dynamic>,
          isSuperOrder: event.isSuperOrder,
        );
        emit(state.copyWith(refreshedOrder: updated));
      }
    } catch (_) {
      // Silently ignore — best-effort refresh
    }
  }

  // Reload both order lists after any successful action
  void _reloadAll() {
    add(const LoadOrders());
    add(const LoadSuperOrders());
  }
}
