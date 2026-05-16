import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Едва заметный геометрический орнамент (икат) поверх тёмного фона.
class IkatPatternBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const IkatPatternBackground({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _IkatPatternPainter(
              color: AppColors.accentBlue.withValues(alpha: 0.04),
            ),
          ),
        ),
        if (padding != null)
          Padding(padding: padding!, child: child)
        else
          child,
      ],
    );
  }
}

class _IkatPatternPainter extends CustomPainter {
  final Color color;

  _IkatPatternPainter({required this.color});

  static const double _step = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var x = -_step; x < size.width + _step; x += _step) {
      for (var y = -_step; y < size.height + _step; y += _step) {
        final cx = x + _step / 2;
        final cy = y + _step / 2;
        final path = Path()
          ..moveTo(cx, cy - 8)
          ..lineTo(cx + 8, cy)
          ..lineTo(cx, cy + 8)
          ..lineTo(cx - 8, cy)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IkatPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}
