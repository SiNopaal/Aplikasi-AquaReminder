class ReminderModel {
  final int? idReminder;
  final int userId;
  final int intervalJam;
  final bool isActive;

  ReminderModel({
    this.idReminder,
    required this.userId,
    required this.intervalJam,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_reminder': idReminder,
      'user_id': userId,
      'interval_jam': intervalJam,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      idReminder: map['id_reminder'],
      userId: map['user_id'],
      intervalJam: map['interval_jam'],
      isActive: map['is_active'] == 1,
    );
  }
}
