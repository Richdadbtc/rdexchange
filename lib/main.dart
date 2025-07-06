import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'routes/app_pages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RDX Exchange',
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