import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../services/api_service.dart';

class CourseProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CourseModel> _courses = [];
  CourseModel? _activeCourse;
  bool _isLoading = false;
  String? _errorMessage;

  List<CourseModel> get courses => _courses;
  CourseModel? get activeCourse => _activeCourse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCourses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _apiService.get('/courses');
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final list = (data['data'] as List<dynamic>)
            .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _courses = list;
        if (_activeCourse == null && _courses.isNotEmpty) {
          await fetchCourseDetail(_courses.first.id);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCourseDetail(int courseId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _apiService.get('/courses/\$courseId');
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        _activeCourse = CourseModel.fromJson(data['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setActiveCourse(CourseModel course) {
    _activeCourse = course;
    fetchCourseDetail(course.id);
  }
}
