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
      final response = await ApiService.register(
        name: name,
        email: email,
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
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
  
  // Login user
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.login(email, password);
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
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
  
  // Verify email
  static Future<AuthResponse> verifyEmail(String token) async {
    try {
      final response = await ApiService.verifyEmail(token);
      return AuthResponse.fromJson(response);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
  
  // Reset password
  static Future<AuthResponse> resetPassword(String email) async {
    try {
      final response = await ApiService.resetPassword(email);
      return AuthResponse.fromJson(response);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: e.toString().replaceAll('Exception: ', ''),
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
      return null;
    }
  }
  
  // Get cached user
  static Future<User?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(userKey);
      if (userJson != null) {
        final userData = Map<String, dynamic>.from(
          await Future.value(userJson).then((json) => 
            Map<String, dynamic>.from({})
          )
        );
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }
  
  // Logout
  static Future<void> logout() async {
    await ApiService.removeToken();
    await _removeUser();
  }
  
  // Private methods
  static Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, user.toJson().toString());
  }
  
  static Future<void> _removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
  }
}