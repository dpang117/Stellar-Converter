import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyListScreen extends StatefulWidget {
  @override
  _CurrencyListScreenState createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen> {
  late Future<List<Map<String, String>>> _currenciesFuture;
  List<Map<String, String>> _allCurrencies = []; // Full currency list
  List<Map<String, String>> _filteredCurrencies = []; // Filtered results
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currenciesFuture = fetchCurrencies();
  }

  /// Fetch both fiat and crypto currencies from backend
  Future<List<Map<String, String>>> fetchCurrencies() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:5000/api/currencies'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<Map<String, String>> currencyList = [];

      data.forEach((code, name) {
        currencyList.add({"name": name, "code": code});
      });

      setState(() {
        _allCurrencies = currencyList;
        _filteredCurrencies = currencyList; // Default to all
      });

      return currencyList;
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  /// Filter the list based on search input
  void _filterCurrencies(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCurrencies = _allCurrencies;
      });
      return;
    }

    setState(() {
      _filteredCurrencies = _allCurrencies.where((currency) {
        final name = currency["name"]!.toLowerCase();
        final code = currency["code"]!.toLowerCase();
        return name.contains(query.toLowerCase()) ||
            code.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Material(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Title
                const Text(
                  'Currency',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Color(0xFF191B1E),
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                const SizedBox(height: 10),

                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _filterCurrencies, // Calls filter function
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: "Search currency...",
                    prefixIcon: Icon(Icons.search, color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Currency List (Fiat & Crypto)
                Expanded(
                  child: FutureBuilder<List<Map<String, String>>>(
                    future: _currenciesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error loading currencies"));
                      } else {
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: _filteredCurrencies.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(
                                index < 1000
                                    ? Icons.monetization_on
                                    : Icons.currency_bitcoin,
                                color: Colors.blue,
                              ),
                              title: Text(
                                _filteredCurrencies[index]["name"]!,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SF Pro Display',
                                ),
                              ),
                              subtitle: Text(
                                _filteredCurrencies[index]["code"]!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF737A86),
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context,
                                    _filteredCurrencies[index]["code"]);
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
