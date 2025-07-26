import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:rdexchange/data/services/wallet_service.dart';
import 'package:rdexchange/data/models/transaction_model.dart';

class WalletController extends GetxController {
  // Use lazy initialization instead of immediate Get.find
  WalletService get walletService => Get.find<WalletService>();
  
  var selectedWalletType = 'NGN'.obs;
  var isLoading = false.obs;
  
  // Add transactions property
  var transactions = <Map<String, dynamic>>[].obs;
  
  // Wallet addresses map
  final Map<String, String> walletAddresses = {
    'BTC': '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa',
    'USDT': '0x742d35Cc6634C0532925a3b8D4C9db96590b4c5d',
    'PI': 'GDQP2KPQGKIHYJGXNUIYOMHARUARCA7DJT5FO2FFOOKY3B2WSQHG4W37',
    'NGN': '', // NGN doesn't have a crypto address
  };
  
  // Balance getters - these return double values directly
  double get ngnBalance => walletService.getBalance('NGN');
  double get btcBalance => walletService.getBalance('BTC');
  double get usdtBalance => walletService.getBalance('USDT');
  double get piBalance => walletService.getBalance('PI');

  @override
  void onInit() {
    super.onInit();
    walletService.fetchWalletBalances();
    _loadSampleTransactions(); // Load sample data for now
  }

  void _loadSampleTransactions() {
    transactions.value = [
      {
        'type': 'Fund Wallet',
        'amount': '₦50,000.00',
        'date': '2 hours ago',
        'status': 'Completed',
        'icon': 'fund',
      },
      {
        'type': 'Buy BTC',
        'amount': '0.001 BTC',
        'date': '1 day ago',
        'status': 'Completed',
        'icon': 'buy',
      },
      {
        'type': 'Withdraw USDT',
        'amount': '100.00 USDT',
        'date': '3 days ago',
        'status': 'Pending',
        'icon': 'withdraw',
      },
    ];
  }

  void refreshBalance() {
    walletService.fetchWalletBalances();
  }
  
  void changeWalletType(String type) {
    selectedWalletType.value = type;
  }
  
  double getCurrentBalance() {
    switch (selectedWalletType.value) {
      case 'NGN':
        return ngnBalance;
      case 'BTC':
        return btcBalance;
      case 'USDT':
        return usdtBalance;
      case 'PI':
        return piBalance;
      default:
        return 0.0;
    }
  }
  
  String getCurrentBalanceString() {
    switch (selectedWalletType.value) {
      case 'NGN':
        return '₦${ngnBalance.toStringAsFixed(2)}';
      case 'BTC':
        return '${btcBalance.toStringAsFixed(8)} BTC';
      case 'USDT':
        return '${usdtBalance.toStringAsFixed(2)} USDT';
      case 'PI':
        return '${piBalance.toStringAsFixed(2)} PI';
      default:
        return '₦0.00';
    }
  }
  
  String? getWalletAddress() {
    return walletAddresses[selectedWalletType.value];
  }
  
  void copyWalletAddress() {
    final address = getWalletAddress();
    if (address != null && address.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: address));
      Get.snackbar(
        'Copied!',
        'Wallet address copied to clipboard',
        backgroundColor: Color(0xFF2A2A2A),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
      );
    }
  }
  
  void fundWallet() {
    Get.snackbar(
      'Fund Wallet',
      'Redirecting to payment gateway...',
      backgroundColor: Color(0xFF2A2A2A),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
    );
  }
  
  void withdrawFunds() {
    Get.snackbar(
      'Withdraw Funds',
      'Withdrawal request initiated...',
      backgroundColor: Color(0xFF2A2A2A),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
    );
  }
  
  void refreshBalanceWithLoading() {
    isLoading.value = true;
    walletService.fetchWalletBalances();
    // Simulate API call
    Future.delayed(Duration(seconds: 2), () {
      isLoading.value = false;
      Get.snackbar(
        'Refreshed',
        'Balance updated successfully',
        backgroundColor: Color(0xFF2A2A2A),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
      );
    });
  }
}