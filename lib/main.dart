import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'data/services/api_service.dart';
import 'data/services/reward_service.dart';
import 'data/services/user_service.dart';
import 'data/services/market_service.dart';
import 'data/services/wallet_service.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register services
  Get.put(RewardService()); // Add this line
  await Get.putAsync(() => UserService().init());
  Get.put(MarketService());
  Get.put(WalletService());
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RDX Exchange',
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      getPages: AppPages.routes,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}