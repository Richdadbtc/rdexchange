import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.182.33:5000/api';
  static const String tokenKey = 'auth_token';
  
  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }
  
  // Store token
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }
  
  // Remove token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }
  
  // Get headers with auth token
  static Future<Map<String, String>> getHeaders({bool includeAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  // Handle API response
  static Map<String, dynamic> handleResponse(http.Response response) {
    final data = json.decode(response.body);    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'An error occurred');
    }
  }
  
  // Auth endpoints
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Split the name into firstName and lastName
    final nameParts = name.trim().split(' ');
    final firstName = nameParts.first;
    // If no last name provided, use a default or prompt user
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'User';
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await getHeaders(includeAuth: false),
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      }),
    );
    return handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await getHeaders(includeAuth: false),
      body: json.encode({'email': email, 'password': password}),
    );
    return handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> verifyEmail(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-email'),
      headers: await getHeaders(includeAuth: false),
      body: json.encode({'token': token}),
    );
    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> resendOTP(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/resend-otp'),
      headers: await getHeaders(includeAuth: false),
      body: json.encode({'email': email}),
    );
    return handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: await getHeaders(),
    );
    return handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: await getHeaders(includeAuth: false),
      body: json.encode({'email': email}),
    );
    return handleResponse(response);
  }
  
  // Wallet endpoints
  static Future<Map<String, dynamic>> getWalletBalance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallet/balance'),
      headers: await getHeaders(),
    );
    return handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> getWalletAddresses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallet/addresses'),
      headers: await getHeaders(),
    );
    return handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> fundWallet({
    required String currency,
    required double amount,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wallet/fund'),
      headers: await getHeaders(),
      body: json.encode({
        'currency': currency,
        'amount': amount,
      }),
    );
    return handleResponse(response);
  }
}