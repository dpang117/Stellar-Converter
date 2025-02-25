import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/currency_service.dart';
import '../screens/currency_detail.dart';

class CurrencyCard extends StatelessWidget {
  final String name;
  final String symbol;
  final String price;
  final String change;
  final String iconUrl;
  final bool isPositive;
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
    required this.change,
    required this.iconUrl,
    required this.isPositive,
    this.chartData = const [],
    this.onRemove,
  }) : super(key: key);

  Widget _buildIcon() {
    final isCrypto = CurrencyService.cryptoCurrencies.contains(symbol);
    
    if (isCrypto) {
      return Container(
        width: 40,
        height: 40,
        child: SvgPicture.asset(
          'assets/crypto_icons/${symbol.toLowerCase()}.svg',
          placeholderBuilder: (context) => Center(
            child: Text(
              symbol[0],
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              symbol[0],
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            fiatFlags[symbol] ?? symbol[0],
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCrypto = CurrencyService.cryptoCurrencies.contains(symbol);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCrypto ? const Color(0xFF0156FE) : Colors.black,  // Blue for crypto, black for fiat
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Currency Icon
          Container(
            margin: EdgeInsets.only(right: 12),
            child: _buildIcon(),
          ),

          // Currency Details and Mini Chart
          Expanded(
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
                      lineColor: isPositive ? Colors.green[300]! : Colors.red[300]!,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 16),

          // Price and Change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? Colors.green[300] : Colors.red[300],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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