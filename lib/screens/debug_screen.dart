import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'dashboard_screen.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _debugInfo = 'Debug info will appear here...';

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      final currentUser = await AuthService.getCurrentUser();
      final userId = await AuthService.getCurrentUserId();
      
      setState(() {
        _debugInfo = '''
Auth Status Check:
- Is Logged In: $isLoggedIn
- Current User: ${currentUser?.nama ?? 'null'}
- User ID: $userId
- Email: ${currentUser?.email ?? 'null'}
        ''';
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Error checking auth status: $e';
      });
    }
  }

  Future<void> _clearAllData() async {
    try {
      await AuthService.logout();
      setState(() {
        _debugInfo = 'All data cleared successfully';
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Error clearing data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Screen'),
        backgroundColor: Colors.red[400],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Debug Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _debugInfo,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Debug Actions
            ElevatedButton(
              onPressed: _checkAuthStatus,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Check Auth Status', style: TextStyle(color: Colors.white)),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _clearAllData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear All Data', style: TextStyle(color: Colors.white)),
            ),
            
            const SizedBox(height: 30),
            
            const Text(
              'Direct Navigation Tests:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 10),
            
            // Navigation Tests
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('→ Login Screen'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text('→ Register Screen'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                );
              },
              child: const Text('→ Forgot Password Screen'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              },
              child: const Text('→ Dashboard Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
