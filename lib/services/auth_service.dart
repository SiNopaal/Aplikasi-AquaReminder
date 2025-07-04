import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../models/user_model.dart';
import 'database_helper.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _isLoggedInKey = 'is_logged_in';

  // Check if user is logged in - SIMPLIFIED
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      print('AuthService: Login status check: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      print('AuthService: Error checking login status: $e');
      return false; // Default to not logged in if error
    }
  }

  // Login user
  static Future<UserModel?> login(String email, String password) async {
    try {
      print('AuthService: Attempting login for email: $email');
      final user = await DatabaseHelper.instance.loginUser(email, password);
      if (user != null) {
        print('AuthService: Login successful for user: ${user.nama}');
        await _saveUserSession(user.idUser!);
        return user;
      }
      print('AuthService: Login failed - invalid credentials');
      return null;
    } catch (e) {
      print('AuthService: Login error: $e');
      return null;
    }
  }

  // Register user
  static Future<bool> register({
    required String email,
    required String password,
    required String nama,
    required int beratBadan,
    required int aktivitas,
  }) async {
    try {
      print('AuthService: Attempting registration for email: $email');
      
      // Check if email already exists
      final emailExists = await DatabaseHelper.instance.isEmailExists(email);
      if (emailExists) {
        print('AuthService: Registration failed - email already exists');
        return false;
      }

      final targetHarian = UserModel.calculateDailyTarget(beratBadan, aktivitas);
      final user = UserModel(
        email: email,
        password: password,
        nama: nama,
        beratBadan: beratBadan,
        aktivitas: aktivitas,
        targetHarian: targetHarian,
        createdAt: DateTime.now().toIso8601String(),
      );

      final success = await DatabaseHelper.instance.registerUser(user);
      print('AuthService: Registration ${success ? 'successful' : 'failed'}');
      return success;
    } catch (e) {
      print('AuthService: Registration error: $e');
      return false;
    }
  }

  // Save user session
  static Future<void> _saveUserSession(int userId) async {
    try {
      print('AuthService: Saving user session for userId: $userId');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_userIdKey, userId);
      await prefs.setBool(_isLoggedInKey, true);
      print('AuthService: User session saved successfully');
    } catch (e) {
      print('AuthService: Error saving session: $e');
    }
  }

  // Get current user
  static Future<UserModel?> getCurrentUser() async {
    try {
      print('AuthService: Getting current user');
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      if (!isLoggedIn) {
        print('AuthService: User not logged in');
        return null;
      }
      
      final userId = prefs.getInt(_userIdKey);
      if (userId != null) {
        final user = await DatabaseHelper.instance.getUserById(userId);
        print('AuthService: Retrieved user: ${user?.nama ?? 'null'}');
        return user;
      }
      return null;
    } catch (e) {
      print('AuthService: Error getting current user: $e');
      return null;
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      print('AuthService: Logging out user');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all preferences
      print('AuthService: User logged out successfully');
    } catch (e) {
      print('AuthService: Error during logout: $e');
    }
  }

  // Get current user ID
  static Future<int?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_userIdKey);
      return userId;
    } catch (e) {
      print('AuthService: Error getting user ID: $e');
      return null;
    }
  }

  // Generate random verification code
  static String _generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Store verification code temporarily
  static final Map<String, String> _verificationCodes = {};

  // Request password reset
  static Future<String?> requestPasswordReset(String email) async {
    try {
      print('AuthService: Requesting password reset for email: $email');
      final emailExists = await DatabaseHelper.instance.isEmailExists(email);
      if (!emailExists) {
        print('AuthService: Password reset failed - email not found');
        return null;
      }

      final verificationCode = _generateVerificationCode();
      _verificationCodes[email] = verificationCode;
      print('AuthService: Verification code generated: $verificationCode');

      return verificationCode;
    } catch (e) {
      print('AuthService: Error requesting password reset: $e');
      return null;
    }
  }

  // Verify reset code
  static bool verifyResetCode(String email, String code) {
    final isValid = _verificationCodes[email] == code;
    print('AuthService: Verifying reset code for $email: $isValid');
    return isValid;
  }

  // Reset password
  static Future<bool> resetPassword(String email, String newPassword) async {
    try {
      print('AuthService: Resetting password for email: $email');
      final user = await DatabaseHelper.instance.getUserByEmail(email);
      if (user == null) {
        print('AuthService: Password reset failed - user not found');
        return false;
      }

      final updatedUser = UserModel(
        idUser: user.idUser,
        email: user.email,
        password: newPassword,
        nama: user.nama,
        beratBadan: user.beratBadan,
        aktivitas: user.aktivitas,
        targetHarian: user.targetHarian,
        createdAt: user.createdAt,
      );

      await DatabaseHelper.instance.updateUser(updatedUser);
      
      // Remove verification code after successful reset
      _verificationCodes.remove(email);
      
      print('AuthService: Password reset successful');
      return true;
    } catch (e) {
      print('AuthService: Password reset failed with error: $e');
      return false;
    }
  }
}
