class CurrencyConversion {
  final String code;
  final String name;
  final String symbol;
  final String rate;
  final String amount;

  CurrencyConversion({
    required this.code,
    required this.name,
    required this.symbol,
    required this.rate,
    required this.amount,
  });

  factory CurrencyConversion.fromJson(Map<String, dynamic> json) {
    return CurrencyConversion(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      rate: json['rate'] ?? '',
      amount: json['amount'] ?? '',
    );
  }
} 