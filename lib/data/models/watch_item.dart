class WatchItem {
  final String name;
  final String exchange;
  final String price;
  final String changePercent;
  final bool isUp;
  final List<double> chart;

  WatchItem({
    required this.name,
    required this.exchange,
    required this.price,
    required this.changePercent,
    required this.isUp,
    required this.chart,
  });
}