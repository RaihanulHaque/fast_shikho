import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../models/practice_example.dart';
import 'next_step_card.dart';

class PracticeTab extends StatefulWidget {
  final List<PracticeExample> problems;
  final VoidCallback? onNext;
  final int stepIndex;
  final String nextStepName;
  final int nextStepXP;

  const PracticeTab({
    super.key,
    required this.problems,
    this.onNext,
    this.stepIndex = 1,
    this.nextStepName = '',
    this.nextStepXP = 0,
  });

  @override
  State<PracticeTab> createState() => _PracticeTabState();
}

class _PracticeTabState extends State<PracticeTab> {
  int _points = 500;
  final Set<int> _completed = {};
  final Map<int, bool> _gotIt = {}; // true = পেরেছি, false = পারিনি

  void _spendPoints(int cost) => setState(() => _points = (_points - cost).clamp(0, 9999));
  void _earnPoints(int amount) => setState(() => _points += amount);

  void _markDone(int index, bool got) {
    setState(() {
      _completed.add(index);
      _gotIt[index] = got;
    });
    _earnPoints(got ? 50 : 15);
  }

  String _motivationText() {
    final pct = _completed.isEmpty ? 0 : (_completed.length / widget.problems.length * 100).round();
    if (pct == 0) return 'শুরু করো! 💪';
    if (pct < 40) return 'ভালো শুরু! 🌱';
    if (pct < 70) return 'চলতে থাকো! 🔥';
    if (pct < 100) return 'প্রায় শেষ! ⚡';
    return 'সব সম্পন্ন! 🎉';
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // ── Top bar ──────────────────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(children: [
          // Progress
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(
                '${_completed.length}/${widget.problems.length} সম্পন্ন',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 8),
              Text(_motivationText(), style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _completed.isEmpty ? 0 : _completed.length / widget.problems.length,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                minHeight: 5,
              ),
            ),
          ])),
          const SizedBox(width: 16),
          // Points badge
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Container(
              key: ValueKey(_points),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('🪙', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text('$_points', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFFB8860B))),
              ]),
            ),
          ),
        ]),
      ),

      // ── Problem list ───────────────────────────────────────────────────
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          itemCount: widget.problems.length + (widget.onNext != null ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i < widget.problems.length) {
              final isDone = _completed.contains(i);
              return _ProblemCard(
                key: ValueKey(i),
                problem: widget.problems[i],
                index: i,
                isDone: isDone,
                gotIt: _gotIt[i],
                pointsAvailable: _points,
                onSpendPoints: _spendPoints,
                onComplete: (got) => _markDone(i, got),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: NextStepCard(
                stepIndex: widget.stepIndex,
                nextStepName: widget.nextStepName,
                xp: widget.nextStepXP,
                onNext: widget.onNext!,
              ),
            );
          },
        ),
      ),
    ]);
  }
}

// ─── Problem Card ─────────────────────────────────────────────────────────────

class _ProblemCard extends StatefulWidget {
  final PracticeExample problem;
  final int index;
  final bool isDone;
  final bool? gotIt;
  final int pointsAvailable;
  final void Function(int) onSpendPoints;
  final void Function(bool) onComplete;

  const _ProblemCard({
    super.key,
    required this.problem,
    required this.index,
    required this.isDone,
    required this.gotIt,
    required this.pointsAvailable,
    required this.onSpendPoints,
    required this.onComplete,
  });

  @override
  State<_ProblemCard> createState() => _ProblemCardState();
}

class _ProblemCardState extends State<_ProblemCard> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  // Non-math state
  int? _confidence; // 0=জানি না, 1=কিছুটা, 2=পুরো জানি
  bool _answerRevealed = false;
  // Math state
  final Set<int> _revealedHints = {};
  final TextEditingController _answerCtrl = TextEditingController();
  bool _submitted = false;
  // Last hint cost flash
  int? _lastCost;

  static const _hintCost = 25;

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  void _unlockHint(int i) {
    if (_revealedHints.contains(i)) return;
    if (widget.pointsAvailable < _hintCost) return;
    HapticFeedback.lightImpact();
    widget.onSpendPoints(_hintCost);
    setState(() {
      _revealedHints.add(i);
      _lastCost = _hintCost;
    });
    // Clear flash
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _lastCost = null);
    });
  }

  void _revealAnswer() {
    HapticFeedback.mediumImpact();
    setState(() => _answerRevealed = true);
  }

  void _submitAnswer() {
    HapticFeedback.mediumImpact();
    // Fuzzy match — if user typed something non-empty, show the correct answer
    setState(() { _submitted = true; });
  }

  void _selfAssess(bool got) {
    HapticFeedback.selectionClick();
    widget.onComplete(got);
  }

  Color get _cardBorderColor {
    if (widget.isDone) {
      return widget.gotIt == true ? AppColors.success.withValues(alpha: 0.4) : AppColors.error.withValues(alpha: 0.3);
    }
    return _expanded ? AppColors.primary.withValues(alpha: 0.25) : AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.problem;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorderColor, width: _expanded ? 1.0 : 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header (always visible) ──────────────────────────────────────
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Number + done indicator
              Stack(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    gradient: widget.isDone
                        ? (widget.gotIt == true ? const LinearGradient(colors: [AppColors.success, Color(0xFF16A34A)]) : const LinearGradient(colors: [AppColors.error, Color(0xFFDC2626)]))
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(child: Text(
                    widget.isDone ? (widget.gotIt == true ? '✓' : '✗') : '${widget.index + 1}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                  )),
                ),
              ]),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Type badge
                Row(children: [
                  _TypeBadge(isMath: p.isMath),
                  if (p.needsDiagram) ...[const SizedBox(width: 6), _TypeBadge(isDiagram: true)],
                  const Spacer(),
                  if (widget.isDone)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (widget.gotIt == true ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.gotIt == true ? 'পেরেছি ✓' : 'পারিনি ✗',
                        style: GoogleFonts.hindSiliguri(fontSize: 11, color: widget.gotIt == true ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600),
                      ),
                    ),
                ]),
                const SizedBox(height: 8),
                Text(p.question, style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.4)),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 13, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text('${p.steps.length} ধাপ', style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.textHint)),
                ]),
              ])),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
                ),
              ),
            ]),
          ),
        ),

        // ── Expanded content ─────────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
          child: _expanded
              ? Column(children: [
                  const Divider(color: AppColors.divider, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: p.isMath ? _buildMathContent() : _buildConceptContent(),
                  ),
                ])
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }

  // ── Non-math: confidence check + hidden answer ──────────────────────────

  Widget _buildConceptContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Confidence check (before reveal)
      if (!_answerRevealed && !widget.isDone) ...[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('আপনি কি এই উত্তর জানেন?', style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Row(children: [
              _ConfidenceChip(label: '😕 জানি না', value: 0, selected: _confidence == 0, onTap: () => setState(() => _confidence = 0)),
              const SizedBox(width: 8),
              _ConfidenceChip(label: '🤔 কিছুটা', value: 1, selected: _confidence == 1, onTap: () => setState(() => _confidence = 1)),
              const SizedBox(width: 8),
              _ConfidenceChip(label: '✅ জানি', value: 2, selected: _confidence == 2, onTap: () => setState(() => _confidence = 2)),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
      ],

      // Hidden answer area
      if (!_answerRevealed && !widget.isDone)
        GestureDetector(
          onTap: _revealAnswer,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: 10),
              Text('উত্তর দেখতে ট্যাপ করুন', style: GoogleFonts.hindSiliguri(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w500)),
            ]),
          ),
        ),

      // Revealed answer (steps + answer)
      if (_answerRevealed || widget.isDone) ...[
        ...widget.problem.steps.asMap().entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 24, height: 24,
              margin: const EdgeInsets.only(right: 10, top: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.secondary.withValues(alpha: 0.7)]),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text('${e.key + 1}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
            Expanded(child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.scaffoldBg, borderRadius: BorderRadius.circular(12)),
              child: Text(e.value, style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textPrimary, height: 1.4)),
            )),
          ]),
        )),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.problem.answer, style: GoogleFonts.hindSiliguri(fontSize: 14, color: AppColors.textPrimary, height: 1.5, fontWeight: FontWeight.w500))),
          ]),
        ),
      ],

      // Self-assessment
      if ((_answerRevealed || widget.isDone) && !widget.isDone) ...[
        const SizedBox(height: 16),
        Text('নিজেকে মূল্যায়ন করো:', style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _SelfAssessButton(label: '👍 পেরেছি', isGot: true, onTap: () => _selfAssess(true))),
          const SizedBox(width: 12),
          Expanded(child: _SelfAssessButton(label: '👎 পারিনি', isGot: false, onTap: () => _selfAssess(false))),
        ]),
      ],

      if (widget.isDone) ...[
        const SizedBox(height: 12),
        _DoneBadge(got: widget.gotIt == true, confidence: _confidence),
      ],
    ]);
  }

  // ── Math: locked hints + answer input ─────────────────────────────────

  Widget _buildMathContent() {
    final steps = widget.problem.steps;
    final canAfford = widget.pointsAvailable >= _hintCost;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Point cost flash
      if (_lastCost != null)
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 0.0),
          duration: const Duration(milliseconds: 1200),
          builder: (ctx, opacity, _) => Opacity(
            opacity: opacity,
            child: Center(child: Text('-$_lastCost পয়েন্ট', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.error))),
          ),
        ),

      // Locked/unlocked steps (hints)
      ...steps.asMap().entries.map((e) {
        final isRevealed = _revealedHints.contains(e.key) || widget.isDone;
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isRevealed ? AppColors.scaffoldBg : AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isRevealed ? AppColors.primary.withValues(alpha: 0.2) : AppColors.border,
                width: isRevealed ? 1 : 0.5,
              ),
            ),
            child: isRevealed
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 22, height: 22,
                        margin: const EdgeInsets.only(right: 10, top: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Center(child: Text('${e.key + 1}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
                      ),
                      Expanded(child: Text(e.value, style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textPrimary, height: 1.4))),
                    ]),
                  )
                : GestureDetector(
                    onTap: canAfford ? () => _unlockHint(e.key) : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(children: [
                        Icon(Icons.lock_outline_rounded, size: 16, color: canAfford ? AppColors.primary : AppColors.textHint),
                        const SizedBox(width: 10),
                        Expanded(child: Text(
                          'হিন্ট ${e.key + 1} দেখতে ট্যাপ করুন',
                          style: GoogleFonts.hindSiliguri(fontSize: 13, color: canAfford ? AppColors.primary : AppColors.textHint, fontWeight: FontWeight.w500),
                        )),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: canAfford ? AppColors.primary.withValues(alpha: 0.08) : AppColors.scaffoldBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-$_hintCost পয়েন্ট',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: canAfford ? AppColors.primary : AppColors.textHint),
                          ),
                        ),
                      ]),
                    ),
                  ),
          ),
        );
      }),

      if (!canAfford && _revealedHints.length < steps.length && !widget.isDone)
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.error),
            const SizedBox(width: 8),
            Text('পয়েন্ট শেষ! স্ব-মূল্যায়ন করে পয়েন্ট অর্জন করো।', style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.error)),
          ]),
        ),

      const SizedBox(height: 6),

      // Answer input (only if not done, and at least 1 hint unlocked or all revealed)
      if (!_submitted && !widget.isDone) ...[
        TextField(
          controller: _answerCtrl,
          style: GoogleFonts.hindSiliguri(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'চূড়ান্ত উত্তর লিখুন...',
            hintStyle: GoogleFonts.hindSiliguri(color: AppColors.textHint, fontSize: 14),
            filled: true,
            fillColor: AppColors.scaffoldBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border, width: 0.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border, width: 0.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _answerCtrl.text.trim().isEmpty ? null : _submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text('সাবমিট করুন', style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ],

      // After submit: show correct answer + self-assess
      if (_submitted || widget.isDone) ...[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Text('সঠিক উত্তর:', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
            ]),
            const SizedBox(height: 6),
            Text(widget.problem.answer, style: GoogleFonts.hindSiliguri(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ]),
        ),
        if (!widget.isDone) ...[
          const SizedBox(height: 14),
          Text('তোমার উত্তর কি মিলেছে?', style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _SelfAssessButton(label: '👍 পেরেছি', isGot: true, onTap: () => _selfAssess(true))),
            const SizedBox(width: 12),
            Expanded(child: _SelfAssessButton(label: '👎 পারিনি', isGot: false, onTap: () => _selfAssess(false))),
          ]),
        ],
        if (widget.isDone) ...[
          const SizedBox(height: 12),
          _DoneBadge(got: widget.gotIt == true, confidence: null),
        ],
      ],
    ]);
  }
}

// ─── Small reusable widgets ───────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final bool isMath;
  final bool isDiagram;
  const _TypeBadge({this.isMath = false, this.isDiagram = false});

  @override
  Widget build(BuildContext context) {
    if (isDiagram) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(7)),
        child: Text('🖼 ডায়াগ্রাম', style: GoogleFonts.hindSiliguri(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.info)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isMath ? AppColors.warning.withValues(alpha: 0.1) : AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        isMath ? '📐 গাণিতিক' : '💡 ধারণাগত',
        style: GoogleFonts.hindSiliguri(fontSize: 10, fontWeight: FontWeight.w600, color: isMath ? AppColors.warning : AppColors.secondary),
      ),
    );
  }
}

class _ConfidenceChip extends StatelessWidget {
  final String label;
  final int value;
  final bool selected;
  final VoidCallback onTap;
  const _ConfidenceChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.scaffoldBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 0.5),
          ),
          child: Center(child: Text(label, style: GoogleFonts.hindSiliguri(fontSize: 11, color: selected ? AppColors.primary : AppColors.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.w400))),
        ),
      ),
    );
  }
}

class _SelfAssessButton extends StatelessWidget {
  final String label;
  final bool isGot;
  final VoidCallback onTap;
  const _SelfAssessButton({required this.label, required this.isGot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isGot ? AppColors.success.withValues(alpha: 0.08) : AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isGot ? AppColors.success.withValues(alpha: 0.4) : AppColors.error.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Center(child: Text(label, style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w700, color: isGot ? AppColors.success : AppColors.error))),
      ),
    );
  }
}

class _DoneBadge extends StatelessWidget {
  final bool got;
  final int? confidence;
  const _DoneBadge({required this.got, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: got ? AppColors.success.withValues(alpha: 0.06) : AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: got ? AppColors.success.withValues(alpha: 0.2) : AppColors.border),
      ),
      child: Row(children: [
        Text(got ? '🎯 পেরেছ!' : '📖 আরেকবার চেষ্টা করো', style: GoogleFonts.hindSiliguri(fontSize: 13, color: got ? AppColors.success : AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const Spacer(),
        if (got)
          Text('+50 🪙', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w700))
        else
          Text('+15 🪙', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textHint, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
