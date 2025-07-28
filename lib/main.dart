import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rdexchange/data/services/auth_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'data/services/api_service.dart';
import 'data/services/reward_service.dart';
import 'data/services/user_service.dart';
import 'data/services/market_service.dart';
import 'data/services/wallet_service.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'routes/app_pages.dart';
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize timezone
  tz.initializeTimeZones();
  
  // Register services
  Get.put(ApiService());
  Get.put(AuthService());
  Get.put(UserService());
  Get.put(MarketService());
  Get.put(WalletService());
  Get.put(RewardService());
  Get.put(NotificationService()); // Add this line
  
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