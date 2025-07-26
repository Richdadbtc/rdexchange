import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/social_auth_service.dart'; 

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final SocialAuthService _socialAuthService = SocialAuthService();
  
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
      clearError();
      
      print('Attempting login for: $email'); // Add debug info
      
      final response = await _authRepository.login(
        email: email,
        password: password,
      );
      
      print('Login response: ${response.success}, message: ${response.message}'); // Add debug info
      
      if (response.success) {
        if (response.user != null) {
          currentUser.value = response.user;
          isLoggedIn.value = true;
          print('User logged in successfully: ${response.user!.email}'); // Add debug info
        }
        
        _showSuccess('Logged in successfully');
        return true;
      } else {
        print('Login failed: ${response.errorMessage}'); // Add debug info
        _showError(response.errorMessage); // Use errorMessage instead of message
        return false;
      }
    } catch (e) {
      print('Login exception: $e'); // Add debug info
      _showError('Login failed: ${e.toString()}');
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

  // Social Authentication Methods
  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final response = await _socialAuthService.signInWithGoogle();
      
      if (response.success && response.user != null && response.token != null) {
        await _saveUserData(response.user!, response.token!);
        Get.snackbar('Success', 'Google sign in successful!', snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Google sign in failed: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signInWithFacebook() async {
    try {
      isLoading.value = true;
      final response = await _socialAuthService.signInWithFacebook();
      
      if (response.success && response.user != null && response.token != null) {
        await _saveUserData(response.user!, response.token!);
        Get.snackbar('Success', 'Facebook sign in successful!', snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Facebook sign in failed: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signInWithApple() async {
    try {
      isLoading.value = true;
      final response = await _socialAuthService.signInWithApple();
      
      if (response.success && response.user != null && response.token != null) {
        await _saveUserData(response.user!, response.token!);
        Get.snackbar('Success', 'Apple sign in successful!', snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Apple sign in failed: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _socialAuthService.signOutFromSocialProviders();
    super.onClose();
  }

  // Add this missing method
  Future<void> _saveUserData(User user, String token) async {
    try {
      // Save token
      await _authRepository.saveToken(token);
      
      // Update current user and login status
      currentUser.value = user;
      isLoggedIn.value = true;
      
      // Navigate to home screen
      Get.offAllNamed('/home');
    } catch (e) {
      print('Error saving user data: $e');
      throw e;
    }
  }
}