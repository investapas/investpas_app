class StockNews {
  final String source;
  final String symbol;
  final String title;
  final String time;
  final String description;
  final String url;

  const StockNews({
    required this.source,
    required this.symbol,
    required this.title,
    required this.time,
    this.description = '',
    this.url = '',
  });

  factory StockNews.fromJson(Map<String, dynamic> json) {
    return StockNews(
      source: json['source'] as String? ?? 'Market News',
      symbol: json['symbol'] as String? ?? '',
      title: json['title'] as String? ?? '',
      time: json['time'] as String? ?? '',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}
