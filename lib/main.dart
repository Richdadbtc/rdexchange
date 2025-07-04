import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';

void main() {
  runApp(const RDExchangeApp());
}

class RDExchangeApp extends StatelessWidget {
  const RDExchangeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RD Exchange',
      theme: AppTheme.darkTheme,
      initialRoute: AppPages.INITIAL, // Use uppercase INITIAL
      getPages: AppPages.routes,
    );
  }
}