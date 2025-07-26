import 'package:get/get.dart';
import '../data/services/wallet_service.dart';
import '../features/wallet/controllers/wallet_controller.dart';
import '../features/home/screens/home_screen.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure WalletService is available
    if (!Get.isRegistered<WalletService>()) {
      Get.put(WalletService());
    }
    
    // Register WalletController
    if (!Get.isRegistered<WalletController>()) {
      Get.put<WalletController>(WalletController());
    }
    
    // Register HomeTabController
    Get.lazyPut<HomeTabController>(() => HomeTabController());
  }
}