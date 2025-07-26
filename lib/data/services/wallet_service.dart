import 'package:get/get.dart';
import 'api_service.dart';
import '../models/transaction_model.dart';

class WalletService extends GetxService {
  var balances = <String, double>{}.obs;
  var isLoading = false.obs;
  var transactions = <TransactionModel>[].obs;

  Future<void> fetchWalletBalances() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get('/wallet/balance');
      
      if (response['success']) {
        final walletData = response['wallet'];
        final balanceData = walletData['balances'];
        
        balances.value = {
          'NGN': (balanceData['NGN']?['total'] ?? 0.0).toDouble(),
          'BTC': (balanceData['BTC']?['total'] ?? 0.0).toDouble(),
          'USDT': (balanceData['USDT']?['total'] ?? 0.0).toDouble(),
          'PI': (balanceData['PI']?['total'] ?? 0.0).toDouble(),
        };
      }
    } catch (e) {
      print('Error fetching wallet balances: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await ApiService.get('/transactions');
      
      if (response['success']) {
        final transactionList = response['transactions'] as List;
        transactions.value = transactionList
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  double getBalance(String currency) {
    return balances[currency] ?? 0.0;
  }
}