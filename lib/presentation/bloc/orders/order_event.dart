import 'package:equatable/equatable.dart';
import 'order_state.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderEvent {
  const LoadOrders();
}

class LoadSuperOrders extends OrderEvent {
  const LoadSuperOrders();
}

class ChangeOrderTab extends OrderEvent {
  final OrderTab tab;
  const ChangeOrderTab(this.tab);
  @override
  List<Object?> get props => [tab];
}

class CancelOrderLeg extends OrderEvent {
  final String orderId;
  final String orderLeg;
  const CancelOrderLeg({required this.orderId, required this.orderLeg});
  @override
  List<Object?> get props => [orderId, orderLeg];
}

class CancelOrder extends OrderEvent {
  final String orderId;
  const CancelOrder({required this.orderId});
  @override
  List<Object?> get props => [orderId];
}

class ModifySuperOrder extends OrderEvent {
  final String orderId;
  final Map<String, dynamic> payload;

  const ModifySuperOrder({required this.orderId, required this.payload});

  @override
  List<Object?> get props => [orderId, payload];
}

class ModifyOrder extends OrderEvent {
  final String orderId;
  final Map<String, dynamic> payload;

  const ModifyOrder({required this.orderId, required this.payload});

  @override
  List<Object?> get props => [orderId, payload];
}

class ClearActionMessage extends OrderEvent {
  const ClearActionMessage();
}

class ClearActionState extends OrderEvent {
  const ClearActionState();
}

/// Fetch a single order by ID immediately after modify/cancel
/// so the details sheet can show the latest price, SL, status, etc.
class RefreshSingleOrder extends OrderEvent {
  final String orderId;
  final bool isSuperOrder;
  const RefreshSingleOrder({required this.orderId, this.isSuperOrder = false});
  @override
  List<Object?> get props => [orderId, isSuperOrder];
}
