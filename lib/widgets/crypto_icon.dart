import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/currency_service.dart';

class CryptoIcon extends StatelessWidget {
  final String symbol;
  final double size;
  final Color? backgroundColor;

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

  const CryptoIcon({
    Key? key,
    required this.symbol,
    this.size = 48,
    this.backgroundColor,
  }) : super(key: key);

  Widget _buildIcon() {
    final isCrypto = CurrencyService.cryptoCurrencies.contains(symbol);
    
    if (isCrypto) {
      return Container(
        width: size,
        height: size,
        child: SvgPicture.asset(
          'assets/crypto_icons/${symbol.toLowerCase()}.svg',
          placeholderBuilder: (context) => Center(
            child: Text(
              symbol[0],
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              symbol[0],
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            fiatFlags[symbol] ?? symbol[0],
            style: TextStyle(fontSize: size * 0.8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: CurrencyService.cryptoCurrencies.contains(symbol) 
          ? (backgroundColor ?? Colors.orange) 
          : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: _buildIcon(),
    );
  }
} 