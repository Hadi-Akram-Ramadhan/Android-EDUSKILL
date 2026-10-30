class CertificateModel {
  final int id;
  final String certCode;
  final String certHash;
  final int courseId;
  final String recipientName;
  final String courseTitle;
  final String? mentorName;
  final double scoreAverage;
  final String issueDate;
  final String? qrCodeUrl;
  final bool isValid;
  final Map<String, dynamic>? course;

  CertificateModel({
    required this.id,
    required this.certCode,
    required this.certHash,
    required this.courseId,
    required this.recipientName,
    required this.courseTitle,
    this.mentorName,
    required this.scoreAverage,
    required this.issueDate,
    this.qrCodeUrl,
    required this.isValid,
    this.course,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] as int? ?? 0,
      certCode: json['cert_code'] as String? ?? '',
      certHash: json['cert_hash'] as String? ?? '',
      courseId: json['course_id'] as int? ?? 0,
      recipientName: json['recipient_name'] as String? ?? '',
      courseTitle: json['course_title'] as String? ?? '',
      mentorName: json['mentor_name'] as String?,
      scoreAverage: double.tryParse(json['score_average'].toString()) ?? 0.0,
      issueDate: json['issue_date'] as String? ?? '',
      qrCodeUrl: json['qr_code_url'] as String?,
      isValid: json['is_valid'] as bool? ?? true,
      course: json['course'] as Map<String, dynamic>?,
    );
  }

  String get grade {
    if (scoreAverage >= 90.0) return 'A (Sangat Memuaskan)';
    if (scoreAverage >= 80.0) return 'B (Memuaskan)';
    if (scoreAverage >= 70.0) return 'C (Lulus)';
    return 'D (Cukup)';
  }
}
