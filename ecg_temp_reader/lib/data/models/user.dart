class AppUser {
  final int id;
  final String username;
  final String passwordHash;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.createdAt,
  });

  AppUser copyWith({
    int? id,
    String? username,
    String? passwordHash,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as int,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

