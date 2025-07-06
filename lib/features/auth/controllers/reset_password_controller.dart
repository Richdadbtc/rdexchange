import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class ResetPasswordController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  
  var email = ''.obs;
  var isLoading = false.obs;
  var isEmailSent = false.obs;

  Future<void> resetPassword() async {
    if (email.value.isEmpty) {
      Get.snackbar(
        'Error', 
        'Please enter your email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(email.value)) {
      Get.snackbar(
        'Error', 
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    
    try {
      final success = await authController.resetPassword(email.value);
      
      if (success) {
        isEmailSent.value = true;
        
        // Navigate back to login after showing success
        Future.delayed(Duration(seconds: 2), () {
          Get.back();
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  void goBackToLogin() {
    Get.back();
  }
}