class ChartCandle {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  const ChartCandle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  static List<ChartCandle> fromApiResponse(Map<String, dynamic> data) {
    final timestamps = List<dynamic>.from(data['timestamp'] ?? []);
    final opens      = List<dynamic>.from(data['open']      ?? []);
    final highs      = List<dynamic>.from(data['high']      ?? []);
    final lows       = List<dynamic>.from(data['low']       ?? []);
    final closes     = List<dynamic>.from(data['close']     ?? []);
    final volumes    = List<dynamic>.from(data['volume']    ?? []);

    final result = <ChartCandle>[];
    for (int i = 0; i < timestamps.length; i++) {
      result.add(ChartCandle(
        time:   DateTime.fromMillisecondsSinceEpoch((timestamps[i] as int) * 1000),
        open:   (opens[i]   as num).toDouble(),
        high:   (highs[i]   as num).toDouble(),
        low:    (lows[i]    as num).toDouble(),
        close:  (closes[i]  as num).toDouble(),
        volume: (volumes[i] as num).toInt(),
      ));
    }
    return result;
  }
}
