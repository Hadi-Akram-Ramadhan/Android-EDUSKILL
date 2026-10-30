import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/course_model.dart';

class UnitBanner extends StatelessWidget {
  final UnitModel unit;
  final int unitNumber;

  const UnitBanner({super.key, required this.unit, required this.unitNumber});

  @override
  Widget build(BuildContext context) {
    final completed = unit.lessons.where((l) => l.isCompleted).length;
    final total = unit.lessons.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppTheme.primaryBlueShadow, offset: Offset(0, 5), blurRadius: 0)],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Text('$unitNumber', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('UNIT $unitNumber', style: const TextStyle(color: Color(0xFFBFDBFE), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(unit.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.emeraldGreen)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('$completed/$total', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
        ],
      ),
    );
  }
}
