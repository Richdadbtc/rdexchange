import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class WalletController extends GetxController {
  // Observable variables
  var selectedWalletType = 'NGN'.obs;
  var ngnBalance = 0.0.obs;  // Changed from 100000.0
  var btcBalance = 0.0.obs;  // Changed from 0.00234
  var usdtBalance = 0.0.obs; // Changed from 150.0
  var piBalance = 0.0.obs;   // Changed from 1000.0
  var isLoading = false.obs;
  
  // Wallet addresses
  final Map<String, String> walletAddresses = {
    'BTC': 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
    'USDT': '0x742d35Cc6634C0532925a3b8D4C9db96590b5c8e',
    'PI': 'GAHK7EEG2WWHVKDNT4CEQFZGKF2LGDSW2IVM4S5DP42RBW3K6BTODB4A',
  };
  
  // Transaction history
  var transactions = <Map<String, dynamic>>[].obs; // Empty list instead of demo transactions
  
  void changeWalletType(String type) {
    selectedWalletType.value = type;
  }
  
  double getCurrentBalance() {
    switch (selectedWalletType.value) {
      case 'NGN':
        return ngnBalance.value;
      case 'BTC':
        return btcBalance.value;
      case 'USDT':
        return usdtBalance.value;
      case 'PI':
        return piBalance.value;
      default:
        return 0.0;
    }
  }
  
  String getCurrentBalanceString() {
    switch (selectedWalletType.value) {
      case 'NGN':
        return '₦${ngnBalance.value.toStringAsFixed(2)}';
      case 'BTC':
        return '${btcBalance.value.toStringAsFixed(8)} BTC';
      case 'USDT':
        return '${usdtBalance.value.toStringAsFixed(2)} USDT';
      case 'PI':
        return '${piBalance.value.toStringAsFixed(2)} PI';
      default:
        return '₦0.00';
    }
  }
  
  String? getWalletAddress() {
    return walletAddresses[selectedWalletType.value];
  }
  
  void copyWalletAddress() {
    final address = getWalletAddress();
    if (address != null) {
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
  
  void refreshBalance() {
    isLoading.value = true;
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