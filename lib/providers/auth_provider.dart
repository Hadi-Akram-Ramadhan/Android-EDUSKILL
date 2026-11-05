import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.getSavedToken();
      if (token != null && token.isNotEmpty) {
        _apiService.setAuthToken(token);
        _user = await _authService.getMe();
      }
    } catch (_) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _authService.login(email, password);
      _user = result['user'] as UserModel?;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    String? nisNim,
    required String email,
    required String password,
    String? passwordConfirmation,
    String role = 'siswa',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _authService.register(
        name: name,
        nisNim: nisNim,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
      );
      _user = result['user'] as UserModel?;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  void updateUser(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  Future<bool> refillHearts() async {
    try {
      final res = await _apiService.post('/profile/refill-hearts');
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        if (_user != null) {
          final resData = data['data'] as Map<String, dynamic>;
          _user = UserModel(
            id: _user!.id,
            name: _user!.name,
            nisNim: _user!.nisNim,
            email: _user!.email,
            role: _user!.role,
            avatar: _user!.avatar,
            xp: _user!.xp,
            level: _user!.level,
            hearts: resData['hearts'] as int? ?? 5,
            streakCount: _user!.streakCount,
            gems: resData['gems'] as int? ?? _user!.gems,
          );
          notifyListeners();
        }
        return true;
      }
    } catch (_) {}
    return false;
  }
}

