import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  // Register
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return await AuthService.register(
      name: name,
      email: email,
      password: password,
    );
  }
  
  // Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await AuthService.login(
      email: email,
      password: password,
    );
  }
  
  // Verify email
  Future<AuthResponse> verifyEmail(String token) async {
    return await AuthService.verifyEmail(token);
  }
  
  // Reset password
  Future<AuthResponse> resetPassword(String email) async {
    return await AuthService.resetPassword(email);
  }
  
  // Get current user
  Future<User?> getCurrentUser() async {
    return await AuthService.getCurrentUser();
  }
  
  // Get cached user
  Future<User?> getCachedUser() async {
    return await AuthService.getCachedUser();
  }
  
  // Check if logged in
  Future<bool> isLoggedIn() async {
    return await AuthService.isLoggedIn();
  }
  
  // Logout
  Future<void> logout() async {
    await AuthService.logout();
  }
  
  // Resend OTP
  Future<AuthResponse> resendOTP(String email) async {
    return await AuthService.resendOTP(email);
  }
}