class ConsumptionModel {
  final int? idLog;
  final int userId;
  final String waktu;
  final int volume;
  final String tanggal;

  ConsumptionModel({
    this.idLog,
    required this.userId,
    required this.waktu,
    required this.volume,
    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_log': idLog,
      'user_id': userId,
      'waktu': waktu,
      'volume': volume,
      'tanggal': tanggal,
    };
  }

  factory ConsumptionModel.fromMap(Map<String, dynamic> map) {
    return ConsumptionModel(
      idLog: map['id_log'],
      userId: map['user_id'],
      waktu: map['waktu'],
      volume: map['volume'],
      tanggal: map['tanggal'],
    );
  }
}
