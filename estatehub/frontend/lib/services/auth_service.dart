import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/api_config.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Keys for SharedPreferences
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Current user and token
  String? _token;
  User? _currentUser;

  // Getters
  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _currentUser != null;

  // ============================================================================
  // INITIALIZE - Load saved token and user on app start
  // ============================================================================
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  // ============================================================================
  // LOGIN
  // ============================================================================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email, // FastAPI OAuth2 uses 'username' field
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        
        // Save token and user
        await _saveAuthData(authResponse.accessToken, authResponse.user);
        
        return {
          'success': true,
          'message': 'Login successful!',
          'user': authResponse.user,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // ============================================================================
  // REGISTER
  // ============================================================================
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        
        // Save token and user
        await _saveAuthData(authResponse.accessToken, authResponse.user);
        
        return {
          'success': true,
          'message': 'Registration successful!',
          'user': authResponse.user,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('Register error: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // ============================================================================
  // LOGOUT
  // ============================================================================
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      
      _token = null;
      _currentUser = null;
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // ============================================================================
  // SAVE AUTH DATA
  // ============================================================================
  Future<void> _saveAuthData(String token, User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      
      _token = token;
      _currentUser = user;
    } catch (e) {
      print('Error saving auth data: $e');
    }
  }

  // ============================================================================
  // GET AUTHORIZATION HEADER
  // ============================================================================
  Map<String, String> getAuthHeaders() {
    if (_token == null) {
      return {'Content-Type': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }

  // ============================================================================
  // VERIFY TOKEN (Optional - check if token is still valid)
  // ============================================================================
  Future<bool> verifyToken() async {
    if (_token == null) return false;
    
    try {
      // You can add an endpoint to verify token if needed
      // For now, just check if token exists
      return true;
    } catch (e) {
      print('Token verification error: $e');
      return false;
    }
  }
}