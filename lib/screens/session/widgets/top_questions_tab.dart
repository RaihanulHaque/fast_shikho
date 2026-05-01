import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../models/top_question.dart';
import 'next_step_card.dart';

class TopQuestionsTab extends StatefulWidget {
  final List<TopQuestion> questions;
  final VoidCallback? onNext;
  final int stepIndex;
  final String nextStepName;
  final int nextStepXP;

  const TopQuestionsTab({
    super.key,
    required this.questions,
    this.onNext,
    this.stepIndex = 2,
    this.nextStepName = '',
    this.nextStepXP = 0,
  });

  @override
  State<TopQuestionsTab> createState() => _TopQuestionsTabState();
}

class _TopQuestionsTabState extends State<TopQuestionsTab> {
  static const _initialCount = 4;
  int _visibleCount = _initialCount;
  bool _expanded = false;
  int _answeredCount = 0;

  void _showMore() {
    setState(() {
      _visibleCount = widget.questions.length;
      _expanded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions;
    final remaining = q.length - _visibleCount;
    final showMoreBtn = !_expanded && q.length > _initialCount;
    final showNext = _expanded || q.length <= _initialCount;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: [
        // ── Header stat row ──────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary.withValues(alpha: 0.08), AppColors.primary.withValues(alpha: 0.04)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.15)),
          ),
          child: Row(children: [
            const Text('🏆', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('বিগত বছরের প্রশ্ন', style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text('${q.length} টি প্রশ্ন · সহজ থেকে কঠিন', style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            // Answered counter
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Container(
                key: ValueKey(_answeredCount),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _answeredCount > 0 ? AppColors.success.withValues(alpha: 0.1) : AppColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _answeredCount > 0 ? AppColors.success.withValues(alpha: 0.3) : AppColors.border),
                ),
                child: Text(
                  '$_answeredCount/$_visibleCount',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: _answeredCount > 0 ? AppColors.success : AppColors.textHint),
                ),
              ),
            ),
          ]),
        ),

        // ── Visible question cards ────────────────────────────────────────
        ...List.generate(_visibleCount.clamp(0, q.length), (i) {
          final isNew = _expanded && i >= _initialCount;
          return _AnimatedEntry(
            delay: isNew ? Duration(milliseconds: (i - _initialCount) * 80) : Duration.zero,
            child: _QuestionCard(
              question: q[i],
              index: i,
              onAnswered: () => setState(() => _answeredCount++),
            ),
          );
        }),

        // ── Show more button ──────────────────────────────────────────────
        if (showMoreBtn)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _ShowMoreButton(
              label: 'আরো $remaining টি প্রশ্ন দেখুন',
              onTap: _showMore,
            ),
          ),

        // ── Next step card ────────────────────────────────────────────────
        if (showNext && widget.onNext != null) ...[
          const SizedBox(height: 16),
          NextStepCard(
            stepIndex: widget.stepIndex,
            nextStepName: widget.nextStepName,
            xp: widget.nextStepXP,
            onNext: widget.onNext!,
          ),
        ],
      ],
    );
  }
}

// ─── Animated entry wrapper ───────────────────────────────────────────────────

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
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
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
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (ctx, child) => Transform.scale(
        scale: 1.0 + _pulse.value * 0.02,
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary.withValues(alpha: 0.12), AppColors.primary.withValues(alpha: 0.08)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.expand_more_rounded, color: AppColors.secondary, size: 22),
            const SizedBox(width: 8),
            Text(widget.label, style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
          ]),
        ),
      ),
    );
  }
}

// ─── Question Card ────────────────────────────────────────────────────────────

class _QuestionCard extends StatefulWidget {
  final TopQuestion question;
  final int index;
  final VoidCallback onAnswered;
  const _QuestionCard({required this.question, required this.index, required this.onAnswered});

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  String? _selectedMCQ;
  final Set<int> _selectedPoints = {};
  bool _revealed = false;

  void _reveal() {
    setState(() => _revealed = true);
    widget.onAnswered();
  }

  Color _diffColor() {
    switch (widget.question.difficulty) {
      case 'easy': return AppColors.easy;
      case 'medium': return AppColors.medium;
      case 'hard': return AppColors.hard;
      default: return AppColors.textHint;
    }
  }

  String _diffLabel() {
    switch (widget.question.difficulty) {
      case 'easy': return '⭐ সহজ';
      case 'medium': return '🔥 মাঝারি';
      case 'hard': return '💎 কঠিন';
      default: return widget.question.difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _revealed ? AppColors.primary.withValues(alpha: 0.2) : AppColors.border, width: _revealed ? 1 : 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Badges
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _diffColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _diffColor().withValues(alpha: 0.2)),
            ),
            child: Text(_diffLabel(), style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.w600, color: _diffColor())),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
            child: Text(q.source, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.secondary)),
          ),
          const Spacer(),
          // Question number
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text('${widget.index + 1}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
        ]),
        const SizedBox(height: 14),

        Text(q.questionText, style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.5)),
        const SizedBox(height: 16),

        if (q.questionType == 'mcq') _buildMCQ(q),
        if (q.questionType == 'short_answer' || q.questionType == 'creative') _buildShortAnswer(q),
        if (q.questionType == 'broad_answer') _buildBroadAnswer(q),

        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: _revealed
              ? Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.07), AppColors.secondary.withValues(alpha: 0.04)]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('💬', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(q.explanation, style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textPrimary, height: 1.6))),
                  ]),
                )
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }

  Widget _buildMCQ(TopQuestion q) {
    return Column(children: [
      ...q.options!.entries.map((e) {
        final sel = _selectedMCQ == e.key;
        final correct = e.key == q.correctOption;
        Color bg = AppColors.scaffoldBg;
        Color borderColor = AppColors.border;
        if (_revealed && correct) { bg = AppColors.success.withValues(alpha: 0.1); borderColor = AppColors.success; }
        else if (_revealed && sel && !correct) { bg = AppColors.error.withValues(alpha: 0.1); borderColor = AppColors.error; }
        else if (sel) { bg = AppColors.primary.withValues(alpha: 0.08); borderColor = AppColors.primary; }

        return GestureDetector(
          onTap: _revealed ? null : () { setState(() { _selectedMCQ = e.key; }); _reveal(); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: sel || (_revealed && correct) ? 1.5 : 0.5)),
            child: Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: sel ? AppColors.primary.withValues(alpha: 0.15) : AppColors.cardBg, borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(e.key, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: sel ? AppColors.primary : AppColors.textSecondary))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(e.value, style: GoogleFonts.hindSiliguri(fontSize: 14, color: AppColors.textPrimary))),
              if (_revealed && correct) const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              if (_revealed && sel && !correct) const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
            ]),
          ),
        );
      }),
    ]);
  }

  Widget _buildShortAnswer(TopQuestion q) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: !_revealed
          ? SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _reveal,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: Text('উত্তর দেখুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Text('উত্তর', style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.success)),
                ]),
                const SizedBox(height: 8),
                Text(q.answer ?? '', style: GoogleFonts.hindSiliguri(fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
              ]),
            ),
    );
  }

  Widget _buildBroadAnswer(TopQuestion q) {
    final points = q.selectablePoints ?? [];
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
        child: Text('✅ সঠিক বিবৃতিগুলো বাছাই করুন:', style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
      ),
      ...points.asMap().entries.map((e) {
        final sel = _selectedPoints.contains(e.key);
        Color bg = AppColors.scaffoldBg;
        Color borderColor = AppColors.border;
        if (_revealed && e.value.isCorrect) { bg = AppColors.success.withValues(alpha: 0.08); borderColor = AppColors.success; }
        else if (_revealed && sel && !e.value.isCorrect) { bg = AppColors.error.withValues(alpha: 0.08); borderColor = AppColors.error; }
        else if (sel) { bg = AppColors.primary.withValues(alpha: 0.06); borderColor = AppColors.primary; }

        return GestureDetector(
          onTap: _revealed ? null : () => setState(() { if (sel) { _selectedPoints.remove(e.key); } else { _selectedPoints.add(e.key); } }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: sel || _revealed ? 1.5 : 0.5)),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24, height: 24,
                decoration: BoxDecoration(color: sel ? AppColors.primary : AppColors.cardBg, borderRadius: BorderRadius.circular(7), border: Border.all(color: sel ? AppColors.primary : AppColors.border, width: 1.5)),
                child: sel ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(e.value.point, style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textPrimary))),
              if (_revealed && e.value.isCorrect) const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
              if (_revealed && !e.value.isCorrect) const Icon(Icons.cancel_rounded, color: AppColors.error, size: 18),
            ]),
          ),
        );
      }),
      if (!_revealed)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedPoints.isNotEmpty ? _reveal : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text('চেক করুন', style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
    ]);
  }
}
