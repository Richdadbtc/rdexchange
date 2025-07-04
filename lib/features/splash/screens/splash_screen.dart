import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToOnboarding();
  }

  _navigateToOnboarding() {
    Timer(Duration(seconds: 3), () {
      Get.offNamed('/onboarding');
    });
  }
}

class SplashScreen extends StatelessWidget {
  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A), // Dark background to match your design
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // RDX Logo
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Replace text with actual logo
                  Image.asset(
                    'assets/images/rdx_logo.png', // Add your logo file here
                    height: 100,
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'EXCHANGE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            // Tagline
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text(
                    'BUY & SELL',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'CRYPTO INSTANTLY',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}