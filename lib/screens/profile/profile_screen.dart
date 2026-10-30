import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/tactile_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // User Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.borderSubtle, width: 2),
            boxShadow: const [BoxShadow(color: Color(0xFFE2E8F0), offset: Offset(0, 5))],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primaryBlueLight,
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0] : 'U',
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                user?.name ?? 'Pengguna',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textMain),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              if (user?.nisNim != null) ...[
                const SizedBox(height: 4),
                Text('NIS/NIM: ${user!.nisNim}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Text('STATISTIK SAYA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8, color: AppTheme.textMuted)),
        const SizedBox(height: 12),

        // Stats Grid
        Row(
          children: [
            Expanded(child: _statBox('TOTAL XP', '${user?.xp ?? 0}', Icons.bolt_rounded, AppTheme.amberGold, AppTheme.amberBg)),
            const SizedBox(width: 12),
            Expanded(child: _statBox('LEVEL', '${user?.level ?? 1}', Icons.star_rounded, AppTheme.primaryBlue, AppTheme.primaryBlueLight)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _statBox('STREAK', '${user?.streakCount ?? 0} Hari', Icons.local_fire_department_rounded, AppTheme.coralRed, AppTheme.coralBg)),
            const SizedBox(width: 12),
            Expanded(child: _statBox('GEMS', '${user?.gems ?? 0}', Icons.diamond_rounded, const Color(0xFF06B6D4), const Color(0xFFECFEFF))),
          ],
        ),

        const SizedBox(height: 36),
        TactileButton(
          label: 'KELUAR AKUN',
          outlined: true,
          icon: Icons.logout_rounded,
          textColor: AppTheme.coralRed,
          onPressed: () => _confirmLogout(context, auth),
        ),
      ],
    );
  }

  Widget _statBox(String label, String value, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari Akun?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Kamu perlu masuk kembali untuk melanjutkan belajar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.coralRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
