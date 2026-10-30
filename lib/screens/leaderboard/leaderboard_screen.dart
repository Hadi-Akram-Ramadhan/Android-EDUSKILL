import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/leaderboard_user_model.dart';
import '../../services/api_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ApiService _api = ApiService();
  String _type = 'global'; // 'global' or 'streak'
  bool _isLoading = true;
  String? _error;
  List<LeaderboardUserModel> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await _api.get('/leaderboard', queryParameters: {'type': _type});
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final list = (data['data']['leaderboard'] as List<dynamic>?) ?? [];
        _leaderboard = list.map((e) => LeaderboardUserModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Filter: XP Global vs Streak Harian
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.slateBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderSubtle, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _tabButton('XP Global', 'global', Icons.bolt_rounded),
                ),
                Expanded(
                  child: _tabButton('Streak Harian', 'streak', Icons.local_fire_department_rounded),
                ),
              ],
            ),
          ),
        ),

        // List / Podium
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
              : _error != null
                  ? Center(child: Text(_error!))
                  : RefreshIndicator(
                      onRefresh: _fetchLeaderboard,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          if (_leaderboard.length >= 3) _buildPodium(),
                          const SizedBox(height: 16),
                          ..._leaderboard.map((u) => _buildUserRow(u)),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _tabButton(String label, String value, IconData icon) {
    final active = _type == value;
    return GestureDetector(
      onTap: () {
        if (_type != value) {
          setState(() => _type = value);
          _fetchLeaderboard();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active ? [const BoxShadow(color: Color(0xFFE2E8F0), offset: Offset(0, 2), blurRadius: 2)] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: active ? AppTheme.primaryBlue : AppTheme.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: active ? AppTheme.primaryBlue : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium() {
    final first = _leaderboard[0];
    final second = _leaderboard.length > 1 ? _leaderboard[1] : null;
    final third = _leaderboard.length > 2 ? _leaderboard[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0xFFE2E8F0), offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null) _podiumItem(second, 2, 85, const Color(0xFF94A3B8)),
          _podiumItem(first, 1, 110, AppTheme.amberGold),
          if (third != null) _podiumItem(third, 3, 70, const Color(0xFFD97706)),
        ],
      ),
    );
  }

  Widget _podiumItem(LeaderboardUserModel user, int rank, double height, Color crownColor) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 32 : 26,
              backgroundColor: crownColor.withValues(alpha: 0.2),
              child: Text(
                user.name.isNotEmpty ? user.name[0] : 'S',
                style: TextStyle(fontWeight: FontWeight.w900, color: crownColor, fontSize: rank == 1 ? 24 : 18),
              ),
            ),
            Positioned(
              top: -14,
              child: Icon(Icons.military_tech_rounded, color: crownColor, size: rank == 1 ? 26 : 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            user.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _type == 'streak' ? '${user.streakCount} Hari 🔥' : '${user.xp} XP ⚡',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: crownColor),
        ),
        const SizedBox(height: 6),
        Container(
          width: 65,
          height: height,
          decoration: BoxDecoration(
            color: crownColor.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: crownColor, width: 2),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: crownColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserRow(LeaderboardUserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0xFFF1F5F9), offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '${user.rank}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.textMuted),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryBlueLight,
            child: Text(
              user.name.isNotEmpty ? user.name[0] : 'S',
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textMain),
                ),
                Text(
                  'Level ${user.level}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          Text(
            _type == 'streak' ? '${user.streakCount} Hari' : '${user.xp} XP',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textMain),
          ),
        ],
      ),
    );
  }
}
