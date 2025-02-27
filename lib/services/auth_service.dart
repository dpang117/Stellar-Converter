import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/register_request.dart';

class AuthService {
  static const String _authTokenKey = 'auth_token';
  static const String _userEmailKey = 'user_email';
  static const String _userDataKey = 'user_data';
  
  static const String baseUrl = 'http://api.stellarpay.app';

  // Login with actual API
  static Future<bool> login(String emailOrUsername, String password) async {
    try {
      print('Attempting login with: $emailOrUsername');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': emailOrUsername,
          'password': password,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = json.decode(response.body);
      
      switch (response.statusCode) {
        case 200:
          if (data['response']['status'] == 'success') {
            final responseBody = data['response']['body'];
            final token = responseBody['token'];
            final user = responseBody['user'];

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_authTokenKey, token);
            await prefs.setString(_userEmailKey, user['email']);
            await prefs.setString(_userDataKey, json.encode(user));
            
            return true;
          }
          throw Exception('Invalid response format');
          
        case 500:
          print('Server error details: ${response.body}');
          throw Exception('Server error - please try again later');
          
        case 401:
          throw Exception('Invalid credentials');
          
        case 403:
          throw Exception('Account locked');
          
        case 404:
          throw Exception('User not found');
          
        default:
          throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }

  // Get auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_authTokenKey);
    return token != null;
  }

  // Placeholder for signup
  static Future<bool> signup(String email, String password) async {
    // TODO: Implement actual signup API call
    // For now, just store dummy data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, 'dummy_token');
    await prefs.setString(_userEmailKey, email);
    return true;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userDataKey);
  }

  // Get current user email
  static Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Add the register method
  static Future<bool> register(RegisterRequest request) async {
    try {
      print('Attempting registration for: ${request.email}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = json.decode(response.body);
      
      switch (response.statusCode) {
        case 200:
          if (data['response']['status'] != 'error') {
            final responseBody = data['response']['body'];
            final token = responseBody['token'];
            final user = responseBody['user'];

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_authTokenKey, token);
            await prefs.setString(_userEmailKey, user['email']);
            await prefs.setString(_userDataKey, json.encode(user));
            
            return true;
          }
          throw Exception(data['response']['message'] ?? 'Registration failed');
          
        case 400:
          throw Exception('Invalid registration data');
          
        case 409:
          throw Exception('Username or email already exists');
          
        case 500:
          print('Server error details: ${response.body}');
          throw Exception('Server error - please try again later');
          
        default:
          throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }
} 