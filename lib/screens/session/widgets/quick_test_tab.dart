import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../models/quick_test.dart';

class QuickTestTab extends StatefulWidget {
  final List<QuickTestMCQ> questions;
  final int stepIndex;

  const QuickTestTab({
    super.key,
    required this.questions,
    this.stepIndex = 3,
  });

  @override
  State<QuickTestTab> createState() => _QuickTestTabState();
}

class _QuickTestTabState extends State<QuickTestTab> {
  static const _initialCount = 6;

  int _visibleCount = _initialCount;
  bool _expanded = false;

  // Duolingo-style live tracking
  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;
  int _maxStreak = 0;
  int _xp = 0;
  int _answered = 0;

  // Per-card answers (for final summary)
  final Map<int, bool> _results = {};

  bool get _allAnswered => _answered == widget.questions.length;

  void _onAnswer(int index, bool isCorrect) {
    if (_results.containsKey(index)) return; // already answered
    HapticFeedback.mediumImpact();
    setState(() {
      _results[index] = isCorrect;
      _answered++;
      if (isCorrect) {
        _correct++;
        _streak++;
        _maxStreak = _streak > _maxStreak ? _streak : _maxStreak;
        _xp += 10 + (_streak >= 3 ? 5 : 0); // streak bonus
      } else {
        _wrong++;
        _streak = 0;
        _xp += 2;
      }
    });
  }

  void _showMore() {
    setState(() {
      _visibleCount = widget.questions.length;
      _expanded = true;
    });
  }

  // Whether the first batch (_initialCount) is all answered
  bool get _firstBatchDone {
    final batchCount = _visibleCount.clamp(0, _initialCount);
    for (int i = 0; i < batchCount; i++) {
      if (!_results.containsKey(i)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions;
    final remaining = q.length - _visibleCount;
    final showMoreBtn = !_expanded && q.length > _initialCount && _firstBatchDone;

    return Column(children: [
      // ── Live score bar ────────────────────────────────────────────────
      _LiveScoreBar(
        correct: _correct,
        wrong: _wrong,
        streak: _streak,
        xp: _xp,
        total: q.length,
        answered: _answered,
      ),

      // ── Streak celebration ────────────────────────────────────────────
      AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: _streak >= 3
            ? _StreakBanner(streak: _streak)
            : const SizedBox.shrink(),
      ),

      // ── Final score card ──────────────────────────────────────────────
      AnimatedSize(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        child: _allAnswered
            ? _FinalScoreCard(correct: _correct, total: q.length, xp: _xp, maxStreak: _maxStreak)
            : const SizedBox.shrink(),
      ),

      // ── Question list ─────────────────────────────────────────────────
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            // Visible questions
            ...List.generate(_visibleCount.clamp(0, q.length), (i) {
              final isNew = _expanded && i >= _initialCount;
              return _AnimatedEntry(
                delay: isNew ? Duration(milliseconds: (i - _initialCount) * 80) : Duration.zero,
                child: _MCQCard(
                  question: q[i],
                  index: i,
                  result: _results[i],
                  onAnswer: (correct) => _onAnswer(i, correct),
                ),
              );
            }),

            // Show more button (only after first batch answered)
            if (showMoreBtn)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _ShowMoreButton(
                  label: 'আরো $remaining টি প্রশ্ন',
                  onTap: _showMore,
                ),
              ),

            // "Answer all to see more" hint
            if (!_expanded && q.length > _initialCount && !_firstBatchDone && !_allAnswered)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Center(
                  child: Text(
                    'প্রথম $_initialCount টি উত্তর দাও, তারপর আরো প্রশ্ন দেখবে',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.textHint),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    ]);
  }
}

// ─── Live Score Bar ───────────────────────────────────────────────────────────

class _LiveScoreBar extends StatelessWidget {
  final int correct, wrong, streak, xp, total, answered;
  const _LiveScoreBar({required this.correct, required this.wrong, required this.streak, required this.xp, required this.total, required this.answered});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        // Correct
        _StatPill(icon: '✅', value: correct.toString(), color: AppColors.success),
        const SizedBox(width: 8),
        // Wrong
        _StatPill(icon: '❌', value: wrong.toString(), color: AppColors.error),
        const SizedBox(width: 8),
        // Streak
        _StatPill(icon: '🔥', value: streak > 0 ? '$streak' : '-', color: AppColors.warning),
        const Spacer(),
        // XP
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Container(
            key: ValueKey(xp),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('⚡', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text('$xp XP', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        Text('$answered/$total', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String icon, value;
  final Color color;
  const _StatPill({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
      child: Container(
        key: ValueKey(value),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}

// ─── Streak Banner ────────────────────────────────────────────────────────────

class _StreakBanner extends StatelessWidget {
  final int streak;
  const _StreakBanner({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.warning.withValues(alpha: 0.15), AppColors.warning.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Text('🔥', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$streak ধারাবাহিক সঠিক!', style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.warning)),
          Text('দারুণ চলছে — থামো না!', style: GoogleFonts.hindSiliguri(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Text('+5 XP বোনাস', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warning)),
        ),
      ]),
    );
  }
}

// ─── Final Score Card ─────────────────────────────────────────────────────────

class _FinalScoreCard extends StatelessWidget {
  final int correct, total, xp, maxStreak;
  const _FinalScoreCard({required this.correct, required this.total, required this.xp, required this.maxStreak});

  String _grade() {
    final pct = correct / total;
    if (pct >= 0.9) return 'S';
    if (pct >= 0.75) return 'A';
    if (pct >= 0.6) return 'B';
    if (pct >= 0.4) return 'C';
    return 'D';
  }

  String _message() {
    final pct = correct / total;
    if (pct >= 0.9) return '🌟 অসাধারণ! তুমি মাস্টার!';
    if (pct >= 0.75) return '🎉 চমৎকার কাজ!';
    if (pct >= 0.6) return '👍 ভালো, আরো একটু চেষ্টা করো!';
    if (pct >= 0.4) return '💪 হাল ছাড়ো না!';
    return '📚 আরেকবার পড়ে চেষ্টা করো';
  }

  Color _gradeColor() {
    final g = _grade();
    if (g == 'S') return const Color(0xFF9B59B6);
    if (g == 'A') return AppColors.success;
    if (g == 'B') return AppColors.primary;
    if (g == 'C') return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (correct / total * 100).round();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gradeColor().withValues(alpha: 0.12), _gradeColor().withValues(alpha: 0.04)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gradeColor().withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(children: [
        // Grade circle
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: _gradeColor().withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: _gradeColor().withValues(alpha: 0.4), width: 2),
          ),
          child: Center(child: Text(_grade(), style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w900, color: _gradeColor()))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_message(), style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Row(children: [
            Text('$correct/$total সঠিক', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: _gradeColor())),
            const SizedBox(width: 8),
            Text('·', style: TextStyle(color: AppColors.textHint)),
            const SizedBox(width: 8),
            Text('$pct%', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Text('⚡ $xp XP', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            if (maxStreak >= 3) ...[
              const SizedBox(width: 8),
              Text('🔥 সর্বোচ্চ $maxStreak ধারা', style: GoogleFonts.hindSiliguri(fontSize: 11, color: AppColors.warning)),
            ],
          ]),
        ])),
      ]),
    );
  }
}

// ─── MCQ Card (immediate Duolingo-style feedback) ─────────────────────────────

class _MCQCard extends StatelessWidget {
  final QuickTestMCQ question;
  final int index;
  final bool? result; // null=unanswered, true=correct, false=wrong
  final void Function(bool) onAnswer;

  const _MCQCard({required this.question, required this.index, required this.result, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    final answered = result != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: answered
              ? (result! ? AppColors.success.withValues(alpha: 0.4) : AppColors.error.withValues(alpha: 0.4))
              : AppColors.border,
          width: answered ? 1.5 : 0.5,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        // Result ribbon
        if (answered)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: result! ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(children: [
              Text(result! ? '✅ সঠিক!' : '❌ ভুল!', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w700, color: result! ? AppColors.success : AppColors.error)),
              const Spacer(),
              Text(result! ? '+10 XP ⚡' : '+2 XP', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: result! ? AppColors.success : AppColors.textHint, fontWeight: FontWeight.w600)),
            ]),
          ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Question number + text
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(9)),
                child: Center(child: Text('${index + 1}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(question.question, style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.4))),
            ]),
            const SizedBox(height: 14),

            // Options
            ...question.options.entries.map((e) {
              final isCorrect = e.key == question.correctAnswer;
              // We don't track which option was selected in parent, so highlight correct + all after answer
              Color bg = AppColors.scaffoldBg;
              Color borderColor = AppColors.border;
              if (answered && isCorrect) { bg = AppColors.success.withValues(alpha: 0.1); borderColor = AppColors.success; }
              else if (answered) { bg = AppColors.scaffoldBg; borderColor = AppColors.border; }

              return GestureDetector(
                onTap: !answered ? () => onAnswer(isCorrect) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13), border: Border.all(color: borderColor, width: answered && isCorrect ? 1.5 : 0.5)),
                  child: Row(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: answered && isCorrect ? AppColors.success.withValues(alpha: 0.15) : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: answered && isCorrect ? AppColors.success : AppColors.border),
                      ),
                      child: Center(child: Text(e.key, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: answered && isCorrect ? AppColors.success : AppColors.textSecondary))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(e.value, style: GoogleFonts.hindSiliguri(fontSize: 14, color: answered && isCorrect ? AppColors.textPrimary : (answered ? AppColors.textHint : AppColors.textPrimary)))),
                    if (answered && isCorrect) const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                  ]),
                ),
              );
            }),

            // Explanation after answer
            if (answered && question.explanation != null)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.06), AppColors.secondary.withValues(alpha: 0.03)]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('💬', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(question.explanation!, style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.textSecondary, height: 1.5))),
                  ]),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}

// ─── Animated entry ───────────────────────────────────────────────────────────

class _AnimatedEntry extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _AnimatedEntry({required this.child, required this.delay});

  @override
  State<_AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<_AnimatedEntry> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (widget.delay == Duration.zero) {
      _ctrl.value = 1.0;
    } else {
      Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ─── Show More Button ─────────────────────────────────────────────────────────

class _ShowMoreButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _ShowMoreButton({required this.label, required this.onTap});

  @override
  State<_ShowMoreButton> createState() => _ShowMoreButtonState();
}

class _ShowMoreButtonState extends State<_ShowMoreButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(scale: 1.0 + _pulse.value * 0.025, child: child),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.06)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(widget.label, style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ]),
        ),
      ),
    );
  }
}
