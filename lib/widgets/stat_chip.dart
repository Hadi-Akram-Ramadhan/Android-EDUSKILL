import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class StatChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  final String? tooltip;
  final VoidCallback? onTap;

  const StatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
    this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 21),
              const SizedBox(width: 5),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textMain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
