import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/consumption_model.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserModel? _user;
  List<ConsumptionModel> _todayConsumption = [];
  int _totalConsumed = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) {
        // User not logged in, redirect to login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        return;
      }

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final consumption = await DatabaseHelper.instance.getConsumptionByDateAndUser(today, user.idUser!);
      
      int total = 0;
      for (var item in consumption) {
        total += item.volume;
      }

      setState(() {
        _user = user;
        _todayConsumption = consumption;
        _totalConsumed = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
      );
    }
  }

  Future<void> _addWaterIntake() async {
    if (_user == null) return;

    final result = await showDialog<int>(
      context: context,
      builder: (context) => const WaterIntakeDialog(),
    );

    if (result != null && result > 0) {
      final now = DateTime.now();
      final consumption = ConsumptionModel(
        userId: _user!.idUser!,
        waktu: DateFormat('HH:mm:ss').format(now),
        volume: result,
        tanggal: DateFormat('yyyy-MM-dd').format(now),
      );

      await DatabaseHelper.instance.insertConsumption(consumption);
      await _loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil mencatat ${result}ml air'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  double get _progressPercentage {
    if (_user == null) return 0.0;
    return (_totalConsumed / _user!.targetHarian).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Halo, ${_user!.nama}'),
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) => _loadData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Progress Hari Ini',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Circular Progress
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: _progressPercentage,
                              strokeWidth: 12,
                              backgroundColor: Colors.blue[100],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue[400]!,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '${(_progressPercentage * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              Text(
                                '$_totalConsumed ml',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      Text(
                        'Target: ${_user!.targetHarian} ml',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue[600],
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: _progressPercentage,
                        backgroundColor: Colors.blue[100],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue[400]!,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.add_circle,
                      title: 'Catat Minum',
                      subtitle: 'Tambah konsumsi air',
                      onTap: _addWaterIntake,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.notifications,
                      title: 'Pengingat',
                      subtitle: 'Atur notifikasi',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Today's History
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
                        'Riwayat Hari Ini',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      if (_todayConsumption.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Belum ada konsumsi air hari ini',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _todayConsumption.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = _todayConsumption[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Icon(
                                  Icons.water_drop,
                                  color: Colors.blue[400],
                                ),
                              ),
                              title: Text('${item.volume} ml'),
                              subtitle: Text('Waktu: ${item.waktu}'),
                              trailing: Icon(
                                Icons.check_circle,
                                color: Colors.green[400],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWaterIntake,
        backgroundColor: Colors.blue[400],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.blue[400],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaterIntakeDialog extends StatefulWidget {
  const WaterIntakeDialog({super.key});

  @override
  State<WaterIntakeDialog> createState() => _WaterIntakeDialogState();
}

class _WaterIntakeDialogState extends State<WaterIntakeDialog> {
  int _selectedVolume = 250;
  final List<int> _quickVolumes = [100, 200, 250, 300, 500];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Catat Konsumsi Air'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pilih volume air yang diminum:',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          
          // Quick selection buttons
          Wrap(
            spacing: 10,
            children: _quickVolumes.map((volume) {
              return ChoiceChip(
                label: Text('${volume}ml'),
                selected: _selectedVolume == volume,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedVolume = volume;
                    });
                  }
                },
                selectedColor: Colors.blue[200],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Custom input
          TextFormField(
            initialValue: _selectedVolume.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Volume (ml)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixText: 'ml',
            ),
            onChanged: (value) {
              final volume = int.tryParse(value);
              if (volume != null && volume > 0) {
                setState(() {
                  _selectedVolume = volume;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedVolume),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[400],
            foregroundColor: Colors.white,
          ),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
