import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static const String userKey = 'current_user';
  
  // Register new user
  static Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (name.trim().isEmpty) {
        return AuthResponse(
          success: false,
          message: 'Name is required',
        );
      }
      
      if (email.trim().isEmpty || !_isValidEmail(email)) {
        return AuthResponse(
          success: false,
          message: 'Valid email is required',
        );
      }
      
      if (password.length < 6) {
        return AuthResponse(
          success: false,
          message: 'Password must be at least 6 characters',
        );
      }
      
      final response = await ApiService.register(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
      );
      
      final authResponse = AuthResponse.fromJson(response);
      
      if (authResponse.success && authResponse.token != null) {
        await ApiService.setToken(authResponse.token!);
        if (authResponse.user != null) {
          await _saveUser(authResponse.user!);
        }
      }
      
      return authResponse;
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }
  
  // Login user
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (email.trim().isEmpty || !_isValidEmail(email)) {
        return AuthResponse(
          success: false,
          message: 'Valid email is required',
        );
      }
      
      if (password.isEmpty) {
        return AuthResponse(
          success: false,
          message: 'Password is required',
        );
      }
      
      final response = await ApiService.login(
        email.trim().toLowerCase(), 
        password
      );
      final authResponse = AuthResponse.fromJson(response);
      
      if (authResponse.success && authResponse.token != null) {
        await ApiService.setToken(authResponse.token!);
        if (authResponse.user != null) {
          await _saveUser(authResponse.user!);
        }
      }
      
      return authResponse;
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }
  
  // Verify email
  static Future<AuthResponse> verifyEmail(String token) async {
    try {
      if (token.trim().isEmpty) {
        return AuthResponse(
          success: false,
          message: 'Verification code is required',
        );
      }
      
      final response = await ApiService.verifyEmail(token.trim());
      return AuthResponse.fromJson(response);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }
  
  // Reset password
  static Future<AuthResponse> resetPassword(String email) async {
    try {
      if (email.trim().isEmpty || !_isValidEmail(email)) {
        return AuthResponse(
          success: false,
          message: 'Valid email is required',
        );
      }
      
      final response = await ApiService.resetPassword(email.trim().toLowerCase());
      return AuthResponse.fromJson(response);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }
  
  // Get current user
  static Future<User?> getCurrentUser() async {
    try {
      final token = await ApiService.getToken();
      if (token == null) return null;
      
      final response = await ApiService.getCurrentUser();
      if (response['success'] == true && response['user'] != null) {
        final user = User.fromJson(response['user']);
        await _saveUser(user);
        return user;
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
  
  // Get cached user
  static Future<User?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(userKey);
      if (userJson != null && userJson.isNotEmpty) {
        final userData = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error getting cached user: $e');
      // Clear corrupted data
      await _removeUser();
      return null;
    }
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await ApiService.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Logout
  static Future<void> logout() async {
    try {
      await ApiService.removeToken();
      await _removeUser();
    } catch (e) {
      print('Error during logout: $e');
    }
  }
  
  // Resend OTP
  static Future<AuthResponse> resendOTP(String email) async {
    try {
      if (email.trim().isEmpty || !_isValidEmail(email)) {
        return AuthResponse(
          success: false,
          message: 'Valid email is required',
        );
      }
      
      final response = await ApiService.resendOTP(email.trim().toLowerCase());
      return AuthResponse.fromJson(response);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }
  
  // Private methods
  static Future<void> _saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(userKey, json.encode(user.toJson()));
    } catch (e) {
      print('Error saving user: $e');
    }
  }
  
  static Future<void> _removeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(userKey);
    } catch (e) {
      print('Error removing user: $e');
    }
  }
  
  // Helper methods
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Exception: ')) {
      return error.toString().replaceAll('Exception: ', '');
    }
    
    // Handle common network errors
    if (error.toString().contains('SocketException')) {
      return 'Network connection error. Please check your internet connection.';
    }
    
    if (error.toString().contains('TimeoutException')) {
      return 'Request timeout. Please try again.';
    }
    
    if (error.toString().contains('FormatException')) {
      return 'Invalid server response. Please try again.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
}