import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Loading screen
// ─────────────────────────────────────────────────────────────────────────────

class PandaLoadingScreen extends StatefulWidget {
  const PandaLoadingScreen({super.key});

  @override
  State<PandaLoadingScreen> createState() => _PandaLoadingScreenState();
}

class _PandaLoadingScreenState extends State<PandaLoadingScreen>
    with TickerProviderStateMixin {

  // ── Existing ──────────────────────────────────────────────────────────────
  late AnimationController _tiltController;
  late AnimationController _blinkController;
  late AnimationController _progressController;
  late AnimationController _dotController;
  late AnimationController _happyController;
  late AnimationController _earWiggleController;

  late Animation<double> _tiltAnim;
  late Animation<double> _blinkAnim;
  late Animation<double> _progressAnim;
  late Animation<double> _happyAnim;
  late Animation<double> _earWiggleAnim;

  // ── New: squash-jump ──────────────────────────────────────────────────────
  late AnimationController _squashController;
  late Animation<double> _squashScaleX;
  late Animation<double> _squashScaleY;
  late Animation<double> _squashTransY;

  // ── New: thinking pupils dart ─────────────────────────────────────────────
  late AnimationController _pupilDartController;
  late Animation<Offset> _pupilDartAnim;

  // ── New: floating question-mark bob ──────────────────────────────────────
  late AnimationController _questionController;
  late Animation<double> _questionAnim;

  // ── New: hearts + sparkle particles ─────────────────────────────────────
  late AnimationController _particleController;
  late Animation<double> _particleAnim;

  int _tipIndex = 0;
  int _activeDot = 0;

  final _tips = [
    'একটি টপিক একসাথে আপলোড করলে ভালো ফলাফল পাবে 📚',
    'সর্বোচ্চ ৬ পৃষ্ঠার নোট আপলোড করা যাবে',
    'হাতের লেখা পরিষ্কার হলে AI আরও ভালো বুঝতে পারে ✨',
  ];

  @override
  void initState() {
    super.initState();

    // ── Thinking tilt (3 s cycle) ──────────────────────────────────────────
    _tiltController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _tiltAnim = Tween<double>(begin: 0.0, end: 5 * math.pi / 180)
        .animate(CurvedAnimation(parent: _tiltController, curve: Curves.easeInOut));

    // ── Blink ─────────────────────────────────────────────────────────────
    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _blinkAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_blinkController);
    _scheduleBlink();

    // ── Progress 0 → 88 % in 18 s ─────────────────────────────────────────
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 18))
      ..forward();
    _progressAnim = Tween<double>(begin: 0.0, end: 0.88)
        .animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut));

    // ── Happy (600 ms one-shot) ────────────────────────────────────────────
    _happyController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _happyAnim = CurvedAnimation(parent: _happyController, curve: Curves.easeOut);

    // ── Ear wiggle (400 ms repeat) ────────────────────────────────────────
    _earWiggleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
      ..repeat(reverse: true);
    _earWiggleAnim = Tween<double>(begin: -1.0, end: 1.0)
        .animate(CurvedAnimation(parent: _earWiggleController, curve: Curves.easeInOut));

    // ── Squash-jump (800 ms one-shot) ─────────────────────────────────────
    _squashController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _squashScaleX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.20), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.20, end: 0.85), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.08), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.97), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.00), weight: 20),
    ]).animate(_squashController);
    _squashScaleY = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.75), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.75, end: 1.25), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.92), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.04), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 1.00), weight: 20),
    ]).animate(_squashController);
    _squashTransY = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 8.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -30.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -30.0, end: 4.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -2.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 0.0), weight: 20),
    ]).animate(_squashController);

    // ── Pupil dart (4 s step cycle) ───────────────────────────────────────
    _pupilDartController = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _pupilDartAnim = TweenSequence<Offset>([
      TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 25),
      TweenSequenceItem(tween: ConstantTween(const Offset(-2, -2)), weight: 25),
      TweenSequenceItem(tween: ConstantTween(const Offset(2, -2)), weight: 25),
      TweenSequenceItem(tween: ConstantTween(const Offset(0, 2)), weight: 25),
    ]).animate(_pupilDartController);

    // ── Question mark bob (2 s repeat) ────────────────────────────────────
    _questionController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _questionAnim = CurvedAnimation(parent: _questionController, curve: Curves.easeInOut);

    // ── Particles: hearts + sparkles (1.5 s one-shot) ─────────────────────
    _particleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _particleAnim = CurvedAnimation(parent: _particleController, curve: Curves.easeOut);

    // ── Trigger happy-state animations at 65% progress ────────────────────
    _progressController.addListener(() {
      if (_progressAnim.value > 0.65 && !_happyController.isAnimating && !_happyController.isCompleted) {
        _happyController.forward();
        _squashController.forward();
        _particleController.forward();
      }
    });

    // ── Dot ticker ────────────────────────────────────────────────────────
    _dotController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _dotController.reset();
          _dotController.forward();
          if (mounted) setState(() => _activeDot = (_activeDot + 1) % 3);
        }
      });
    _dotController.forward();

    _rotateTips();
  }

  void _scheduleBlink() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    await _blinkController.forward();
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    await _blinkController.reverse();
    _scheduleBlink();
  }

  void _rotateTips() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    setState(() => _tipIndex = (_tipIndex + 1) % _tips.length);
    _rotateTips();
  }

  @override
  void dispose() {
    _tiltController.dispose();
    _blinkController.dispose();
    _progressController.dispose();
    _dotController.dispose();
    _happyController.dispose();
    _earWiggleController.dispose();
    _squashController.dispose();
    _pupilDartController.dispose();
    _questionController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(children: [
          const Spacer(flex: 3),

          // REFINING / DONE badge
          AnimatedBuilder(
            animation: _happyAnim,
            builder: (ctx, _) {
              final isHappy = _happyAnim.value > 0.5;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isHappy ? AppColors.primary : AppColors.primary,
                    width: 1.5,
                  ),
                  color: isHappy ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: isHappy ? 0.4 : 0.2),
                      blurRadius: isHappy ? 24 : 16,
                      spreadRadius: isHappy ? 3 : 2,
                    ),
                  ],
                ),
                child: Text(
                  isHappy ? 'প্রায় হয়ে গেছে! 🎉' : 'REFINING ...',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              );
            },
          ),

          const Spacer(flex: 1),

          // ── Panda + particles ────────────────────────────────────────────
          SizedBox(
            width: 280,
            height: 260,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Particle overlay: hearts + sparkles
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _particleAnim,
                    builder: (ctx, _) => CustomPaint(
                      painter: _ParticlePainter(progress: _particleAnim.value),
                    ),
                  ),
                ),

                // Floating question mark (thinking state)
                AnimatedBuilder(
                  animation: Listenable.merge([_questionAnim, _happyAnim]),
                  builder: (ctx, _) {
                    final opacity = (1.0 - _happyAnim.value * 3.0).clamp(0.0, 1.0);
                    return Positioned(
                      top: 20 - _questionAnim.value * 6,
                      right: 55,
                      child: Opacity(
                        opacity: opacity,
                        child: Text(
                          '?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accentCyan,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Panda face (squash + tilt + all animations)
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _tiltAnim, _blinkAnim, _happyAnim, _earWiggleAnim,
                    _squashScaleX, _squashScaleY, _squashTransY, _pupilDartAnim,
                  ]),
                  builder: (ctx, _) {
                    final happy = _happyAnim.value;
                    final tilt = happy > 0.5 ? 0.0 : _tiltAnim.value;
                    final pupilOffset = happy > 0.5 ? Offset.zero : _pupilDartAnim.value;
                    return Transform.translate(
                      offset: Offset(0, _squashTransY.value),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.diagonal3Values(
                          _squashScaleX.value,
                          _squashScaleY.value,
                          1.0,
                        ),
                        child: Transform.rotate(
                          angle: tilt,
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: CustomPaint(
                              painter: _PandaPainter(
                                blinkProgress: _blinkAnim.value,
                                happyProgress: happy,
                                earWiggle: _earWiggleAnim.value,
                                pupilOffset: pupilOffset,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Dot indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final isActive = i == _activeDot;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 10 : 8,
                height: isActive ? 10 : 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.textHint,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)]
                      : null,
                ),
              );
            }),
          ),

          const SizedBox(height: 28),

          // Main text (reacts to state)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: AnimatedBuilder(
              animation: _happyAnim,
              builder: (ctx, _) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  key: ValueKey(_happyAnim.value > 0.5),
                  _happyAnim.value > 0.5
                      ? 'দারুণ হচ্ছে!\nআর একটু ধৈর্য ধরো 🐼'
                      : 'AI তোমার নোট পড়ছে...\nস্মার্ট প্যাকেজ বানাচ্ছে 🧠',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hindSiliguri(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: AnimatedBuilder(
              animation: _progressAnim,
              builder: (ctx, _) {
                return Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _progressAnim.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF58CC02), Color(0xFF72E118)],
                            ),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.6),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Spacer(flex: 3),

          // PRO TIP card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(anim),
                  child: child,
                ),
              ),
              child: Container(
                key: ValueKey(_tipIndex),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTintBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tips_and_updates_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('• PRO TIP',
                          style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(_tips[_tipIndex],
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, height: 1.4)),
                    ]),
                  ),
                ]),
              ),
            ),
          ),

          const SizedBox(height: 36),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Particle overlay painter — hearts + sparkles
// ─────────────────────────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final double progress; // 0→1 one-shot

  const _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final cx = size.width / 2;
    final pandaTop = size.height * 0.15; // approx top of panda head

    // ── Sparkles (pop out fast then fade) ─────────────────────────────────
    // Each sparkle: angle, distance, stagger delay
    const sparkles = [
      (angle: -0.7, dist: 90.0, delay: 0.0),   // top-left
      (angle: 0.7, dist: 90.0, delay: 0.08),    // top-right
      (angle: -1.4, dist: 70.0, delay: 0.12),   // left
      (angle: 1.4, dist: 70.0, delay: 0.16),    // right
      (angle: -0.3, dist: 110.0, delay: 0.04),  // upper-left far
      (angle: 0.3, dist: 110.0, delay: 0.06),   // upper-right far
    ];

    for (final s in sparkles) {
      final localP = ((progress - s.delay) / 0.45).clamp(0.0, 1.0);
      if (localP <= 0) continue;

      // Pop in fast (0→0.3) then fade out (0.3→1.0)
      final sizeScale = localP < 0.3
          ? localP / 0.3
          : 1.0 - (localP - 0.3) / 0.7;
      final opacity = sizeScale.clamp(0.0, 1.0);

      final sparkleX = cx + math.cos(s.angle - math.pi / 2) * s.dist * localP;
      final sparkleY = pandaTop + math.sin(s.angle - math.pi / 2) * s.dist * localP;

      _drawSparkle(
        canvas,
        Offset(sparkleX, sparkleY),
        8.0 * sizeScale,
        const Color(0xFFFFC800).withValues(alpha: opacity * 0.9),
      );
    }

    // ── Hearts (float up and fade) ─────────────────────────────────────────
    const hearts = [
      (startX: -38.0, endX: -50.0, delay: 0.05, color: Color(0xFFFF4B4B)),
      (startX: 0.0, endX: 10.0, delay: 0.20, color: Color(0xFFFF6B6B)),
      (startX: 38.0, endX: 52.0, delay: 0.35, color: Color(0xFFFF4B4B)),
    ];

    for (final h in hearts) {
      final localP = ((progress - h.delay) / 0.65).clamp(0.0, 1.0);
      if (localP <= 0) continue;

      final heartOpacity = localP < 0.6 ? localP / 0.6 : 1.0 - (localP - 0.6) / 0.4;
      final heartX = cx + h.startX + (h.endX - h.startX) * localP;
      final heartY = pandaTop - 10 - localP * 100;

      _drawHeart(
        canvas,
        Offset(heartX, heartY),
        10.0 * (1 - localP * 0.3),
        h.color.withValues(alpha: heartOpacity.clamp(0.0, 1.0)),
      );
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final r = i.isEven ? size : size * 0.4;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    final x = center.dx;
    final y = center.dy;
    path.moveTo(x, y + size * 0.3);
    path.cubicTo(x, y, x - size * 0.6, y - size * 0.3, x - size * 0.5, y - size * 0.65);
    path.cubicTo(x - size * 0.5, y - size * 1.1, x + size * 0.5, y - size * 1.1, x + size * 0.5, y - size * 0.65);
    path.cubicTo(x + size * 0.6, y - size * 0.3, x, y, x, y + size * 0.3);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Panda face painter — SVG-space coordinates (100 × 110)
// ─────────────────────────────────────────────────────────────────────────────

class _PandaPainter extends CustomPainter {
  final double blinkProgress; // 0=open, 1=closed
  final double happyProgress; // 0=thinking, 1=happy
  final double earWiggle;     // -1 to 1
  final Offset pupilOffset;   // dart offset when thinking

  const _PandaPainter({
    required this.blinkProgress,
    required this.happyProgress,
    required this.earWiggle,
    required this.pupilOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 110);
    _draw(canvas);
  }

  void _draw(Canvas canvas) {
    final dark = Paint()..color = const Color(0xFF2C2C2C);
    final happy = happyProgress;

    // ── Ears with wiggle ────────────────────────────────────────────────────
    final leftWiggle = happy > 0.5 ? earWiggle * -0.28 : 0.0;
    final rightWiggle = happy > 0.5 ? earWiggle * 0.28 : 0.0;

    canvas.save();
    canvas.translate(25, 45);
    canvas.rotate(leftWiggle);
    canvas.drawCircle(Offset.zero, 12, dark);
    canvas.restore();

    canvas.save();
    canvas.translate(75, 45);
    canvas.rotate(rightWiggle);
    canvas.drawCircle(Offset.zero, 12, dark);
    canvas.restore();

    // ── Head shadow ─────────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 66.5), width: 73, height: 59),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.13)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // ── Head (white) ────────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 65), width: 70, height: 56),
      Paint()..color = const Color(0xFFF5F5F5),
    );

    // ── Blush (dim=thinking, bright=happy) ──────────────────────────────────
    final blushAlpha = 0.2 + happy * 0.6;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(28, 72), width: 9.5, height: 5.5),
      Paint()..color = const Color(0xFFFF69B4).withValues(alpha: blushAlpha),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(72, 72), width: 9.5, height: 5.5),
      Paint()..color = const Color(0xFFFF69B4).withValues(alpha: blushAlpha),
    );

    // ── Eye patches (rotated) ───────────────────────────────────────────────
    canvas.save();
    canvas.translate(35, 60);
    canvas.rotate(-0.349); // −20°
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 20, height: 28), dark);
    canvas.restore();

    canvas.save();
    canvas.translate(65, 60);
    canvas.rotate(0.349); // +20°
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 20, height: 28), dark);
    canvas.restore();

    // ── Eyes ────────────────────────────────────────────────────────────────
    final eyeScale = (1.0 - blinkProgress).clamp(0.0, 1.0);
    if (eyeScale > 0.05) {
      // Whites
      canvas.drawOval(Rect.fromCenter(center: const Offset(35, 60), width: 9 * eyeScale, height: 11 * eyeScale), Paint()..color = Colors.white);
      canvas.drawOval(Rect.fromCenter(center: const Offset(65, 60), width: 9 * eyeScale, height: 11 * eyeScale), Paint()..color = Colors.white);

      // Pupils (dart when thinking)
      final lp = Offset(35 + pupilOffset.dx, 60 + pupilOffset.dy);
      final rp = Offset(65 + pupilOffset.dx, 60 + pupilOffset.dy);
      canvas.drawCircle(lp, 2.5 * eyeScale, dark);
      canvas.drawCircle(rp, 2.5 * eyeScale, dark);

      // Glints
      canvas.drawCircle(Offset(lp.dx - 1.5, lp.dy - 1.5), 1.2 * eyeScale, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(rp.dx - 1.5, rp.dy - 1.5), 1.2 * eyeScale, Paint()..color = Colors.white);
    } else {
      // Closed arc
      final cp = Paint()
        ..color = const Color(0xFF2C2C2C)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(Path()..moveTo(31, 60)..quadraticBezierTo(35, 63, 39, 60), cp);
      canvas.drawPath(Path()..moveTo(61, 60)..quadraticBezierTo(65, 63, 69, 60), cp);
    }

    // ── Nose ────────────────────────────────────────────────────────────────
    canvas.drawPath(
      Path()
        ..moveTo(47, 70)
        ..quadraticBezierTo(50, 68, 53, 70)
        ..quadraticBezierTo(53, 73, 50, 74)
        ..quadraticBezierTo(47, 73, 47, 70)
        ..close(),
      dark,
    );

    // ── Mouth ───────────────────────────────────────────────────────────────
    if (happy > 0.1) {
      // Open happy mouth
      final mouthClip = Path()..moveTo(40, 75)..cubicTo(40, 88, 60, 88, 60, 75)..close();
      canvas.drawPath(mouthClip, Paint()..color = const Color(0xFF4B0014));
      canvas.drawPath(
        Path()..moveTo(40, 75)..cubicTo(40, 88, 60, 88, 60, 75),
        Paint()..color = const Color(0xFF2C2C2C)..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
      );
      // Pink tongue
      canvas.save();
      canvas.clipPath(mouthClip);
      canvas.drawOval(Rect.fromCenter(center: const Offset(50, 84), width: 14, height: 10), Paint()..color = const Color(0xFFFFB3C1));
      canvas.restore();
    } else {
      // Thinking: slight smile
      canvas.drawPath(
        Path()..moveTo(45, 78)..quadraticBezierTo(50, 82, 55, 78),
        Paint()..color = const Color(0xFF2C2C2C)..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_PandaPainter old) =>
      old.blinkProgress != blinkProgress ||
      old.happyProgress != happyProgress ||
      old.earWiggle != earWiggle ||
      old.pupilOffset != pupilOffset;
}
