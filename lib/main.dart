import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/debug_screen.dart'; // Import debug screen
import 'services/database_helper.dart';
import 'services/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize database
    await DatabaseHelper.instance.database;
    print('Database initialized successfully');
    
    // Initialize notifications
    await NotificationService.initialize();
    print('Notifications initialized successfully');
    
    // Request permissions
    await Permission.notification.request();
    print('Permissions requested');
    
  } catch (e) {
    print('Initialization error: $e');
  }
  
  runApp(const AquaReminderApp());
}

class AquaReminderApp extends StatelessWidget {
  const AquaReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaReminder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const DebugScreen(), // Use DebugScreen for testing
      debugShowCheckedModeBanner: false,
    );
  }
}
