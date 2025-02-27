import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/currency_service.dart';
import '../widgets/currency_icon.dart';

class CurrencyListScreen extends StatefulWidget {
  final String? mode;

  const CurrencyListScreen({
    Key? key,
    this.mode,
  }) : super(key: key);

  @override
  _CurrencyListScreenState createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen> {
  final CurrencyService _currencyService = CurrencyService();
  List<String> currencies = [];
  List<String> filteredCurrencies = [];
  final TextEditingController _searchController = TextEditingController();

  // Map of fiat currency codes to their flag emojis
  final Map<String, String> fiatFlags = {
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

  // Add stablecoins set
  static const Set<String> stablecoins = {
    'USDT', 'USDC', 'BUSD', 'DAI', 'UST', 'SUSD', 'TUSD', 'HUSD', 'USDP', 'GUSD',
    'RSR', 'MIM', 'FRAX', 'OUSD', 'LUSD', 'XSGD', 'EURS', 'EURT', 'USDX', 'USDN'
  };

  // Define fiat currencies
  static const Set<String> fiatCurrencies = {
    'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'HKD', 'NZD', 'CNY', 'SGD',
    'ZAR', 'INR', 'BRL', 'RUB', 'AED', 'TWD', 'KRW', 'MXN', 'SAR', 'PLN', 'DKK',
    'SEK', 'NOK', 'THB', 'ILS', 'QAR', 'KWD', 'PHP', 'TRY', 'CZK', 'IDR', 'MYR',
    'HUF', 'VND', 'ISK', 'RON', 'HRK', 'BGN', 'UAH', 'UYU', 'ARS', 'COP', 'CLP',
    'PEN', 'MAD', 'NGN', 'KES', 'DZD', 'EGP', 'BDT', 'PKR', 'VEF', 'IRR', 'JOD',
    'NPR', 'LKR', 'OMR', 'MMK', 'BHD'
  };

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  void _loadCurrencies() async {
    final allCurrencies = await _currencyService.getAvailableCurrencies();
    setState(() {
      // For watchlist mode, filter based on crypto/fiat
      if (widget.mode == "Crypto") {
        currencies = allCurrencies
            .where((c) => CurrencyService.cryptoCurrencies.contains(c) || stablecoins.contains(c))
            .toList();
      } else if (widget.mode == "Fiat") {
        currencies = allCurrencies
            .where((c) => fiatCurrencies.contains(c))  // Only show true fiat currencies
            .toList();
      } else {
        // For converter and default currency, show all currencies
        currencies = allCurrencies;
      }
      filteredCurrencies = List.from(currencies);
    });
  }

  void _filterCurrencies(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCurrencies = List.from(currencies);
      } else {
        filteredCurrencies = currencies
            .where((currency) =>
                currency.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Drag indicator
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Search bar and title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Currency',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onChanged: _filterCurrencies,
                      decoration: InputDecoration(
                        hintText: 'Search currency...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ],
                ),
              ),

              // Currency list
              Expanded(
                child: ListView.builder(
                  itemCount: filteredCurrencies.length,
                  itemBuilder: (context, index) {
                    final currency = filteredCurrencies[index];
                    return ListTile(
                      leading: CurrencyIcon(symbol: currency),
                      title: Text(currency),
                      onTap: () => Navigator.pop(context, currency),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
