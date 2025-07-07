import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  
  // Observable variables
  var isLoading = false.obs;
  var currentUser = Rxn<User>();
  var isLoggedIn = false.obs;
  var errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }
  
  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }
  
  // Show error snackbar
  void _showError(String message) {
    errorMessage.value = message;
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 4),
    );
  }
  
  // Show success snackbar
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );
  }
  
  // Check authentication status
  Future<void> checkAuthStatus() async {
    try {
      isLoading.value = true;
      clearError();
      
      final loggedIn = await _authRepository.isLoggedIn();
      isLoggedIn.value = loggedIn;
      
      if (loggedIn) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          currentUser.value = user;
        } else {
          // Token might be invalid, logout
          await logout();
        }
      }
    } catch (e) {
      print('Auth check error: $e');
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      clearError();
      
      // Client-side validation
      if (name.trim().isEmpty) {
        _showError('Name is required');
        return false;
      }
      
      if (email.trim().isEmpty) {
        _showError('Email is required');
        return false;
      }
      
      if (password.length < 6) {
        _showError('Password must be at least 6 characters');
        return false;
      }
      
      final response = await _authRepository.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );
      
      if (response.success) {
        if (response.user != null) {
          currentUser.value = response.user;
          isLoggedIn.value = true;
        }
        
        _showSuccess(response.message);
        return true;
      } else {
        _showError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _showError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      
      final response = await _authRepository.login(
        email: email,
        password: password,
      );
      
      if (response.success) {
        if (response.user != null) {
          currentUser.value = response.user;
          isLoggedIn.value = true;
        }
        
        Get.snackbar(
          'Success',
          'Logged in successfully',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return true;
      } else {
        Get.snackbar(
          'Login Failed',
          response.message,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Verify email
  Future<bool> verifyEmail(String token) async {
    try {
      isLoading.value = true;
      
      final response = await _authRepository.verifyEmail(token);
      
      if (response.success) {
        Get.snackbar(
          'Success',
          'Email verified successfully',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        // Refresh user data
        await checkAuthStatus();
        return true;
      } else {
        Get.snackbar(
          'Verification Failed',
          response.message,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Verification failed: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      
      final response = await _authRepository.resetPassword(email);
      
      if (response.success) {
        Get.snackbar(
          'Success',
          response.message,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Reset Failed',
          response.message,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Reset failed: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Resend OTP
  Future<bool> resendOTP(String email) async {
    try {
      isLoading.value = true;
      clearError();
      
      if (email.trim().isEmpty) {
        _showError('Email is required');
        return false;
      }
      
      final response = await _authRepository.resendOTP(email.trim());
      
      if (response.success) {
        _showSuccess(response.message);
        return true;
      } else {
        _showError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _showError('Failed to resend OTP: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      currentUser.value = null;
      isLoggedIn.value = false;
      
      Get.snackbar(
        'Success',
        'Logged out successfully',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Navigate to login
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout failed: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}