import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KycController extends GetxController {
  var selectedVerificationType = 'NIN'.obs;
  var verificationNumber = ''.obs;
  var firstName = ''.obs;
  var lastName = ''.obs;
  var dateOfBirth = ''.obs;
  var phoneNumber = ''.obs;
  var isLoading = false.obs;
  var isVerified = false.obs;
  
  final List<String> verificationTypes = ['NIN', 'BVN'];
  
  void selectVerificationType(String type) {
    selectedVerificationType.value = type;
    verificationNumber.value = '';
  }
  
  bool validateNIN(String nin) {
    // NIN should be 11 digits
    return nin.length == 11 && RegExp(r'^[0-9]+$').hasMatch(nin);
  }
  
  bool validateBVN(String bvn) {
    // BVN should be 11 digits
    return bvn.length == 11 && RegExp(r'^[0-9]+$').hasMatch(bvn);
  }
  
  bool validateForm() {
    if (selectedVerificationType.value == 'NIN') {
      return validateNIN(verificationNumber.value) &&
             firstName.value.isNotEmpty &&
             lastName.value.isNotEmpty &&
             dateOfBirth.value.isNotEmpty;
    } else {
      return validateBVN(verificationNumber.value) &&
             firstName.value.isNotEmpty &&
             lastName.value.isNotEmpty &&
             phoneNumber.value.isNotEmpty;
    }
  }
  
  Future<void> submitVerification() async {
    if (!validateForm()) {
      Get.snackbar(
        'Error',
        'Please fill all required fields correctly',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    isLoading.value = true;
    
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 3));
      
      // For demo purposes, we'll simulate success
      isVerified.value = true;
      
      Get.snackbar(
        'Success',
        'KYC verification submitted successfully! You will be notified once verified.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
      
      // Navigate back after a delay
      Future.delayed(Duration(seconds: 2), () {
        Get.back();
      });
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit verification. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(Duration(days: 6570)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      dateOfBirth.value = '${picked.day}/${picked.month}/${picked.year}';
    }
  }
}