import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import '../config/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  String? _token;
  User? _currentUser;

  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _currentUser != null;

  // 🔥 FIREBASE & GOOGLE SIGN-IN INSTANCES
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ============================================================================
  // INITIALIZE
  // ============================================================================
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
      }
      
      print("✅ Auth Service initialized");
    } catch (e) {
      print('❌ Error initializing auth: $e');
    }
  }

  // ============================================================================
  // 🔥 GOOGLE SIGN-IN
  // ============================================================================
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print("🔵 Starting Google Sign-In...");
      
      // 1️⃣ Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print("⚠️ User cancelled Google Sign-In");
        return {
          'success': false,
          'message': 'Sign-in cancelled',
        };
      }

      print("🔵 Google user selected: ${googleUser.email}");

      // 2️⃣ Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print("🔵 Got Google auth tokens");

      // 3️⃣ Create Firebase credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("🔵 Created Firebase credential");

      // 4️⃣ Sign in to Firebase
      final firebase_auth.UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(credential);

      print("🔵 Signed in to Firebase");

      // 5️⃣ Get Firebase user
      final firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        print("❌ Firebase user is null");
        return {
          'success': false,
          'message': 'Authentication failed',
        };
      }

      print("🔵 Firebase user: ${firebaseUser.email}");

      // 6️⃣ Get Firebase ID token
      final String? idToken = await firebaseUser.getIdToken();

      // 7️⃣ Create local user object
      final user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        fullName: firebaseUser.displayName ?? googleUser.displayName ?? '',
        phone: firebaseUser.phoneNumber,
        isActive: true,
        createdAt: DateTime.now(),
      );

      // 8️⃣ Save token and user data
      await _saveAuthData(idToken ?? '', user);

      print("✅ Google Sign-In successful!");

      return {
        'success': true,
        'message': 'Signed in with Google successfully!',
        'user': user,
      };

    } on firebase_auth.FirebaseAuthException catch (e) {
      print("❌ Firebase Auth Error: ${e.code} - ${e.message}");
      return {
        'success': false,
        'message': _getFirebaseErrorMessage(e.code),
      };
    } catch (e) {
      print("❌ Google Sign-In Error: $e");
      return {
        'success': false,
        'message': 'Failed to sign in with Google. Please try again.',
      };
    }
  }

  // ============================================================================
  // EMAIL/PASSWORD LOGIN
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
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        
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
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Firebase
      await _firebaseAuth.signOut();
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      
      _token = null;
      _currentUser = null;
      
      print("✅ Logged out successfully");
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  Future<void> _saveAuthData(String token, User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      
      _token = token;
      _currentUser = user;
      
      print("✅ Auth data saved");
    } catch (e) {
      print('Error saving auth data: $e');
    }
  }

  Map<String, String> getAuthHeaders() {
    if (_token == null) {
      return {'Content-Type': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email';
      case 'invalid-credential':
        return 'Invalid credentials';
      case 'operation-not-allowed':
        return 'Google Sign-In is not enabled';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found';
      case 'wrong-password':
        return 'Incorrect password';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}