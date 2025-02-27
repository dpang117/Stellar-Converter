import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/currency_service.dart';
import '../screens/currency_detail.dart';
import '../widgets/currency_icon.dart';

class CurrencyCard extends StatelessWidget {
  final String name;
  final String symbol;
  final dynamic price;
  final String iconUrl;
  final List<double> chartData;
  final VoidCallback? onRemove;

  // Map of fiat currency codes to their flag emojis
  static const Map<String, String> fiatFlags = {
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'GBP': '🇬🇧',
    'JPY': '🇯🇵',
    'CAD': '🇨🇦',
    'AUD': '🇦🇺',
    'CHF': '🇨🇭',
    'CNY': '🇨🇳',
    'HKD': '🇭🇰',
    'NZD': '🇳🇿',
    'SGD': '🇸🇬',
    'ZAR': '🇿🇦',
    'INR': '🇮🇳',
    'BRL': '🇧🇷',
    'RUB': '🇷🇺',
    'AED': '🇦🇪',
    'TWD': '🇹🇼',
    'KRW': '🇰🇷',
    'MXN': '🇲🇽',
    'SAR': '🇸🇦',
    'PLN': '🇵🇱',
    'DKK': '🇩🇰',
    'SEK': '🇸🇪',
    'NOK': '🇳🇴',
    'THB': '🇹🇭',
    'ILS': '🇮🇱',
    'QAR': '🇶🇦',
    'KWD': '🇰🇼',
    'PHP': '🇵🇭',
    'TRY': '🇹🇷',
    'CZK': '🇨🇿',
    'IDR': '🇮🇩',
    'MYR': '🇲🇾',
    'HUF': '🇭🇺',
    'VND': '🇻🇳',
    'ISK': '🇮🇸',
    'RON': '🇷🇴',
    'HRK': '🇭🇷',
    'BGN': '🇧🇬',
    'UAH': '🇺🇦',
    'UYU': '🇺🇾',
    'ARS': '🇦🇷',
    'COP': '🇨🇴',
    'CLP': '🇨🇱',
    'PEN': '🇵🇪',
    'MAD': '🇲🇦',
    'NGN': '🇳🇬',
    'KES': '🇰🇪',
    'DZD': '🇩🇿',
    'EGP': '🇪🇬',
    'BDT': '🇧🇩',
    'PKR': '🇵🇰',
    'VEF': '🇻🇪',
    'IRR': '🇮🇷',
    'JOD': '🇯🇴',
    'NPR': '🇳🇵',
    'LKR': '🇱🇰',
    'OMR': '🇴🇲',
    'MMK': '🇲🇲',
    'BHD': '🇧🇭',
  };

  const CurrencyCard({
    Key? key,
    required this.name,
    required this.symbol,
    required this.price,
    required this.iconUrl,
    this.chartData = const [],
    this.onRemove,
  }) : super(key: key);

  String _formatPrice() {
    if (price == null) return "N/A";
    
    double numericPrice;
    try {
      numericPrice = price is double ? price : double.parse(price.toString());
    } catch (e) {
      return price.toString();
    }

    // Format based on size of number
    if (numericPrice >= 1000000) {
      return numericPrice.toStringAsFixed(0);  // No decimals for very large numbers
    } else if (numericPrice >= 1) {
      return numericPrice.toStringAsFixed(2);  // 2 decimals for normal numbers
    } else if (numericPrice >= 0.0001) {
      return numericPrice.toStringAsFixed(6);  // 6 decimals for small numbers
    } else {
      return numericPrice.toStringAsExponential(2); // Scientific notation for very small numbers
    }
  }

  Widget _buildIcon() {
    return CurrencyIcon(symbol: symbol);
  }

  @override
  Widget build(BuildContext context) {
    final isCrypto = CurrencyService.cryptoCurrencies.contains(symbol);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCrypto ? const Color(0xFF0156FE) : Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 12),
            child: _buildIcon(),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  height: 20,
                  width: double.infinity,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: ChartPainter(
                      data: chartData,
                      lineColor: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Text(
            _formatPrice(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  ChartPainter({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Line paint
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw chart line
    final path = Path();
    final max = data.reduce((a, b) => a > b ? a : b);
    final min = data.reduce((a, b) => a < b ? a : b);
    final range = max - min;
    final xStep = size.width / (data.length - 1);

    path.moveTo(0, size.height * (1 - (data[0] - min) / range));

    for (int i = 1; i < data.length; i++) {
      final x = xStep * i;
      final y = size.height * (1 - (data[i] - min) / range);
      
      if (i < data.length - 1) {
        final nextX = xStep * (i + 1);
        final nextY = size.height * (1 - (data[i + 1] - min) / range);
        
        // Use less aggressive smoothing
        final controlX = x + (nextX - x) * 0.25;
        final controlY = y;
        
        path.quadraticBezierTo(controlX, controlY, nextX, nextY);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Add gradient fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withOpacity(0.2),
          lineColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) =>
      data != oldDelegate.data || lineColor != oldDelegate.lineColor;
} 