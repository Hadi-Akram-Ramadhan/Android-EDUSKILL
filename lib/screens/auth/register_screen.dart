import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/tactile_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _nisCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final String _role = 'siswa';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nisCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Buat Akun Baru'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap (Hanya Huruf & Spasi)',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nisCtrl,
                decoration: InputDecoration(
                  labelText: 'NIS / NIM (Opsional)',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
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
                  labelText: 'Kata Sandi (Min. 6 Karakter)',
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
                label: 'DAFTAR SEKARANG',
                isLoading: auth.isLoading,
                onPressed: () async {
                  final router = GoRouter.of(context);
                  final ok = await auth.register(
                    name: _nameCtrl.text.trim(),
                    nisNim: _nisCtrl.text.trim(),
                    email: _emailCtrl.text.trim(),
                    password: _passwordCtrl.text,
                    role: _role,
                  );
                  if (ok && mounted) {
                    router.go('/');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
