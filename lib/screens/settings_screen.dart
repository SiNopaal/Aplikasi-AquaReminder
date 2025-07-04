import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/reminder_model.dart';
import '../models/consumption_model.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import 'profile_screen.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserModel? _user;
  ReminderModel? _reminder;
  List<ConsumptionModel> _weeklyData = [];
  bool _isLoading = true;
  int _reminderInterval = 2; // Default 2 hours

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) return;

      final reminder = await DatabaseHelper.instance.getActiveReminderByUser(user.idUser!);
      
      // Get weekly data (last 7 days)
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 6));
      final weeklyConsumption = await DatabaseHelper.instance.getWeeklyConsumptionByUser(
        DateFormat('yyyy-MM-dd').format(startDate),
        DateFormat('yyyy-MM-dd').format(endDate),
        user.idUser!,
      );

      setState(() {
        _user = user;
        _reminder = reminder;
        _weeklyData = weeklyConsumption;
        _reminderInterval = reminder?.intervalJam ?? 2;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateReminderInterval(int hours) async {
    if (_user == null) return;

    try {
      if (_reminder != null) {
        final updatedReminder = ReminderModel(
          idReminder: _reminder!.idReminder,
          userId: _user!.idUser!,
          intervalJam: hours,
          isActive: true,
        );
        await DatabaseHelper.instance.updateReminder(updatedReminder);
      } else {
        final newReminder = ReminderModel(
          userId: _user!.idUser!,
          intervalJam: hours,
          isActive: true,
        );
        await DatabaseHelper.instance.insertReminder(newReminder);
      }

      // Update notifications
      await NotificationService.cancelAllNotifications();
      await NotificationService.scheduleRepeatingNotification(
        id: 1,
        title: 'Waktunya Minum Air!',
        body: 'Jangan lupa minum air untuk menjaga hidrasi tubuh Anda',
        intervalHours: hours,
      );

      setState(() {
        _reminderInterval = hours;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengingat berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  List<FlSpot> _getWeeklyChartData() {
    final Map<String, int> dailyTotals = {};
    
    // Initialize with 0 for each day
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      dailyTotals[dateStr] = 0;
    }
    
    // Sum up consumption for each day
    for (var consumption in _weeklyData) {
      dailyTotals[consumption.tanggal] = 
          (dailyTotals[consumption.tanggal] ?? 0) + consumption.volume;
    }
    
    final spots = <FlSpot>[];
    int index = 0;
    dailyTotals.forEach((date, total) {
      spots.add(FlSpot(index.toDouble(), total.toDouble()));
      index++;
    });
    
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            if (_user != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil Pengguna',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(Icons.monitor_weight, color: Colors.blue[400]),
                          const SizedBox(width: 10),
                          Text('Berat Badan: ${_user!.beratBadan} kg'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.fitness_center, color: Colors.blue[400]),
                          const SizedBox(width: 10),
                          Text('Aktivitas: ${_user!.aktivitasText}'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.water_drop, color: Colors.blue[400]),
                          const SizedBox(width: 10),
                          Text('Target Harian: ${_user!.targetHarian} ml'),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            ).then((_) => _loadData());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[400],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Edit Profil'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Reminder Settings Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengaturan Pengingat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Interval Pengingat: $_reminderInterval jam',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: _reminderInterval.toDouble(),
                      min: 1,
                      max: 6,
                      divisions: 5,
                      label: '$_reminderInterval jam',
                      activeColor: Colors.blue[400],
                      onChanged: (value) {
                        setState(() {
                          _reminderInterval = value.round();
                        });
                      },
                      onChangeEnd: (value) {
                        _updateReminderInterval(value.round());
                      },
                    ),
                    Text(
                      'Pengingat akan muncul setiap $_reminderInterval jam',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Weekly Chart Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grafik Konsumsi Mingguan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${(value / 1000).toStringAsFixed(1)}L',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                  final index = value.toInt();
                                  if (index >= 0 && index < days.length) {
                                    return Text(
                                      days[index],
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _getWeeklyChartData(),
                              isCurved: true,
                              color: Colors.blue[400],
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue[100],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
