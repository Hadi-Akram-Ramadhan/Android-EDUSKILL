class LeaderboardUserModel {
  final int rank;
  final int id;
  final String name;
  final String? avatar;
  final int xp;
  final int level;
  final int streakCount;

  LeaderboardUserModel({
    required this.rank,
    required this.id,
    required this.name,
    this.avatar,
    required this.xp,
    required this.level,
    required this.streakCount,
  });

  factory LeaderboardUserModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserModel(
      rank: json['rank'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Siswa',
      avatar: json['avatar'] as String?,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      streakCount: json['streak_count'] as int? ?? 0,
    );
  }
}
