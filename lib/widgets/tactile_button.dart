import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class TactileButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? shadowColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final bool outlined;
  final double? width;

  const TactileButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.shadowColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.outlined = false,
    this.width,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final bg = widget.outlined ? Colors.white : (widget.color ?? AppTheme.primaryBlue);
    final shadow = widget.outlined
        ? AppTheme.borderSubtle
        : (widget.shadowColor ?? AppTheme.primaryBlueShadow);
    final text = widget.outlined
        ? AppTheme.primaryBlue
        : (widget.textColor ?? Colors.white);

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        width: widget.width,
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? bg : AppTheme.borderSubtle,
          borderRadius: BorderRadius.circular(16),
          border: widget.outlined ? Border.all(color: AppTheme.borderSubtle, width: 2) : null,
          boxShadow: enabled && !_pressed
              ? [BoxShadow(color: shadow, offset: const Offset(0, 4), blurRadius: 0)]
              : null,
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 3, color: text))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: text, size: 20),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      widget.label.toUpperCase(),
                      style: TextStyle(
                        color: enabled ? text : AppTheme.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
