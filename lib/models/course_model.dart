class CourseModel {
  final int id;
  final String title;
  final String slug;
  final String? description;
  final String? category;
  final String? targetAudience;
  final String? thumbnail;
  final String? level;
  final int totalXp;
  final int totalLessons;
  final int completedLessons;
  final int progressPercentage;
  final Map<String, dynamic>? mentor;
  final List<UnitModel> units;

  CourseModel({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.category,
    this.targetAudience,
    this.thumbnail,
    this.level,
    required this.totalXp,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPercentage,
    this.mentor,
    this.units = const [],
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    var rawUnits = json['units'] as List<dynamic>? ?? [];
    List<UnitModel> unitsList = rawUnits
        .map((u) => UnitModel.fromJson(u as Map<String, dynamic>))
        .toList();

    return CourseModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String?,
      targetAudience: json['target_audience'] as String?,
      thumbnail: json['thumbnail'] as String?,
      level: json['level'] as String?,
      totalXp: json['total_xp'] as int? ?? 0,
      totalLessons: json['total_lessons'] as int? ?? 0,
      completedLessons: json['completed_lessons'] as int? ?? 0,
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      mentor: json['mentor'] as Map<String, dynamic>?,
      units: unitsList,
    );
  }
}

class UnitModel {
  final int id;
  final String title;
  final String? description;
  final int orderIndex;
  final List<LessonModel> lessons;

  UnitModel({
    required this.id,
    required this.title,
    this.description,
    required this.orderIndex,
    required this.lessons,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    var rawLessons = json['lessons'] as List<dynamic>? ?? [];
    List<LessonModel> lessonsList = rawLessons
        .map((l) => LessonModel.fromJson(l as Map<String, dynamic>))
        .toList();

    return UnitModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      lessons: lessonsList,
    );
  }
}

class LessonModel {
  final int id;
  final String title;
  final String? slug;
  final String? description;
  final String? type;
  final int xpReward;
  final int orderIndex;
  final bool isCompleted;
  final bool isUnlocked;
  final int score;

  LessonModel({
    required this.id,
    required this.title,
    this.slug,
    this.description,
    this.type,
    required this.xpReward,
    required this.orderIndex,
    required this.isCompleted,
    required this.isUnlocked,
    required this.score,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'lesson',
      xpReward: json['xp_reward'] as int? ?? 15,
      orderIndex: json['order_index'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
    );
  }
}
