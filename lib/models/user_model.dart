class UserModel {
  final int? idUser;
  final String email;
  final String password;
  final String nama;
  final int beratBadan;
  final int aktivitas; // 1: ringan, 2: sedang, 3: berat
  final int targetHarian;
  final String createdAt;

  UserModel({
    this.idUser,
    required this.email,
    required this.password,
    required this.nama,
    required this.beratBadan,
    required this.aktivitas,
    required this.targetHarian,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_user': idUser,
      'email': email,
      'password': password,
      'nama': nama,
      'berat_badan': beratBadan,
      'aktivitas': aktivitas,
      'target_harian': targetHarian,
      'created_at': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      idUser: map['id_user'],
      email: map['email'],
      password: map['password'],
      nama: map['nama'],
      beratBadan: map['berat_badan'],
      aktivitas: map['aktivitas'],
      targetHarian: map['target_harian'],
      createdAt: map['created_at'],
    );
  }

  String get aktivitasText {
    switch (aktivitas) {
      case 1:
        return 'Ringan';
      case 2:
        return 'Sedang';
      case 3:
        return 'Berat';
      default:
        return 'Tidak Diketahui';
    }
  }

  static int calculateDailyTarget(int weight, int activityLevel) {
    // Base calculation: 35ml per kg body weight
    int baseTarget = weight * 35;
    
    // Adjust based on activity level
    switch (activityLevel) {
      case 1: // Ringan
        return baseTarget;
      case 2: // Sedang
        return (baseTarget * 1.2).round();
      case 3: // Berat
        return (baseTarget * 1.5).round();
      default:
        return baseTarget;
    }
  }
}
