import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
  final _confirmPasswordCtrl = TextEditingController();

  String _selectedRole = 'siswa';
  String? _localError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nisCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit(AuthProvider auth) async {
    setState(() => _localError = null);

    final name = _nameCtrl.text.trim();
    final nis = _nisCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirmPassword = _confirmPasswordCtrl.text;

    if (name.isEmpty) {
      setState(() => _localError = 'Nama lengkap wajib diisi.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _localError = 'Format email tidak valid.');
      return;
    }
    if (password.length < 6) {
      setState(() => _localError = 'Kata sandi minimal 6 karakter.');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _localError = 'Konfirmasi kata sandi tidak cocok.');
      return;
    }

    final ok = await auth.register(
      name: name,
      nisNim: nis.isNotEmpty ? nis : null,
      email: email,
      password: password,
      passwordConfirmation: confirmPassword,
      role: _selectedRole,
    );

    if (ok && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final displayError = _localError ?? auth.errorMessage;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFE2E8F0),
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Icon Badge
                    Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Color(0xFF2563EB),
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Title & Subtitle
                    const Text(
                      'Buat Akun EduSkill',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Mulai belajar pemrograman dasar dengan metode interaktif.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error Box
                    if (displayError != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          border: Border.all(color: const Color(0xFFEF4444), width: 2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          displayError,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Field 1: Nama Lengkap
                    _buildLabel('NAMA LENGKAP (TANPA ANGKA / SIMBOL)'),
                    _buildInputField(
                      controller: _nameCtrl,
                      hintText: 'Contoh: Ahmad Subagyo',
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),

                    // Field 2: NIS (Nomor Induk Siswa - Opsional)
                    _buildLabel('NIS (Nomor Induk Siswa - Opsional)'),
                    _buildInputField(
                      controller: _nisCtrl,
                      hintText: 'Contoh: 202409001',
                    ),
                    const SizedBox(height: 16),

                    // Field 3: Email
                    _buildLabel('EMAIL'),
                    _buildInputField(
                      controller: _emailCtrl,
                      hintText: 'email@sekolah.sch.id',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Field 4: Peran Pengguna (Role Selector)
                    _buildLabel('PERAN PENGGUNA'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRoleCard(
                            role: 'siswa',
                            label: 'SISWA SMP / SMA',
                            icon: Icons.school_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRoleCard(
                            role: 'guru',
                            label: 'GURU / MENTOR',
                            icon: Icons.menu_book_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Field 5: Kata Sandi
                    _buildLabel('KATA SANDI (MIN. 6 KARAKTER)'),
                    _buildInputField(
                      controller: _passwordCtrl,
                      hintText: '••••••••',
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),

                    // Field 6: Konfirmasi Kata Sandi
                    _buildLabel('KONFIRMASI KATA SANDI'),
                    _buildInputField(
                      controller: _confirmPasswordCtrl,
                      hintText: '••••••••',
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    TactileButton(
                      label: 'DAFTAR SEKARANG',
                      isLoading: auth.isLoading,
                      onPressed: () => _handleSubmit(auth),
                    ),
                    const SizedBox(height: 18),

                    // Footer: Login link
                    Center(
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text.rich(
                          TextSpan(
                            text: 'Sudah punya akun? ',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: 'Masuk di Sini',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w800,
                                ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    bool autofocus = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofocus: autofocus,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return Material(
      color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
