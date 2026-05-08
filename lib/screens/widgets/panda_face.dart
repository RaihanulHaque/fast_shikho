import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public API
// ─────────────────────────────────────────────────────────────────────────────

enum PandaExpression { idle, happy, sad, thinking }

/// Reactive panda face. Animates on expression change (bounce on happy,
/// blink every 3-5 s). Draws in a square, scales to [size].
class PandaFace extends StatefulWidget {
  final double size;
  final PandaExpression expression;

  const PandaFace({super.key, required this.size, this.expression = PandaExpression.idle});

  @override
  State<PandaFace> createState() => _PandaFaceState();
}

class _PandaFaceState extends State<PandaFace> with TickerProviderStateMixin {
  late AnimationController _blinkCtrl;
  late AnimationController _bounceCtrl;

  late Animation<double> _blinkAnim;
  late Animation<double> _bounceAnim;

  final _rng = math.Random();

  @override
  void initState() {
    super.initState();

    // Blink: 150 ms, scheduled every 3-5 s
    _blinkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _blinkAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_blinkCtrl);
    _scheduleBlink();

    // Bounce on happy: 500 ms TweenSequence
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.28), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.28, end: 0.88), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.06), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.00), weight: 25),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.linear));

    if (widget.expression == PandaExpression.happy) _bounceCtrl.forward(from: 0);
  }

  @override
  void didUpdateWidget(PandaFace old) {
    super.didUpdateWidget(old);
    if (widget.expression != old.expression && widget.expression == PandaExpression.happy) {
      _bounceCtrl.forward(from: 0);
    }
  }

  void _scheduleBlink() async {
    final delay = 3000 + _rng.nextInt(2000);
    await Future.delayed(Duration(milliseconds: delay));
    if (!mounted) return;
    await _blinkCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    await _blinkCtrl.reverse();
    _scheduleBlink();
  }

  @override
  void dispose() {
    _blinkCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_blinkAnim, _bounceAnim]),
      builder: (ctx, _) {
        return Transform.scale(
          scale: _bounceAnim.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _PandaFacePainter(
                expression: widget.expression,
                blink: _blinkAnim.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter — draws in a 100×100 normalised canvas
// ─────────────────────────────────────────────────────────────────────────────

class _PandaFacePainter extends CustomPainter {
  final PandaExpression expression;
  final double blink; // 0 = open, 1 = fully closed

  const _PandaFacePainter({required this.expression, required this.blink});

  // ── Coordinate constants (100×100 space) ──────────────────────────────────
  static const _cx = 50.0;
  static const _cy = 58.0; // head centre

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    _draw(canvas);
  }

  void _draw(Canvas canvas) {
    final dark = Paint()..color = const Color(0xFF2C2C2C);
    final isHappy = expression == PandaExpression.happy;
    final isSad = expression == PandaExpression.sad;

    // ── Ears ──────────────────────────────────────────────────────────────
    canvas.drawCircle(const Offset(_cx - 23, _cy - 19), 11, dark);
    canvas.drawCircle(const Offset(_cx + 23, _cy - 19), 11, dark);

    // ── Shadow ────────────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(_cx, _cy + 1.5), width: 66, height: 54),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // ── Face ──────────────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(_cx, _cy), width: 64, height: 52),
      Paint()..color = const Color(0xFFF5F5F5),
    );

    // ── Blush ─────────────────────────────────────────────────────────────
    final blushA = isHappy ? 0.75 : isSad ? 0.08 : 0.22;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(_cx - 22, _cy + 11), width: 9, height: 5),
      Paint()..color = const Color(0xFFFF69B4).withValues(alpha: blushA),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(_cx + 22, _cy + 11), width: 9, height: 5),
      Paint()..color = const Color(0xFFFF69B4).withValues(alpha: blushA),
    );

    // ── Eye patches (rotated ±20°) ────────────────────────────────────────
    canvas.save();
    canvas.translate(_cx - 13, _cy - 3);
    canvas.rotate(-0.349);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 18, height: 25), dark);
    canvas.restore();

    canvas.save();
    canvas.translate(_cx + 13, _cy - 3);
    canvas.rotate(0.349);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 18, height: 25), dark);
    canvas.restore();

    // ── Eyes ──────────────────────────────────────────────────────────────
    final eyeSc = (1.0 - blink).clamp(0.0, 1.0);
    final eyeBoost = isHappy ? 1.12 : 1.0; // slightly bigger when happy
    if (eyeSc > 0.05) {
      // Whites
      canvas.drawOval(Rect.fromCenter(center: const Offset(_cx - 13, _cy - 3), width: 8.5 * eyeSc * eyeBoost, height: 10.5 * eyeSc * eyeBoost), Paint()..color = Colors.white);
      canvas.drawOval(Rect.fromCenter(center: const Offset(_cx + 13, _cy - 3), width: 8.5 * eyeSc * eyeBoost, height: 10.5 * eyeSc * eyeBoost), Paint()..color = Colors.white);

      // Pupils (lower when sad, normal otherwise)
      final py = isSad ? _cy - 1.0 : _cy - 3.0;
      canvas.drawCircle(Offset(_cx - 13, py), 2.3 * eyeSc, dark);
      canvas.drawCircle(Offset(_cx + 13, py), 2.3 * eyeSc, dark);

      // Glints
      canvas.drawCircle(Offset(_cx - 14.5, _cy - 5), 1.1 * eyeSc, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(_cx + 11.5, _cy - 5), 1.1 * eyeSc, Paint()..color = Colors.white);
    } else {
      // Closed arc
      final cp = Paint()
        ..color = const Color(0xFF2C2C2C)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(Path()..moveTo(_cx - 17, _cy - 3)..quadraticBezierTo(_cx - 13, _cy + 1, _cx - 9, _cy - 3), cp);
      canvas.drawPath(Path()..moveTo(_cx + 9, _cy - 3)..quadraticBezierTo(_cx + 13, _cy + 1, _cx + 17, _cy - 3), cp);
    }

    // ── Worried brows (sad only) ──────────────────────────────────────────
    if (isSad) {
      final bp = Paint()
        ..color = const Color(0xFF2C2C2C)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(_cx - 19, _cy - 14), const Offset(_cx - 9, _cy - 11), bp);
      canvas.drawLine(const Offset(_cx + 9, _cy - 11), const Offset(_cx + 19, _cy - 14), bp);
    }

    // ── Nose ─────────────────────────────────────────────────────────────
    canvas.drawPath(
      Path()
        ..moveTo(_cx - 3, _cy + 8)
        ..quadraticBezierTo(_cx, _cy + 6, _cx + 3, _cy + 8)
        ..quadraticBezierTo(_cx + 3, _cy + 11, _cx, _cy + 12)
        ..quadraticBezierTo(_cx - 3, _cy + 11, _cx - 3, _cy + 8)
        ..close(),
      dark,
    );

    // ── Mouth ─────────────────────────────────────────────────────────────
    final mp = Paint()
      ..color = const Color(0xFF2C2C2C)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (isHappy) {
      // Open smile with tongue
      final clip = Path()
        ..moveTo(_cx - 10, _cy + 14)
        ..cubicTo(_cx - 10, _cy + 25, _cx + 10, _cy + 25, _cx + 10, _cy + 14)
        ..close();
      canvas.drawPath(clip, Paint()..color = const Color(0xFF4B0014));
      canvas.drawPath(
        Path()..moveTo(_cx - 10, _cy + 14)..cubicTo(_cx - 10, _cy + 25, _cx + 10, _cy + 25, _cx + 10, _cy + 14),
        mp,
      );
      canvas.save();
      canvas.clipPath(clip);
      canvas.drawOval(Rect.fromCenter(center: Offset(_cx, _cy + 22), width: 12, height: 8), Paint()..color = const Color(0xFFFFB3C1));
      canvas.restore();
    } else if (isSad) {
      // Frown
      canvas.drawPath(Path()..moveTo(_cx - 8, _cy + 18)..quadraticBezierTo(_cx, _cy + 14, _cx + 8, _cy + 18), mp);
    } else {
      // Idle / thinking: slight smile
      canvas.drawPath(Path()..moveTo(_cx - 8, _cy + 15)..quadraticBezierTo(_cx, _cy + 19, _cx + 8, _cy + 15), mp);
    }
  }

  @override
  bool shouldRepaint(_PandaFacePainter old) =>
      old.expression != expression || old.blink != blink;
}
