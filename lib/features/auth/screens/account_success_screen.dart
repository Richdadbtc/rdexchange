import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class AccountSuccessController extends GetxController {
  void goToLogin() {
    Get.offAllNamed('/login');
  }
  
  void startTrading() {
    // Navigate to home screen
    // Add navigation to dashboard after success
    Future.delayed(Duration(seconds: 3), () {
      Get.offAllNamed('/home');
    });
  }
}

class AccountSuccessScreen extends StatelessWidget {
  final AccountSuccessController controller = Get.put(AccountSuccessController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20), // Added top spacing
              // Success Animation/Icon
              Container(
                width: 100, // Reduced from 120
                height: 100, // Reduced from 120
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  MaterialCommunityIcons.check_circle,
                  size: 60, // Reduced from 80
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 24), // Reduced from 40
              Text(
                'Account Created Successfully!',
                style: TextStyle(
                  fontSize: 24, // Reduced from 28
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12), // Reduced from 16
              Text(
                'Welcome to RD Exchange',
                style: TextStyle(
                  fontSize: 20, // Reduced from 24
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16), // Reduced from 20
              Text(
                'Your account has been verified and created successfully. You can now start trading with confidence on our secure platform.',
                style: TextStyle(
                  fontSize: 14, // Reduced from 16
                  color: Colors.grey[600],
                  height: 1.4, // Reduced from 1.5
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30), // Reduced from 50
              // Benefits/Features
              Container(
                padding: EdgeInsets.all(16), // Reduced from 20
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      icon: MaterialCommunityIcons.security,
                      title: 'Secure Trading',
                      description: 'Your funds are protected with bank-level security',
                    ),
                    SizedBox(height: 12), // Reduced from 16
                    _buildFeatureItem(
                      icon: MaterialCommunityIcons.chart_line,
                      title: 'Real-time Data',
                      description: 'Access live market data and analytics',
                    ),
                    SizedBox(height: 12), // Reduced from 16
                    _buildFeatureItem(
                      icon: MaterialCommunityIcons.headset,
                      title: '24/7 Support',
                      description: 'Get help whenever you need it',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30), // Reduced from 40
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.startTrading,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Start Trading',
                    style: TextStyle(
                      fontSize: 16, // Reduced from 18
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12), // Reduced from 16
              TextButton(
                onPressed: controller.goToLogin,
                child: Text(
                  'Go to Login',
                  style: TextStyle(
                    fontSize: 14, // Reduced from 16
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 20), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.green,
          size: 20, // Reduced from 24
        ),
        SizedBox(width: 10), // Reduced from 12
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13, // Reduced from 14
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11, // Reduced from 12
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}