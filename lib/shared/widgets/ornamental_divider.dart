import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class OrnamentalDivider extends StatelessWidget {
  const OrnamentalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: CustomPaint(
        painter: _OrnamentalPainter(color: AppColors.primary),
        size: Size.infinite,
      ),
    );
  }
}

class _OrnamentalPainter extends CustomPainter {
  final Color color;

  const _OrnamentalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..strokeWidth = 0.5;

    final diamondPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final cy = size.height / 2;
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), linePaint);

    const step = 28.0;
    const ds = 3.0;

    var x = step / 2;
    while (x < size.width) {
      final path = Path()
        ..moveTo(x, cy - ds)
        ..lineTo(x + ds, cy)
        ..lineTo(x, cy + ds)
        ..lineTo(x - ds, cy)
        ..close();
      canvas.drawPath(path, diamondPaint);
      x += step;
    }
  }

  @override
  bool shouldRepaint(covariant _OrnamentalPainter old) => old.color != color;
}
