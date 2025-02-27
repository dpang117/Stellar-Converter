import 'package:flutter/material.dart';
import '../services/currency_service.dart';
import 'dart:math';
import '../widgets/crypto_icon.dart';
import '../widgets/currency_icon.dart';

class CurrencyDetailScreen extends StatefulWidget {
  final String symbol;
  final String name;
  final String initialPrice;
  final List<double> initialChartData;

  const CurrencyDetailScreen({
    Key? key,
    required this.symbol,
    required this.name,
    required this.initialPrice,
    required this.initialChartData,
  }) : super(key: key);

  @override
  _CurrencyDetailScreenState createState() => _CurrencyDetailScreenState();
}

class _CurrencyDetailScreenState extends State<CurrencyDetailScreen> {
  String selectedTimeframe = '1d';
  late List<double> chartData;
  late String currentPrice;
  bool isLoading = false;
  late String defaultCurrency;

  // Add this to track the latest requested timeframe
  String? _pendingTimeframe;

  final List<String> timeframes = ['1d', '1w', '2w', '1m'];

  @override
  void initState() {
    super.initState();
    _loadDefaultCurrency();
    chartData = widget.initialChartData;
    currentPrice = widget.initialPrice;
    _loadChartData(selectedTimeframe);
  }

  Future<void> _loadDefaultCurrency() async {
    final currency = await CurrencyService.getDefaultCurrency();
    setState(() {
      defaultCurrency = currency;
    });
  }

  Future<void> _loadChartData(String timeframe) async {
    if (!mounted) return;

    // Store the requested timeframe
    _pendingTimeframe = timeframe;

    setState(() {
      isLoading = true;
    });

    try {
      final newData =
          await CurrencyService().getHistoricalPrices(widget.symbol, timeframe);

      if (!mounted) return;

      // Only update if this is still the latest requested timeframe
      if (_pendingTimeframe == timeframe) {
        setState(() {
          chartData = newData;
          selectedTimeframe = timeframe;
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      // Only show error if this is still the latest requested timeframe
      if (_pendingTimeframe == timeframe) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load chart data. Please try again later.'),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _selectTimeframe(String timeframe) {
    if (timeframe != selectedTimeframe) {
      setState(() {
        selectedTimeframe = timeframe;
      });
      _loadChartData(timeframe);
    }
  }

  void _handleDelete() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${widget.name}?'),
        content: Text(
            'Are you sure you want to remove this currency from your watchlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      // Pop back to previous screen with delete result
      Navigator.pop(context, {'action': 'delete', 'symbol': widget.symbol});
    }
  }

  // Update chart container to match the design
  Widget _buildChartWithLabels() {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        height: 280,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    // Add this check
    if (chartData.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        height: 280,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No chart data available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Calculate price points for labels based on chart data
    final max = chartData.reduce((a, b) => a > b ? a : b);
    final min = chartData.reduce((a, b) => a < b ? a : b);
    final range = max - min;

    // Format price points based on currency type and value range
    String formatPricePoint(double value) {
      final isFiat = !CurrencyService.cryptoCurrencies.contains(widget.symbol);
      if (isFiat) {
        // For fiat currencies, show more decimal places for small ranges
        if (range < 0.01) {
          return value.toStringAsFixed(6);
        } else if (range < 0.1) {
          return value.toStringAsFixed(4);
        } else if (range < 1) {
          return value.toStringAsFixed(3);
        } else {
          return value.toStringAsFixed(2);
        }
      } else {
        // For crypto, keep existing formatting
        return value.toStringAsFixed(value >= 100
            ? 2
            : value >= 1
                ? 3
                : 4);
      }
    }

    // Calculate 4 evenly spaced price points
    final pricePoints = List.generate(4, (i) {
      final value = max - (range * i / 3);
      return formatPricePoint(value);
    });

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      height: 280,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Price labels column
          Container(
            width: 80, // Increased width to accommodate longer numbers
            padding: EdgeInsets.only(right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: pricePoints
                  .map((price) => Text(
                        price,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Chart area
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: DetailChartPainter(
                data: chartData,
                lineColor: Colors.blue,
                showGrid: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Update timeframe selector text
  String _getTimeframeLabel(String timeframe) {
    switch (timeframe) {
      case '1d':
        return '1D';
      case '1w':
        return '1W';
      case '2w':
        return '2W';
      case '1m':
        return '1M';
      default:
        return timeframe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              widget.name,
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            CurrencyIcon(
              symbol: widget.symbol,
              size: 60,  // Larger size for detail view
            ),
            SizedBox(width: 16),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delete button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _handleDelete,
              icon: Icon(Icons.remove, color: Colors.white),
              label: Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          // Price Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentPrice,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Chart
          _buildChartWithLabels(),

          // Timeframe selector
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: timeframes.map((timeframe) {
                final isSelected = timeframe == selectedTimeframe;
                return GestureDetector(
                  onTap: () => _selectTimeframe(timeframe),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.grey[300] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      _getTimeframeLabel(timeframe),
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey[600],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Cancel any timers or subscriptions here if you have any
    super.dispose();
  }
}

class DetailChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final bool showGrid;

  DetailChartPainter({
    required this.data,
    required this.lineColor,
    required this.showGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Update grid paint color for better visibility on black
    final gridPaint = Paint()
      ..color = Colors.grey[800]! // Darker grey for grid lines
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw multiple horizontal grid lines
    final gridCount = 4;
    for (int i = 1; i < gridCount; i++) {
      final y = size.height * (i / gridCount);
      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(
          Offset(startX, y),
          Offset(startX + 5, y),
          gridPaint,
        );
        startX += 10; // Gap between dashes
      }
    }

    // Draw chart line with less smoothing
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
  bool shouldRepaint(DetailChartPainter oldDelegate) =>
      data != oldDelegate.data ||
      lineColor != oldDelegate.lineColor ||
      showGrid != oldDelegate.showGrid;
}
