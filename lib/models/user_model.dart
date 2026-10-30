class UserModel {
  final int id;
  final String name;
  final String? nisNim;
  final String email;
  final String role;
  final String? avatar;
  final int xp;
  final int level;
  final int hearts;
  final int streakCount;
  final int gems;

  UserModel({
    required this.id,
    required this.name,
    this.nisNim,
    required this.email,
    required this.role,
    this.avatar,
    required this.xp,
    required this.level,
    required this.hearts,
    required this.streakCount,
    required this.gems,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Pengguna',
      nisNim: json['nis_nim'] as String?,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'siswa',
      avatar: json['avatar'] as String?,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      hearts: json['hearts'] as int? ?? 5,
      streakCount: json['streak_count'] as int? ?? 0,
      gems: json['gems'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nis_nim': nisNim,
    'email': email,
    'role': role,
    'avatar': avatar,
    'xp': xp,
    'level': level,
    'hearts': hearts,
    'streak_count': streakCount,
    'gems': gems,
  };
}
