import 'package:equatable/equatable.dart';
import '../../../data/models/order_model.dart';

enum OrderTab { open, executed }

class OrderState extends Equatable {
  final bool isLoading;
  final List<OrderModel> allOrders;
  final List<OrderModel> superOrders;
  final OrderTab activeTab;
  final String error;
  final bool isActionLoading;
  final String actionMessage;
  final bool actionSuccess;
  /// Fresh order data fetched immediately after a modify/cancel action
  final OrderModel? refreshedOrder;

  const OrderState({
    this.isLoading = false,
    this.allOrders = const [],
    this.superOrders = const [],
    this.activeTab = OrderTab.open,
    this.error = '',
    this.isActionLoading = false,
    this.actionMessage = '',
    this.actionSuccess = false,
    this.refreshedOrder,
  });

  List<OrderModel> get _combined {
    final superIds = superOrders.map((o) => o.orderId).toSet();
    final uniqueAllOrders = allOrders.where((o) => !superIds.contains(o.orderId)).toList();
    return [...superOrders, ...uniqueAllOrders];
  }

  List<OrderModel> get openOrders =>
      _combined.where((o) => o.isOpen).toList();

  List<OrderModel> get executedOrders =>
      _combined.where((o) => o.isExecuted).toList();

  List<OrderModel> get currentOrders =>
      activeTab == OrderTab.open ? openOrders : executedOrders;

  OrderState copyWith({
    bool? isLoading,
    List<OrderModel>? allOrders,
    List<OrderModel>? superOrders,
    OrderTab? activeTab,
    String? error,
    bool? isActionLoading,
    String? actionMessage,
    bool? actionSuccess,
    OrderModel? refreshedOrder,
    bool clearRefreshedOrder = false,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      allOrders: allOrders ?? this.allOrders,
      superOrders: superOrders ?? this.superOrders,
      activeTab: activeTab ?? this.activeTab,
      error: error ?? this.error,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      actionMessage: actionMessage ?? this.actionMessage,
      actionSuccess: actionSuccess ?? this.actionSuccess,
      refreshedOrder: clearRefreshedOrder ? null : (refreshedOrder ?? this.refreshedOrder),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        allOrders,
        superOrders,
        activeTab,
        error,
        isActionLoading,
        actionMessage,
        actionSuccess,
        refreshedOrder,
      ];
}
