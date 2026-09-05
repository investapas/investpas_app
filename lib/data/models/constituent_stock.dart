class ConstituentStock {
  final String name;
  final String exchange;
  final String price;
  final String weekLow;
  final String changePercent;
  final String volume;
  final bool isUp;

  const ConstituentStock({
    required this.name,
    required this.exchange,
    required this.price,
    required this.weekLow,
    required this.changePercent,
    required this.volume,
    required this.isUp,
  });
}