import 'package:get/get.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'api_service.dart';

class CryptoPriceData {
  final String symbol;
  final String name;
  final double usd;
  final double ngn;
  final double change24h;
  final DateTime timestamp;

  CryptoPriceData({
    required this.symbol,
    required this.name,
    required this.usd,
    required this.ngn,
    required this.change24h,
    required this.timestamp,
  });

  factory CryptoPriceData.fromJson(Map<String, dynamic> json) {
    return CryptoPriceData(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      usd: (json['usd'] ?? 0).toDouble(),
      ngn: (json['ngn'] ?? 0).toDouble(),
      change24h: (json['usd_24h_change'] ?? 0).toDouble(),
      timestamp: DateTime.now(),
    );
  }

  bool get isPositiveChange => change24h >= 0;
  String get formattedChange => '${change24h >= 0 ? '+' : ''}${change24h.toStringAsFixed(2)}%';
  String get formattedUsdPrice => '\$${usd.toStringAsFixed(2)}';
  String get formattedNgnPrice => '₦${ngn.toStringAsFixed(2)}';
}

class MarketService extends GetxService {
  static MarketService get to => Get.find();
  
  // Observable price data
  var cryptoPrices = <String, CryptoPriceData>{}.obs;
  var isLoading = false.obs;
  var lastUpdated = Rxn<DateTime>();
  var errorMessage = ''.obs;
  
  Timer? _priceUpdateTimer;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchPrices();
    startPriceUpdates();
  }
  
  @override
  void onClose() {
    _priceUpdateTimer?.cancel();
    super.onClose();
  }
  
  // Fetch current prices from API
  Future<void> fetchPrices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await ApiService.get('/crypto/prices');
      
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        
        cryptoPrices.clear();
        data.forEach((symbol, priceData) {
          cryptoPrices[symbol] = CryptoPriceData.fromJson(priceData);
        });
        
        lastUpdated.value = DateTime.now();
      } else {
        errorMessage.value = response['message'] ?? 'Failed to fetch prices';
      }
    } catch (e) {
      errorMessage.value = 'Network error: ${e.toString()}';
      print('Error fetching prices: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Start automatic price updates every 30 seconds
  void startPriceUpdates() {
    _priceUpdateTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchPrices();
    });
  }
  
  // Stop automatic updates
  void stopPriceUpdates() {
    _priceUpdateTimer?.cancel();
  }
  
  // Get price for specific symbol
  CryptoPriceData? getPrice(String symbol) {
    return cryptoPrices[symbol.toUpperCase()];
  }
  
  // Get NGN price for symbol
  double getNgnPrice(String symbol) {
    return getPrice(symbol)?.ngn ?? 0.0;
  }
  
  // Get USD price for symbol
  double getUsdPrice(String symbol) {
    return getPrice(symbol)?.usd ?? 0.0;
  }
  
  // Calculate buy amount (NGN to crypto)
  double calculateBuyAmount(String symbol, double ngnAmount) {
    final price = getNgnPrice(symbol);
    if (price <= 0) return 0.0;
    return ngnAmount / price;
  }
  
  // Calculate sell amount (crypto to NGN)
  double calculateSellAmount(String symbol, double cryptoAmount) {
    final price = getNgnPrice(symbol);
    return cryptoAmount * price;
  }
  
  // Get all available symbols
  List<String> get availableSymbols => cryptoPrices.keys.toList();
  
  // Check if prices are stale (older than 2 minutes)
  bool get isPricesStale {
    if (lastUpdated.value == null) return true;
    return DateTime.now().difference(lastUpdated.value!).inMinutes > 2;
  }
}