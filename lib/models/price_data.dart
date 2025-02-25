class PriceData {
  final String name;
  final String symbol;
  final String price;
  final String change;
  final String iconUrl;
  final List<double> chartData;
  final bool isPositive;

  PriceData({
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
    required this.iconUrl,
    required this.chartData,
    required this.isPositive,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) {
    return PriceData(
      name: json['name'],
      symbol: json['symbol'],
      price: json['price'],
      change: json['change'],
      iconUrl: json['iconUrl'],
      chartData: (json['chartData'] as List).cast<double>(),
      isPositive: !json['change'].toString().startsWith('-'),
    );
  }
} 