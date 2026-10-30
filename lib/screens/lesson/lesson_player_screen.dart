import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/exercise_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/tactile_button.dart';

class LessonPlayerScreen extends StatefulWidget {
  final int lessonId;

  const LessonPlayerScreen({super.key, required this.lessonId});

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen>
    with TickerProviderStateMixin {
  final ApiService _api = ApiService();

  bool _isLoading = true;
  String? _error;
  String _lessonTitle = '';
  List<ExerciseModel> _exercises = [];
  int _currentIndex = 0;

  // Per-exercise answers (exercise_id -> user's answer)
  final Map<int, dynamic> _userAnswers = {};

  // Evaluation state from backend
  bool _checkedThisQuestion = false;
  String _explanation = '';
  bool _submitting = false;

  // Completion state
  bool _isCompleted = false;
  int _finalScore = 0;
  int _earnedXp = 0;

  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnim;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _feedbackAnim = CurvedAnimation(parent: _feedbackController, curve: Curves.easeOutBack);
    _loadLesson();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadLesson() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await _api.get('/lessons/${widget.lessonId}');
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final d = data['data'] as Map<String, dynamic>;
        _lessonTitle = d['title'] as String? ?? 'Latihan';
                final rawEx = d['exercises'] as List<dynamic>? ?? [];
        _exercises = rawEx.map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Save locally. Backend evaluates all answers once on final submit.
  void _checkAnswer() {
    if (_exercises.isEmpty) return;
    final currentEx = _exercises[_currentIndex];
    final answer = _userAnswers[currentEx.id];

    if (answer == null || (answer is String && answer.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih atau isi jawaban terlebih dahulu!'),
          duration: Duration(seconds: 1)),
      );
      return;
    }
    setState(() {
      _checkedThisQuestion = true;
      _explanation = 'Jawaban tersimpan. Hasil akan tampil setelah semua soal selesai.';
    });
    _feedbackController.forward(from: 0);
  }

  void _goNext() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _checkedThisQuestion = false;
      });
      _feedbackController.reset();
    } else {
      _finishLesson();
    }
  }

  void _finishLesson() {
    // Submit exactly once so hearts and XP are mutated only once.
    _submitFinal();
  }

  Future<void> _submitFinal() async {
    setState(() => _submitting = true);
    try {
      final allAnswers = _userAnswers.entries.map((e) => {
        'exercise_id': e.key,
        'answer': e.value,
      }).toList();

      final res = await _api.post('/lessons/${widget.lessonId}/submit', data: {
        'answers': allAnswers,
      });

      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final d = data['data'] as Map<String, dynamic>;
        final score = d['score'] as int? ?? 100;
        final xp = d['xp_earned'] as int? ?? 0;

        if (mounted) {
          context.read<AuthProvider>().checkAuthStatus();
          context.read<CourseProvider>().fetchCourses();
        }

        setState(() {
          _isCompleted = true;
          _finalScore = score;
          _earnedXp = xp;
          _submitting = false;
        });
      }
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.coralRed,
            content: Text('Gagal menyimpan progres: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 56, color: AppTheme.coralRed),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                TactileButton(label: 'Coba Lagi', onPressed: _loadLesson),
              ],
            ),
          ),
        ),
      );
    }

    if (_isCompleted) return _buildCelebration();

    final total = _exercises.length;
    final progress = total > 0 ? (_currentIndex + 1) / total : 0.0;
    final ex = _exercises.isNotEmpty ? _exercises[_currentIndex] : null;
    final user = context.watch<AuthProvider>().user;

    final feedbackColor = AppTheme.primaryBlue;
    final feedbackBg = AppTheme.primaryBlueLight;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Close + Progress + Hearts
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _confirmExit(context),
                    child: const Icon(Icons.close_rounded, size: 30, color: AppTheme.textMuted),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: AppTheme.borderSubtle,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.emeraldGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: AppTheme.coralRed, size: 22),
                      const SizedBox(width: 3),
                      Text(
                        '${user?.hearts ?? 5}',
                        style: const TextStyle(
                          color: AppTheme.coralRed,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: ex == null
                  ? const Center(child: Text('Tidak ada latihan.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Soal ${_currentIndex + 1} dari $total',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ex.prompt,
                            style: const TextStyle(
                              color: AppTheme.textMain,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              height: 1.3,
                            ),
                          ),
                          if (ex.codeSnippet != null && ex.codeSnippet!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [BoxShadow(color: Color(0xFF1E293B), offset: Offset(0, 5))],
                              ),
                              child: Text(
                                ex.codeSnippet!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: Color(0xFF38BDF8),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (!_checkedThisQuestion) _buildQuestion(ex),
                        ],
                      ),
                    ),
            ),

            // Feedback Drawer (slides up when answer checked)
            if (_checkedThisQuestion)
              ScaleTransition(
                scale: _feedbackAnim,
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  decoration: BoxDecoration(
                    color: feedbackBg,
                    border: Border(top: BorderSide(color: feedbackColor, width: 2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.save_alt_rounded,
                            color: feedbackColor,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'JAWABAN TERSIMPAN',
                            style: TextStyle(color: feedbackColor, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ],
                      ),
                      if (_explanation.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _explanation,
                          style: TextStyle(color: feedbackColor, fontWeight: FontWeight.w600, fontSize: 14, height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: _checkedThisQuestion
                    ? TactileButton(
                        label: _currentIndex < _exercises.length - 1 ? 'LANJUT' : 'SELESAIKAN',
                        color: feedbackColor,
                        shadowColor: AppTheme.primaryBlueShadow,
                        onPressed: _goNext,
                      )
                    : TactileButton(
                        label: 'PERIKSA',
                        color: AppTheme.primaryBlue,
                        shadowColor: AppTheme.primaryBlueShadow,
                        isLoading: _submitting,
                        onPressed: _checkAnswer,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(ExerciseModel ex) {
    switch (ex.questionType) {
      case 'fill_blank':
        return _buildFillBlank(ex);
      case 'code_ordering':
        return _buildCodeOrdering(ex);
      case 'interactive_3d':
        return _build3dInteractive(ex);
      case 'multiple_choice':
      case 'output_prediction':
      default:
        return _buildMultipleChoice(ex);
    }
  }

  Widget _buildMultipleChoice(ExerciseModel ex) {
    List<String> options = [];
    if (ex.options is List) {
      options = (ex.options as List).map((e) => e.toString()).toList();
    }
    final selected = _userAnswers[ex.id];

    return Column(
      children: options.map((opt) {
        final isSelected = selected == opt;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => setState(() => _userAnswers[ex.id] = opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlueLight : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle,
                  width: isSelected ? 2.5 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? AppTheme.primaryBlueShadow.withValues(alpha: 0.4) : const Color(0xFFCBD5E1),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryBlue : AppTheme.textMuted,
                        width: 2,
                      ),
                      color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                    ),
                    child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppTheme.primaryBlue : AppTheme.textMain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFillBlank(ExerciseModel ex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ketik jawaban kamu:',
          style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 10),
        TextField(
          onChanged: (val) => _userAnswers[ex.id] = val.trim(),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Tulis jawabanmu...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.borderSubtle, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2.5),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeOrdering(ExerciseModel ex) {
    final blocks = <Map<String, String>>[];
    if (ex.options is List) {
      for (final option in ex.options as List) {
        if (option is Map) {
          blocks.add({
            'id': option['id']?.toString() ?? '',
            'text': option['text']?.toString() ?? '',
          });
        } else {
          blocks.add({'id': '${blocks.length + 1}', 'text': option.toString()});
        }
      }
    }
    if (!_userAnswers.containsKey(ex.id)) {
      _userAnswers[ex.id] = List<String>.from(blocks.map((b) => b['id']!));
    }
    final currentOrder = _userAnswers[ex.id] as List<String>;
    final textById = {for (final block in blocks) block['id']!: block['text']!};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tahan dan seret balok kode ke urutan yang benar:',
          style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 12),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorderItem: (oldIdx, newIdx) {
            setState(() {
              final item = currentOrder.removeAt(oldIdx);
              currentOrder.insert(newIdx, item);
              _userAnswers[ex.id] = currentOrder;
            });
          },
          children: [
            for (int i = 0; i < currentOrder.length; i++)
              Material(
                key: ValueKey('$i-${currentOrder[i]}'),
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderSubtle, width: 2),
                    boxShadow: const [BoxShadow(color: Color(0xFFCBD5E1), offset: Offset(0, 3))],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.drag_indicator_rounded, color: AppTheme.textMuted, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          textById[currentOrder[i]] ?? currentOrder[i],
                          style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _build3dInteractive(ExerciseModel ex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Color(0xFF1E293B), offset: Offset(0, 6))],
          ),
          child: Stack(
            children: [
              Center(
                child: CustomPaint(
                  size: const Size(240, 160),
                  painter: _IsometricGridPainter(),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '3D Matrix  [X, Y, Z]',
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildMultipleChoice(ex),
      ],
    );
  }

  Widget _buildCelebration() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.amberBg,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.amberDark.withValues(alpha: 0.4), offset: const Offset(0, 8), blurRadius: 0)],
                ),
                child: const Icon(Icons.emoji_events_rounded, color: AppTheme.amberGold, size: 70),
              ),
              const SizedBox(height: 24),
              Text(_finalScore >= 60 ? 'MODUL SELESAI!' : 'COBA LAGI!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
              const SizedBox(height: 8),
              Text(
                _finalScore >= 60 ? '"$_lessonTitle" berhasil diselesaikan!' : 'Pelajari lagi "$_lessonTitle" dan coba ulangi.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppTheme.textMuted, height: 1.4),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _badge('NILAI', '$_finalScore%', AppTheme.emeraldGreen, AppTheme.emeraldBg),
                  const SizedBox(width: 12),
                  _badge('XP DIRAIH', '+$_earnedXp', AppTheme.primaryBlue, AppTheme.primaryBlueLight),
                ],
              ),
              const Spacer(),
              TactileButton(
                label: 'LANJUT BELAJAR',
                color: AppTheme.emeraldGreen,
                shadowColor: AppTheme.emeraldDark,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, String value, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 22)),
        ],
      ),
    );
  }

  void _confirmExit(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dlg) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari Latihan?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Progres yang belum diperiksa tidak akan tersimpan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlg),
            child: const Text('Lanjut Belajar',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(dlg); context.pop(); },
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

class _IsometricGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final targetPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    final startPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const tileW = 22.0;
    const tileH = 12.0;

    for (int i = -3; i <= 3; i++) {
      for (int j = -3; j <= 3; j++) {
        final x = cx + (i - j) * tileW;
        final y = cy + (i + j) * tileH;
        final path = Path()
          ..moveTo(x, y - tileH)
          ..lineTo(x + tileW, y)
          ..lineTo(x, y + tileH)
          ..lineTo(x - tileW, y)
          ..close();

        if (i == 2 && j == 1) {
          canvas.drawPath(path, targetPaint);
        } else if (i == 0 && j == 0) {
          canvas.drawPath(path, startPaint);
        }
        canvas.drawPath(path, gridPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
