import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    if (data['success'] == true && data['data'] != null) {
      final userData = data['data'] as Map<String, dynamic>;
      final token = userData['token'] as String?;
      if (token != null) {
        await _saveToken(token);
        _api.setAuthToken(token);
        final user = UserModel.fromJson(userData['user'] as Map<String, dynamic>);
        await _saveUserData(user);
        return {'user': user, 'token': token};
      }
    }
    throw Exception(data['message'] ?? 'Login gagal');
  }

  Future<Map<String, dynamic>> register({
    required String name,
    String? nisNim,
    required String email,
    required String password,
    String? passwordConfirmation,
    String role = 'siswa',
  }) async {
    final response = await _api.post('/auth/register', data: {
      'name': name,
      if (nisNim != null && nisNim.isNotEmpty) 'nis_nim': nisNim,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation ?? password,
      'role': role,
    });
    final data = response.data as Map<String, dynamic>;
    if (data['success'] == true && data['data'] != null) {
      final userData = data['data'] as Map<String, dynamic>;
      final token = userData['token'] as String?;
      if (token != null) {
        await _saveToken(token);
        _api.setAuthToken(token);
        final user = UserModel.fromJson(userData['user'] as Map<String, dynamic>);
        await _saveUserData(user);
        return {'user': user, 'token': token};
      }
    }
    throw Exception(data['message'] ?? 'Registrasi gagal');
  }

  Future<UserModel?> getMe() async {
    try {
      final response = await _api.get('/auth/me');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return UserModel.fromJson((data['data'] as Map)['user'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    _api.clearAuthToken();
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> _saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, user.toJson().toString());
  }
}

