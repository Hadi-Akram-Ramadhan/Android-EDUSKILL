import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/course_model.dart';

class RoadmapNode extends StatelessWidget {
  final LessonModel lesson;
  final int index;
  final VoidCallback onTap;

  const RoadmapNode({super.key, required this.lesson, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCurrent = lesson.isUnlocked && !lesson.isCompleted;
    final isDone = lesson.isCompleted;
    final color = isDone ? AppTheme.amberGold : (isCurrent ? AppTheme.emeraldGreen : const Color(0xFFCBD5E1));
    final shadow = isDone ? AppTheme.amberDark : (isCurrent ? AppTheme.emeraldDark : const Color(0xFF94A3B8));
    final icon = isDone ? Icons.check_rounded : (isCurrent ? Icons.play_arrow_rounded : Icons.lock_rounded);

    // Winding path: alternate x offsets for a Duolingo-like progression
    final offsets = [0.0, 56.0, 86.0, 56.0, 0.0, -56.0, -86.0, -56.0];
    final offsetX = offsets[index % offsets.length];

    return Semantics(
      button: lesson.isUnlocked,
      label: lesson.title,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            if (isCurrent) ...[
              Transform.translate(
                offset: Offset(offsetX, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.emeraldGreen, width: 1.5),
                  ),
                  child: const Text(
                    'MULAI DI SINI',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.emeraldDark, letterSpacing: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
            Transform.translate(
              offset: Offset(offsetX, 0),
              child: GestureDetector(
                onTap: lesson.isUnlocked ? onTap : null,
                child: Container(
                  width: isCurrent ? 78 : 70,
                  height: isCurrent ? 78 : 70,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 6), blurRadius: 0)],
                    border: isCurrent ? Border.all(color: Colors.white, width: 5) : null,
                  ),
                  child: Icon(icon, color: Colors.white, size: isCurrent ? 36 : 32),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Transform.translate(
              offset: Offset(offsetX, 0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  lesson.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: lesson.isUnlocked ? AppTheme.textMain : AppTheme.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
