import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/currency_service.dart';
import '../widgets/currency_icon.dart';

class CurrencyListScreen extends StatefulWidget {
  final String? mode;
  final bool isCountrySelect;

  const CurrencyListScreen({
    Key? key,
    this.mode,
    this.isCountrySelect = false,
  }) : super(key: key);

  @override
  _CurrencyListScreenState createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen> {
  final CurrencyService _currencyService = CurrencyService();
  List<String> currencies = [];
  List<String> filteredCurrencies = [];
  final TextEditingController _searchController = TextEditingController();


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

  // Update the currencyToCountry map with full names
  final Map<String, String> currencyToCountry = {
    'USD': 'United States of America',
    'EUR': 'European Union',
    'GBP': 'United Kingdom',
    'JPY': 'Japan',
    'CAD': 'Canada',
    'AUD': 'Australia',
    'CHF': 'Switzerland',
    'CNY': 'People\'s Republic of China',
    'HKD': 'Hong Kong',
    'NZD': 'New Zealand',
    'SGD': 'Singapore',
    'ZAR': 'South Africa',
    'INR': 'India',
    'BRL': 'Brazil',
    'RUB': 'Russia',
    'AED': 'United Arab Emirates',
    'TWD': 'Taiwan',
    'KRW': 'South Korea',
    'MXN': 'Mexico',
    'SAR': 'Saudi Arabia',
    'PLN': 'Poland',
    'DKK': 'Denmark',
    'SEK': 'Sweden',
    'NOK': 'Norway',
    'THB': 'Thailand',
    'ILS': 'Israel',
    'QAR': 'Qatar',
    'KWD': 'Kuwait',
    'PHP': 'Philippines',
    'TRY': 'Turkey',
    'CZK': 'Czech Republic',
    'IDR': 'Indonesia',
    'MYR': 'Malaysia',
    'HUF': 'Hungary',
    'VND': 'Vietnam',
    'ISK': 'Iceland',
    'RON': 'Romania',
    'HRK': 'Croatia',
    'BGN': 'Bulgaria',
    'UAH': 'Ukraine',
    'UYU': 'Uruguay',
    'ARS': 'Argentina',
    'COP': 'Colombia',
    'CLP': 'Chile',
    'PEN': 'Peru',
    'MAD': 'Morocco',
    'NGN': 'Nigeria',
    'KES': 'Kenya',
    'DZD': 'Algeria',
    'EGP': 'Egypt',
    'BDT': 'Bangladesh',
    'PKR': 'Pakistan',
    'VEF': 'Venezuela',
    'IRR': 'Iran',
    'JOD': 'Jordan',
    'NPR': 'Nepal',
    'LKR': 'Sri Lanka',
    'OMR': 'Oman',
    'MMK': 'Myanmar',
    'BHD': 'Bahrain'
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
        filteredCurrencies = currencies.where((currency) {
          // Check if currency code matches
          final currencyMatches = currency.toLowerCase().contains(query.toLowerCase());
          
          // Check if country name matches (for fiat currencies)
          final countryName = currencyToCountry[currency]?.toLowerCase() ?? '';
          final countryMatches = countryName.contains(query.toLowerCase());
          
          return currencyMatches || countryMatches;
        }).toList();
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
                      leading: widget.isCountrySelect 
                        ? CurrencyIcon(symbol: currency)  // Use CurrencyIcon instead of emoji
                        : CurrencyIcon(symbol: currency),
                      title: Text(
                        widget.isCountrySelect 
                          ? (currencyToCountry[currency] ?? currency)  // Show full country name
                          : currency
                      ),
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
