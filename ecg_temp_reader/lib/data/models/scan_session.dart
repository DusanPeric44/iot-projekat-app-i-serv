import 'dart:convert';

class ScanSession {
  final int id;
  final int userId;
  final DateTime createdAt;
  final double temperature;
  final List<double> ecgSamples;
  final String note;

  ScanSession({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.temperature,
    required this.ecgSamples,
    this.note = '',
  });

  ScanSession copyWith({
    int? id,
    int? userId,
    DateTime? createdAt,
    double? temperature,
    List<double>? ecgSamples,
    String? note,
  }) {
    return ScanSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      temperature: temperature ?? this.temperature,
      ecgSamples: ecgSamples ?? this.ecgSamples,
      note: note ?? this.note,
    );
  }

  factory ScanSession.fromMap(Map<String, Object?> map) {
    final payload = map['ecg_payload'] as String;
    final List<dynamic> decoded = jsonDecode(payload) as List<dynamic>;
    return ScanSession(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      temperature: (map['temperature'] as num).toDouble(),
      ecgSamples: decoded.map((e) => (e as num).toDouble()).toList(),
      note: (map['note'] as String?) ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'temperature': temperature,
      'ecg_payload': jsonEncode(ecgSamples),
      'note': note,
    };
  }
}

