import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/currency_service.dart';

class CurrencyIcon extends StatelessWidget {
  final String symbol;
  final double size;

  const CurrencyIcon({
    Key? key,
    required this.symbol,
    this.size = 40,
  }) : super(key: key);

  String _getCountryCode(String symbol) {
    final currencyToCountry = {
      'USD': 'us',
      'EUR': 'eu',
      'GBP': 'gb',
      'JPY': 'jp',
      'CAD': 'ca',
      'AUD': 'au',
      'CHF': 'ch',
      'CNY': 'cn',
      'HKD': 'hk',
      'NZD': 'nz',
      'SGD': 'sg',
      'ZAR': 'za',
      'INR': 'in',
      'BRL': 'br',
      'RUB': 'ru',
      'AED': 'ae',
      'TWD': 'tw',
      'KRW': 'kr',
      'MXN': 'mx',
      'SAR': 'sa',
      'PLN': 'pl',
      'DKK': 'dk',
      'SEK': 'se',
      'NOK': 'no',
      'THB': 'th',
      'ILS': 'il',
      'QAR': 'qa',
      'KWD': 'kw',
      'PHP': 'ph',
      'TRY': 'tr',
      'CZK': 'cz',
      'IDR': 'id',
      'MYR': 'my',
      'HUF': 'hu',
      'VND': 'vn',
      'ISK': 'is',
      'RON': 'ro',
      'HRK': 'hr',
      'BGN': 'bg',
      'UAH': 'ua',
      'UYU': 'uy',
      'ARS': 'ar',
      'COP': 'co',
      'CLP': 'cl',
      'PEN': 'pe',
      'MAD': 'ma',
      'NGN': 'ng',
      'KES': 'ke',
      'DZD': 'dz',
      'EGP': 'eg',
      'BDT': 'bd',
      'PKR': 'pk',
      'VEF': 've',
      'IRR': 'ir',
      'JOD': 'jo',
      'NPR': 'np',
      'LKR': 'lk',
      'OMR': 'om',
      'MMK': 'mm',
      'BHD': 'bh',
    };
    
    return currencyToCountry[symbol] ?? 'unknown';
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Text(
        symbol[0],
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCrypto = CurrencyService.cryptoCurrencies.contains(symbol);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCrypto ? Colors.transparent : Colors.white24,
      ),
      child: ClipOval(
        child: isCrypto 
          ? SvgPicture.asset(
              'assets/crypto_icons/${symbol.toLowerCase()}.svg',
              placeholderBuilder: (context) => _buildFallbackIcon(),
              errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
            )
          : Image.network(
              'https://flagcdn.com/w80/${_getCountryCode(symbol).toLowerCase()}.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
            ),
      ),
    );
  }
} 