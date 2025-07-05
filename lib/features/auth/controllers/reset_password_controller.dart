import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  var email = ''.obs;
  var isLoading = false.obs;
  var isEmailSent = false.obs;

  void resetPassword() {
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
    
    // Simulate API call - replace with actual reset password API
    Future.delayed(Duration(seconds: 2), () {
      isLoading.value = false;
      isEmailSent.value = true;
      
      Get.snackbar(
        'Success', 
        'Password reset link sent to your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      
      // Navigate back to login after showing success
      Future.delayed(Duration(seconds: 2), () {
        Get.back();
      });
    });
  }

  void goBackToLogin() {
    Get.back();
  }
}