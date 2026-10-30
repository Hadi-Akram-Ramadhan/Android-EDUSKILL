import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/tactile_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // App Brand
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [BoxShadow(color: AppTheme.primaryBlueShadow, offset: Offset(0, 4))],
                    ),
                    child: const Icon(Icons.code_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Text('EduSkill', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Masuk ke Akun', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
              const SizedBox(height: 6),
              const Text('Lanjutkan streak belajar coding kamu hari ini!', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
              const SizedBox(height: 28),

              // Form
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 24),

              if (auth.errorMessage != null) ...[
                Text(auth.errorMessage!, style: const TextStyle(color: AppTheme.coralRed, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
              ],

              TactileButton(
                label: 'MASUK SEKARANG',
                isLoading: auth.isLoading,
                onPressed: () => auth.login(_emailCtrl.text.trim(), _passwordCtrl.text),
              ),

              const SizedBox(height: 32),
              const Center(
                child: Text('— ATAU 1-KLIK AKUN DEMO —',
                  style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8)),
              ),
              const SizedBox(height: 16),

              // Quick 1-Click Demo Buttons
              _demoButton('Siswa SMP (Budi Santoso)', 'budi@smp.sch.id', 'password', auth),
              const SizedBox(height: 8),
              _demoButton('Siswa SMA (Siti Nurhaliza)', 'siti@sma.sch.id', 'password', auth),
              const SizedBox(height: 8),
              _demoButton('Guru Mentor (Pak Hendra)', 'guru@kodein.id', 'password', auth),

              const SizedBox(height: 28),
              Center(
                child: GestureDetector(
                  onTap: () => context.push('/register'),
                  child: const Text.rich(
                    TextSpan(
                      text: 'Belum punya akun? ',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Daftar di sini',
                          style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _demoButton(String label, String email, String password, AuthProvider auth) {
    return OutlinedButton(
      onPressed: auth.isLoading ? null : () => auth.login(email, password),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppTheme.borderSubtle, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: AppTheme.amberGold, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textMain, fontSize: 13))),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
        ],
      ),
    );
  }
}
