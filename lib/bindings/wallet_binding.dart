import 'package:get/get.dart';
import '../features/wallet/controllers/wallet_controller.dart';
import '../data/services/wallet_service.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure WalletService is available
    if (!Get.isRegistered<WalletService>()) {
      Get.put(WalletService());
    }
    
    // Use Get.put instead of Get.lazyPut for immediate registration
    Get.put<WalletController>(
      WalletController(),
    );
  }
}