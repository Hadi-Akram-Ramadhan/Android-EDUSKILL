class ExerciseModel {
  final int id;
  final String questionType;
  final String prompt;
  final String? codeSnippet;
  final dynamic options;
  final dynamic model3d;
  final int orderIndex;

  ExerciseModel({
    required this.id,
    required this.questionType,
    required this.prompt,
    this.codeSnippet,
    this.options,
    this.model3d,
    required this.orderIndex,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as int? ?? 0,
      questionType: json['question_type'] as String? ?? 'multiple_choice',
      prompt: json['prompt'] as String? ?? '',
      codeSnippet: json['code_snippet'] as String?,
      options: json['options'],
      model3d: json['model_3d'],
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }
}
