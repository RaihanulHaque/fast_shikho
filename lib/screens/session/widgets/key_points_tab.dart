import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../models/key_points.dart';

class KeyPointsTab extends StatefulWidget {
  final KeyPoints keyPoints;
  final String sessionTitle;
  final String detectedSubject;
  final VoidCallback? onNext;
  final int stepIndex;
  final String nextStepName;
  final int nextStepXP;
  final void Function(double)? onScrollProgress;
  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;

  const KeyPointsTab({
    super.key,
    required this.keyPoints,
    this.sessionTitle = '',
    this.detectedSubject = '',
    this.onNext,
    this.stepIndex = 0,
    this.nextStepName = '',
    this.nextStepXP = 0,
    this.onScrollProgress,
    this.onCorrect,
    this.onWrong,
  });

  @override
  State<KeyPointsTab> createState() => _KeyPointsTabState();
}

class _KeyPointsTabState extends State<KeyPointsTab> {
  late final ScrollController _sc;
  bool _showAllKaKha = false;

  @override
  void initState() {
    super.initState();
    _sc = ScrollController();
    _sc.addListener(() {
      final max = _sc.position.maxScrollExtent;
      if (max > 0) widget.onScrollProgress?.call(_sc.offset / max);
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  int get _estimatedMinutes {
    final wordCount = (widget.keyPoints.quickSummary.split(' ').length +
            widget.keyPoints.whatToLearn.join(' ').split(' ').length +
            widget.keyPoints.easyLessons.map((e) => e.explanation).join(' ').split(' ').length)
        .toDouble();
    return ((wordCount / 120) + 2).round().clamp(3, 15);
  }

  List<ImportantPointQA> _qaOfType(String type) =>
      widget.keyPoints.importantPointsQa.where((q) => q.type == type).toList();

  List<Widget> _buildKaKhaCards(List<ImportantPointQA> qs) {
    const prefixes = ['ক', 'খ', 'গ', 'ঘ', 'ঙ', 'চ', 'ছ', 'জ'];
    final visible = _showAllKaKha ? qs : qs.take(2).toList();
    return [
      ...visible.asMap().entries.map((e) {
        final prefix = e.key < prefixes.length ? prefixes[e.key] : '${e.key + 1}';
        return _KaKhaCard(
          prefix: prefix,
          question: e.value.question ?? '',
          answer: e.value.kaKhaAnswer ?? e.value.explanation,
        );
      }),
      if (!_showAllKaKha && qs.length > 2) ...[
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _showAllKaKha = true),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              'আরও ক/খ প্রশ্ন',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final keyPoints = widget.keyPoints;
    final shortAnswerQs = _qaOfType('short_answer');
    final trueFalseQs = _qaOfType('true_false');
    final connectingQs = _qaOfType('connecting_answer');
    final fillQs = _qaOfType('fill_in_the_blanks');
    final mcqQs = _qaOfType('mcq');

    return ListView(
      controller: _sc,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      children: [
        // ── Hero ──
        _Hero(
          title: widget.sessionTitle.isNotEmpty ? widget.sessionTitle : widget.detectedSubject,
          subject: widget.detectedSubject,
          minutes: _estimatedMinutes,
        ),

        // ── পরীক্ষার জন্য গুরুত্বপূর্ণ ──
        const _Section(title: 'পরীক্ষার জন্য গুরুত্বপূর্ণ'),
        _GlassCard(
          child: _GlowBulletList(items: keyPoints.whatToLearn),
        ),
        const _Gap(),

        // ── ঝটপট রিভিউ ──
        const _Section(title: 'ঝটপট রিভিউ'),
        _LeftBorderText(text: keyPoints.quickSummary),
        const _Gap(),

        // ── ঠিক না ভুল? ──
        if (trueFalseQs.isNotEmpty) ...[
          const _Section(title: 'ঠিক না ভুল?'),
          _GlassCard(child: _TrueFalseCard(qa: trueFalseQs.first, onCorrect: widget.onCorrect, onWrong: widget.onWrong)),
          const _Gap(),
        ],

        // ── কনসেপ্ট ক্লিয়ার ──
        if (keyPoints.easyLessons.isNotEmpty) ...[
          const _Section(title: 'কনসেপ্ট ক্লিয়ার'),
          ...keyPoints.easyLessons.map(
            (lesson) => Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: _ConceptItem(lesson: lesson),
            ),
          ),
          const _Gap(),
        ],

        // ── চ্যালেঞ্জ নাও ──
        if (connectingQs.isNotEmpty) ...[
          const _Section(title: 'চ্যালেঞ্জ নাও'),
          _GlassCard(child: _TapMatchWidget(qa: connectingQs.first)),
          const _Gap(),
        ],

        // ── কমন ভুলগুলো ──
        if (keyPoints.commonMistakes.isNotEmpty) ...[
          _SectionWithIcon(title: 'কমন ভুলগুলো', icon: '⚠️'),
          _MistakesCard(mistakes: keyPoints.commonMistakes),
          const _Gap(),
        ],

        // ── শর্টকাট দেখো ──
        if (keyPoints.shortcutTechniques.isNotEmpty) ...[
          _ShortcutButton(shortcuts: keyPoints.shortcutTechniques),
          const _Gap(),
        ],

        // ── Fill in the blanks ──
        if (fillQs.isNotEmpty) ...[
          const _Section(title: 'Fill in the blanks'),
          ...fillQs.map(
            (q) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GlassCard(child: _FillBlankCard(qa: q, onCorrect: widget.onCorrect, onWrong: widget.onWrong)),
            ),
          ),
          const _Gap(),
        ],

        // ── ক / খ প্রশ্নগুলো ──
        if (shortAnswerQs.isNotEmpty) ...[
          const _Section(title: 'ক / খ প্রশ্নগুলো'),
          ..._buildKaKhaCards(shortAnswerQs),
          const _Gap(),
        ],

        // ── MCQ ──
        if (mcqQs.isNotEmpty) ...[
          const _Section(title: 'MCQ'),
          ...mcqQs.map((q) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MCQCard(qa: q, onCorrect: widget.onCorrect, onWrong: widget.onWrong),
          )),
          const _Gap(),
        ],

        // ── Next Step ──
        if (widget.onNext != null)
          _DuoBtn(label: 'পরের ধাপ', onTap: widget.onNext!),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ─────────────────── Layout helpers ───────────────────

class _Gap extends StatelessWidget {
  const _Gap();
  @override
  Widget build(BuildContext context) => const SizedBox(height: 40);
}

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

class _SectionWithIcon extends StatelessWidget {
  final String title;
  final String icon;
  const _SectionWithIcon({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.hindSiliguri(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────── Hero section ───────────────────

class _Hero extends StatelessWidget {
  final String title;
  final String subject;
  final int minutes;

  const _Hero({required this.title, required this.subject, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.hindSiliguri(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'সময় লাগবে $minutes মিনিট',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Green glow bullet list ───────────────────

class _GlowBulletList extends StatelessWidget {
  final List<String> items;
  const _GlowBulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7, right: 14),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Text(
                item,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// ─────────────────── Green left border text ───────────────────

class _LeftBorderText extends StatelessWidget {
  final String text;
  const _LeftBorderText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 22),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 4,
          ),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.hindSiliguri(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.75,
        ),
      ),
    );
  }
}

// ─────────────────── True / False card ───────────────────

class _TrueFalseCard extends StatefulWidget {
  final ImportantPointQA qa;
  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;
  const _TrueFalseCard({required this.qa, this.onCorrect, this.onWrong});

  @override
  State<_TrueFalseCard> createState() => _TrueFalseCardState();
}

class _TrueFalseCardState extends State<_TrueFalseCard> {
  bool? _picked;

  @override
  Widget build(BuildContext context) {
    final answered = _picked != null;
    final isCorrect = answered && _picked == widget.qa.correctBool;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            widget.qa.question ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.hindSiliguri(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _TFButton(label: 'সত্য', value: true, picked: _picked, correct: widget.qa.correctBool, answered: answered, onTap: () {
                setState(() => _picked = true);
                if (widget.qa.correctBool == true) { widget.onCorrect?.call(); } else { widget.onWrong?.call(); }
              })),
              const SizedBox(width: 16),
              Expanded(child: _TFButton(label: 'মিথ্যা', value: false, picked: _picked, correct: widget.qa.correctBool, answered: answered, onTap: () {
                setState(() => _picked = false);
                if (widget.qa.correctBool == false) { widget.onCorrect?.call(); } else { widget.onWrong?.call(); }
              })),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 18),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCorrect ? AppColors.primaryTintBg : AppColors.errorTintBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect ? AppColors.primary.withValues(alpha: 0.25) : AppColors.error.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                isCorrect ? '✓ সঠিক উত্তর!' : '✕ ভুল! ${widget.qa.explanation}',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isCorrect ? AppColors.primary : AppColors.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TFButton extends StatefulWidget {
  final String label;
  final bool value;
  final bool? picked;
  final bool? correct;
  final bool answered;
  final VoidCallback onTap;

  const _TFButton({required this.label, required this.value, required this.picked, required this.correct, required this.answered, required this.onTap});

  @override
  State<_TFButton> createState() => _TFButtonState();
}

class _TFButtonState extends State<_TFButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.picked == widget.value;
    final isCorrect = widget.answered && widget.correct == widget.value;
    final isWrong = widget.answered && isSelected && !isCorrect;

    Color bg = const Color(0x08FFFFFF);
    Color borderColor = Colors.white.withValues(alpha: 0.1);
    Color textColor = AppColors.textPrimary;

    if (isCorrect) {
      bg = AppColors.primaryTintBg;
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    } else if (isWrong) {
      bg = AppColors.errorTintBg;
      borderColor = AppColors.error;
      textColor = AppColors.error;
    }

    return GestureDetector(
      onTapDown: widget.answered ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.answered
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
      onTapCancel: widget.answered ? null : () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: EdgeInsets.symmetric(vertical: _pressed ? 15 : 16),
        margin: EdgeInsets.only(top: _pressed ? 2 : 0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            top: BorderSide(color: borderColor),
            left: BorderSide(color: borderColor),
            right: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor, width: _pressed ? 1 : 3),
          ),
          boxShadow: isCorrect
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 16)]
              : isWrong
                  ? [BoxShadow(color: AppColors.error.withValues(alpha: 0.25), blurRadius: 16)]
                  : null,
        ),
        child: Center(
          child: Text(
            widget.label,
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────── Concept Clear item ───────────────────

class _ConceptItem extends StatelessWidget {
  final EasyLesson lesson;
  const _ConceptItem({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 14, left: 4),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.55), blurRadius: 8),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.concept,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                lesson.explanation,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────── Tap Match widget ───────────────────

class _TapMatchWidget extends StatefulWidget {
  final ImportantPointQA qa;
  const _TapMatchWidget({required this.qa});

  @override
  State<_TapMatchWidget> createState() => _TapMatchWidgetState();
}

class _TapMatchWidgetState extends State<_TapMatchWidget> {
  int? _selectedLeft;
  final Map<int, int> _matches = {}; // leftIdx → rightIdx
  bool _revealed = false;

  void _pickLeft(int i) {
    if (_revealed || _matches.containsKey(i)) return;
    setState(() => _selectedLeft = _selectedLeft == i ? null : i);
  }

  void _pickRight(int i) {
    if (_revealed || _selectedLeft == null || _matches.containsValue(i)) return;
    setState(() {
      _matches[_selectedLeft!] = i;
      _selectedLeft = null;
    });
  }

  bool _isCorrect(int leftIdx, int rightIdx) {
    final l = widget.qa.leftItems![leftIdx];
    final r = widget.qa.rightItems![rightIdx];
    return widget.qa.correctMatches?.any((m) => m.left == l && m.right == r) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.qa.leftItems ?? [];
    final right = widget.qa.rightItems ?? [];
    final allMatched = _matches.length == left.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left
            Expanded(
              child: Column(
                children: List.generate(left.length, (i) {
                  final isSel = _selectedLeft == i;
                  final isMatched = _matches.containsKey(i);
                  final correct = _revealed && isMatched && _isCorrect(i, _matches[i]!);
                  final wrong = _revealed && isMatched && !correct;
                  return GestureDetector(
                    onTap: () => _pickLeft(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        color: wrong
                            ? AppColors.errorTintBg
                            : correct || isSel || isMatched
                                ? AppColors.primaryTintBg.withValues(alpha: correct ? 1.0 : 0.7)
                                : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: wrong
                              ? AppColors.error
                              : isSel
                                  ? AppColors.primary
                                  : isMatched
                                      ? AppColors.primary.withValues(alpha: 0.5)
                                      : AppColors.cardBorder,
                          width: isSel || isMatched || _revealed ? 1.5 : 1,
                        ),
                        boxShadow: isSel
                            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 10)]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              left[i],
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isMatched
                                  ? (wrong ? AppColors.error : AppColors.primary)
                                  : AppColors.accentCyan,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isMatched ? (wrong ? AppColors.error : AppColors.primary) : AppColors.accentCyan).withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 12),
            // Right
            Expanded(
              child: Column(
                children: List.generate(right.length, (i) {
                  final isMatched = _matches.containsValue(i);
                  int? matchedLeft;
                  for (final e in _matches.entries) {
                    if (e.value == i) { matchedLeft = e.key; break; }
                  }
                  final correct = _revealed && isMatched && matchedLeft != null && _isCorrect(matchedLeft, i);
                  final wrong = _revealed && isMatched && !correct;
                  return GestureDetector(
                    onTap: () => _pickRight(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        color: wrong
                            ? AppColors.errorTintBg
                            : isMatched
                                ? AppColors.primaryTintBg.withValues(alpha: correct ? 1.0 : 0.6)
                                : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: wrong
                              ? AppColors.error
                              : isMatched
                                  ? AppColors.primary.withValues(alpha: correct ? 1.0 : 0.5)
                                  : AppColors.cardBorder,
                          width: isMatched || _revealed ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isMatched
                                  ? (wrong ? AppColors.error : AppColors.primary.withValues(alpha: 0.6))
                                  : Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              right[i],
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),

        if (!_revealed && allMatched) ...[
          const SizedBox(height: 16),
          _DuoBtn(
            label: 'উত্তর চেক করুন',
            onTap: () => setState(() => _revealed = true),
          ),
        ],

        if (_revealed) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryTintBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✅ সঠিক মিলকরণ:', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 8),
                ...?widget.qa.correctMatches?.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      Expanded(child: Text(m.left, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(child: Text(m.right, style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textPrimary))),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────── Common Mistakes card ───────────────────

class _MistakesCard extends StatelessWidget {
  final List<String> mistakes;
  const _MistakesCard({required this.mistakes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.errorTintBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: mistakes.map((m) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 14),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.error.withValues(alpha: 0.5), blurRadius: 6)],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  m,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF6B6B),
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

// ─────────────────── Shortcut expandable button ───────────────────

class _ShortcutButton extends StatefulWidget {
  final List<String> shortcuts;
  const _ShortcutButton({required this.shortcuts});

  @override
  State<_ShortcutButton> createState() => _ShortcutButtonState();
}

class _ShortcutButtonState extends State<_ShortcutButton> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryTintBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 20),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🚀', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  'শর্টকাট দেখো',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Icon(
                  _open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: _open
              ? Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.shortcuts.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, right: 12),
                            child: Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              s,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                                height: 1.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─────────────────── Fill in the blank card ───────────────────

class _FillBlankCard extends StatefulWidget {
  final ImportantPointQA qa;
  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;
  const _FillBlankCard({required this.qa, this.onCorrect, this.onWrong});

  @override
  State<_FillBlankCard> createState() => _FillBlankCardState();
}

class _FillBlankCardState extends State<_FillBlankCard> {
  String? _picked;
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final opts = widget.qa.blankOptions ?? [];
    final isCorrect = _revealed && _picked == widget.qa.blankAnswer;
    final isWrong = _revealed && _picked != null && !isCorrect;

    final q = widget.qa.question ?? '';
    final parts = q.split('___');
    final before = parts.isNotEmpty ? parts[0].trimRight() : '';
    final after = parts.length > 1 ? parts[1].trimLeft() : '';

    final blankBorderColor = _revealed
        ? (isCorrect ? AppColors.primary : AppColors.error)
        : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Before-blank text
        if (before.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(before,
                style: GoogleFonts.hindSiliguri(
                    fontSize: 17, color: AppColors.textPrimary, height: 1.5)),
          ),

        // Standalone blank box (matches design image)
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: _revealed
                ? (isCorrect
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.error.withValues(alpha: 0.08))
                : AppColors.scaffoldBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: blankBorderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: blankBorderColor.withValues(alpha: 0.25),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: _picked != null
                ? Text(_picked!,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _revealed
                          ? (isCorrect ? AppColors.primary : AppColors.error)
                          : AppColors.textPrimary,
                    ))
                : Container(
                    width: 48,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
          ),
        ),

        // After-blank text
        if (after.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(after,
                style: GoogleFonts.hindSiliguri(
                    fontSize: 17, color: AppColors.textPrimary, height: 1.5)),
          ),

        // Options grid
        if (opts.isNotEmpty) ...[
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: opts.map((opt) {
              final isSel = _picked == opt;
              final isCorrectOpt = opt == widget.qa.blankAnswer;

              Color bg = AppColors.darkCard;
              Color borderColor = AppColors.cardBorder;
              Color textColor = AppColors.textPrimary;

              if (_revealed && isCorrectOpt) {
                bg = AppColors.primaryTintBg;
                borderColor = AppColors.primary;
                textColor = AppColors.primary;
              } else if (_revealed && isSel && !isCorrectOpt) {
                bg = AppColors.errorTintBg;
                borderColor = AppColors.error;
                textColor = AppColors.error;
              }

              return GestureDetector(
                onTap: _revealed
                    ? null
                    : () {
                        setState(() {
                          _picked = opt;
                          _revealed = true;
                        });
                        if (opt == widget.qa.blankAnswer) {
                          widget.onCorrect?.call();
                        } else {
                          widget.onWrong?.call();
                        }
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: Text(opt,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        )),
                  ),
                ),
              );
            }).toList(),
          ),
        ],

        if (_revealed && isWrong) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.errorTintBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.info_rounded, color: AppColors.error, size: 16),
              const SizedBox(width: 8),
              Text('সঠিক উত্তর: ',
                  style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.error)),
              Text(widget.qa.blankAnswer ?? '',
                  style: GoogleFonts.hindSiliguri(
                      fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ]),
          ),
        ],
      ],
    );
  }
}

// ─────────────────── ক/খ card ───────────────────

class _KaKhaCard extends StatelessWidget {
  final String prefix;
  final String question;
  final String answer;
  const _KaKhaCard({required this.prefix, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$prefix. $question',
            style: GoogleFonts.hindSiliguri(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          Divider(color: AppColors.divider, height: 24),
          Text(
            answer,
            style: GoogleFonts.hindSiliguri(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── MCQ accordion card ───────────────────

class _MCQCard extends StatefulWidget {
  final ImportantPointQA qa;
  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;
  const _MCQCard({required this.qa, this.onCorrect, this.onWrong});

  @override
  State<_MCQCard> createState() => _MCQCardState();
}

class _MCQCardState extends State<_MCQCard> {
  bool _open = false;
  String? _picked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                  widget.qa.question ?? '',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              Icon(_open ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.textSecondary),
            ]),
            if (_open) ...[
              const SizedBox(height: 16),
              ...?widget.qa.options?.entries.map((e) {
                final isSelected = _picked == e.key;
                final isCorrect = e.key == widget.qa.correctOption;
                Color bg = const Color(0x08FFFFFF);
                Color borderCol = Colors.white.withValues(alpha: 0.1);
                if (_picked != null && isCorrect) { bg = AppColors.primaryTintBg; borderCol = AppColors.primary; }
                else if (_picked != null && isSelected && !isCorrect) { bg = AppColors.errorTintBg; borderCol = AppColors.error; }
                else if (isSelected) { bg = AppColors.primaryTintBg; borderCol = AppColors.primary; }
                return GestureDetector(
                  onTap: _picked != null ? null : () {
                    setState(() => _picked = e.key);
                    if (e.key == widget.qa.correctOption) {
                      widget.onCorrect?.call();
                    } else {
                      widget.onWrong?.call();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderCol, width: isSelected || (_picked != null && isCorrect) ? 1.5 : 1),
                    ),
                    child: Row(children: [
                      Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryTintBg : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Center(child: Text(e.key, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: isSelected ? AppColors.primary : AppColors.textSecondary))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(e.value, style: GoogleFonts.hindSiliguri(fontSize: 14, color: AppColors.textPrimary))),
                      if (_picked != null && isCorrect) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                      if (_picked != null && isSelected && !isCorrect) const Icon(Icons.cancel_rounded, color: AppColors.error, size: 18),
                    ]),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────── Duo-style button ───────────────────

class _DuoBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _DuoBtn({required this.label, required this.onTap});

  @override
  State<_DuoBtn> createState() => _DuoBtnState();
}

class _DuoBtnState extends State<_DuoBtn> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: _pressed ? 15 : 16),
        margin: EdgeInsets.only(top: _pressed ? 2 : 0),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          border: Border(bottom: BorderSide(color: AppColors.primaryDark, width: _pressed ? 1 : 3)),
          boxShadow: !_pressed ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20)] : null,
        ),
        child: Center(child: Text(widget.label, style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black))),
      ),
    );
  }
}
