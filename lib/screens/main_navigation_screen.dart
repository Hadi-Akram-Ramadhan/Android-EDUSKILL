import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/stat_chip.dart';
import 'home/roadmap_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'certificates/certificates_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    RoadmapScreen(),
    LeaderboardScreen(),
    CertificatesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        title: Row(
          children: [
            // Streak Fire 🔥
            StatChip(
              icon: Icons.local_fire_department_rounded,
              value: user?.streakCount ?? 0,
              color: AppTheme.amberGold,
              tooltip: 'Streak Harian',
            ),
            const Spacer(),
            // Gems 💎
            StatChip(
              icon: Icons.diamond_rounded,
              value: user?.gems ?? 0,
              color: const Color(0xFF06B6D4),
              tooltip: 'Gems',
            ),
            const SizedBox(width: 8),
            // Hearts ❤️
            StatChip(
              icon: Icons.favorite_rounded,
              value: user?.hearts ?? 5,
              color: AppTheme.coralRed,
              tooltip: 'Hati',
              onTap: () => _showHeartRefillDialog(context, auth),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.borderSubtle, height: 1),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded),
              activeIcon: Icon(Icons.map_rounded, color: AppTheme.primaryBlue),
              label: 'BELAJAR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.military_tech_rounded),
              activeIcon: Icon(Icons.military_tech_rounded, color: AppTheme.primaryBlue),
              label: 'PERINGKAT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.workspace_premium_rounded),
              activeIcon: Icon(Icons.workspace_premium_rounded, color: AppTheme.primaryBlue),
              label: 'SERTIFIKAT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              activeIcon: Icon(Icons.person_rounded, color: AppTheme.primaryBlue),
              label: 'PROFIL',
            ),
          ],
        ),
      ),
    );
  }

  void _showHeartRefillDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.favorite_rounded, color: AppTheme.coralRed, size: 28),
            SizedBox(width: 10),
            Text('Isi Ulang Hati', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Text(
          'Hati kamu saat ini: ${auth.user?.hearts ?? 5}/5 ❤️\n'
          'Gems kamu: ${auth.user?.gems ?? 0} 💎\n\n'
          'Isi penuh sekarang seharga 20 Gems?',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await auth.refillHearts();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: ok ? AppTheme.emeraldGreen : AppTheme.coralRed,
                    content: Text(
                      ok ? 'Hati berhasil diisi penuh (5/5)! ❤️' : 'Gems tidak cukup atau hati sudah penuh.',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emeraldGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Isi 20 Gems', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
