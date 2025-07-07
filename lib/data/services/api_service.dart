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
  
  // Get headers with optional auth
  static Future<Map<String, String>> getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
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
    try {
      final data = json.decode(response.body);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Invalid response format',
      };
    }
  }
  
  // Generic GET request
  static Future<Map<String, dynamic>> get(String endpoint, {bool includeAuth = true}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(includeAuth: includeAuth),
      );
      return handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  // Generic POST request
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {bool includeAuth = true}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getHeaders(includeAuth: includeAuth),
        body: json.encode(data),
      );
      return handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
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
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> verifyEmail(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-email'),
      headers: await getHeaders(includeAuth: false),
      body: json.encode({
        'token': token,
      }),
    );
    return handleResponse(response);
  }

  static Future<Map<String, dynamic>> resetPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: await getHeaders(includeAuth: false),
      body: json.encode({
        'email': email,
      }),
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