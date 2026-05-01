import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../models/key_points.dart';
import 'next_step_card.dart';

class KeyPointsTab extends StatelessWidget {
  final KeyPoints keyPoints;
  final VoidCallback? onNext;
  final int stepIndex;
  final String nextStepName;
  final int nextStepXP;

  const KeyPointsTab({
    super.key,
    required this.keyPoints,
    this.onNext,
    this.stepIndex = 0,
    this.nextStepName = '',
    this.nextStepXP = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // What to Learn
        _SectionCard(
          emoji: '📚',
          title: 'কী শিখতে হবে',
          accentColor: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: keyPoints.whatToLearn.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 26, height: 26,
                  margin: const EdgeInsets.only(right: 10, top: 1),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text('${entry.key + 1}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
                Expanded(child: Text(entry.value, style: GoogleFonts.hindSiliguri(fontSize: 14, color: AppColors.textPrimary, height: 1.5))),
              ]),
            )).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Quick Summary
        _SectionCard(
          emoji: '⚡',
          title: 'দ্রুত সারসংক্ষেপ',
          accentColor: AppColors.secondary,
          child: Text(keyPoints.quickSummary, style: GoogleFonts.hindSiliguri(fontSize: 14, color: AppColors.textPrimary, height: 1.7)),
        ),
        const SizedBox(height: 14),

        // Shortcuts
        _SectionCard(
          emoji: '🎯',
          title: 'শর্টকাট টেকনিক',
          accentColor: AppColors.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: keyPoints.shortcutTechniques.map((tip) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.warning.withValues(alpha: 0.09), AppColors.warning.withValues(alpha: 0.03)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(child: Text(tip, style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textPrimary, height: 1.5))),
              ]),
            )).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Easy Lessons
        if (keyPoints.easyLessons.isNotEmpty) ...[
          _SectionCard(
            emoji: '🧩',
            title: 'সহজ পাঠ',
            accentColor: AppColors.success,
            child: Column(
              children: keyPoints.easyLessons.map((lesson) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(lesson.concept, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
                  ),
                  const SizedBox(height: 10),
                  Text(lesson.explanation, style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textPrimary, height: 1.6)),
                ]),
              )).toList(),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Important QA — swipeable carousel
        _SectionCard(
          emoji: '🧠',
          title: 'গুরুত্বপূর্ণ প্রশ্নোত্তর',
          accentColor: AppColors.accentPink,
          child: _TypedQASection(questions: keyPoints.importantPointsQa),
        ),

        // Next Step Card
        if (onNext != null) ...[
          const SizedBox(height: 24),
          NextStepCard(
            stepIndex: stepIndex,
            nextStepName: nextStepName,
            xp: nextStepXP,
            onNext: onNext!,
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}

// ─── Section Card ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final Color accentColor;
  final Widget child;
  const _SectionCard({required this.emoji, required this.title, required this.accentColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Text(title, style: GoogleFonts.hindSiliguri(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}

// ─── Typed QA Section (grouped by question type) ─────────────────────────────

class _TypedQASection extends StatelessWidget {
  final List<ImportantPointQA> questions;
  const _TypedQASection({required this.questions});

  static const _typeOrder = ['mcq', 'true_false', 'fill_in_the_blanks', 'connecting_answer'];

  static Color _typeColor(String type) {
    switch (type) {
      case 'mcq': return AppColors.primary;
      case 'true_false': return AppColors.warning;
      case 'fill_in_the_blanks': return AppColors.success;
      case 'connecting_answer': return AppColors.accentPink;
      default: return AppColors.textHint;
    }
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'mcq': return '🔵 MCQ';
      case 'true_false': return '⚖️ সত্য / মিথ্যা';
      case 'fill_in_the_blanks': return '✏️ শূন্যস্থান পূরণ';
      case 'connecting_answer': return '🔗 মিলকরণ';
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group by type preserving _typeOrder
    final groups = <String, List<ImportantPointQA>>{};
    for (final q in questions) {
      groups.putIfAbsent(q.type, () => []).add(q);
    }

    final orderedTypes = _typeOrder.where(groups.containsKey).toList();
    // Any unexpected types appended at end
    for (final t in groups.keys) {
      if (!orderedTypes.contains(t)) orderedTypes.add(t);
    }

    final widgets = <Widget>[];
    for (int i = 0; i < orderedTypes.length; i++) {
      final type = orderedTypes[i];
      final items = groups[type]!;
      if (i > 0) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Divider(color: AppColors.border, thickness: 0.5),
        ));
      }
      // Type label
      widgets.add(Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _typeColor(type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _typeColor(type).withValues(alpha: 0.25)),
          ),
          child: Text(_typeLabel(type), style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: _typeColor(type))),
        ),
        const SizedBox(width: 8),
        if (items.length > 1)
          Text('${items.length} টি প্রশ্ন', style: GoogleFonts.hindSiliguri(fontSize: 11, color: AppColors.textHint)),
      ]));
      widgets.add(const SizedBox(height: 12));
      // Carousel or single card
      if (items.length > 1) {
        widgets.add(_TypeCarousel(questions: items, typeColor: _typeColor(type)));
      } else {
        widgets.add(_QACard(qa: items.first, index: 0));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}

// ─── Per-type Carousel ────────────────────────────────────────────────────────

class _TypeCarousel extends StatefulWidget {
  final List<ImportantPointQA> questions;
  final Color typeColor;
  const _TypeCarousel({required this.questions, required this.typeColor});

  @override
  State<_TypeCarousel> createState() => _TypeCarouselState();
}

class _TypeCarouselState extends State<_TypeCarousel> {
  int _index = 0;
  bool _swipeLeft = true;

  void _prev() {
    if (_index > 0) setState(() { _swipeLeft = false; _index--; });
  }

  void _next() {
    if (_index < widget.questions.length - 1) setState(() { _swipeLeft = true; _index++; });
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Swipeable card
      GestureDetector(
        onHorizontalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) < -200) _next();
          if ((d.primaryVelocity ?? 0) > 200) _prev();
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) {
            final slide = Tween<Offset>(
              begin: Offset(_swipeLeft ? 0.18 : -0.18, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
            return FadeTransition(
              opacity: anim,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: _QACard(
            key: ValueKey('$_index-${q[_index].type}'),
            qa: q[_index],
            index: _index,
          ),
        ),
      ),

      // Nav row
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _NavButton(
          icon: Icons.chevron_left_rounded,
          label: 'আগের',
          enabled: _index > 0,
          onTap: _prev,
          activeColor: widget.typeColor,
        ),
        // Dot indicators
        Row(
          children: List.generate(q.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _index ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == _index ? widget.typeColor : AppColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
          )),
        ),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          label: 'পরের',
          enabled: _index < q.length - 1,
          onTap: _next,
          iconRight: true,
          activeColor: widget.typeColor,
        ),
      ]),
    ]);
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool iconRight;
  final Color activeColor;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.iconRight = false,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? activeColor : AppColors.border;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!iconRight) Icon(icon, color: color, size: 20),
          if (!iconRight) const SizedBox(width: 4),
          Text(label, style: GoogleFonts.hindSiliguri(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
          if (iconRight) const SizedBox(width: 4),
          if (iconRight) Icon(icon, color: color, size: 20),
        ],
      ),
    );
  }
}

// ─── QA Card ────────────────────────────────────────────────────────────────

class _QACard extends StatefulWidget {
  final ImportantPointQA qa;
  final int index;
  const _QACard({super.key, required this.qa, required this.index});

  @override
  State<_QACard> createState() => _QACardState();
}

class _QACardState extends State<_QACard> {
  String? _selectedOption;
  bool? _selectedBool;
  String _blankInput = '';
  String? _selectedBlankOption;
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final qa = widget.qa;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Type badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _typeBadgeColor().withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _typeBadgeColor().withValues(alpha: 0.3), width: 0.5),
          ),
          child: Text(_typeBadgeLabel(), style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: _typeBadgeColor())),
        ),

        if (qa.question != null) ...[
          Text(qa.question!, style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.4)),
          const SizedBox(height: 14),
        ],

        if (qa.type == 'mcq') _buildMCQ(),
        if (qa.type == 'true_false') _buildTrueFalse(),
        if (qa.type == 'fill_in_the_blanks') _buildFillBlank(),
        if (qa.type == 'connecting_answer') _ConnectingAnswerWidget(qa: qa),

        // Explanation (animated reveal)
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: _revealed
              ? Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withValues(alpha: 0.07), AppColors.secondary.withValues(alpha: 0.04)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('💬', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(qa.explanation, style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textPrimary, height: 1.6))),
                  ]),
                )
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }

  Color _typeBadgeColor() {
    switch (widget.qa.type) {
      case 'mcq': return AppColors.primary;
      case 'true_false': return AppColors.warning;
      case 'fill_in_the_blanks': return AppColors.success;
      case 'connecting_answer': return AppColors.accentPink;
      default: return AppColors.textHint;
    }
  }

  String _typeBadgeLabel() {
    switch (widget.qa.type) {
      case 'mcq': return 'MCQ';
      case 'true_false': return 'সত্য / মিথ্যা';
      case 'fill_in_the_blanks': return 'শূন্যস্থান পূরণ';
      case 'connecting_answer': return 'মিলকরণ';
      default: return widget.qa.type;
    }
  }

  // ── MCQ ──────────────────────────────────────────────────────────────────

  Widget _buildMCQ() {
    return Column(children: [
      ...widget.qa.options!.entries.map((e) {
        final isSelected = _selectedOption == e.key;
        final isCorrect = e.key == widget.qa.correctOption;
        Color bg = AppColors.cardBg;
        Color borderColor = AppColors.border;
        if (_revealed && isCorrect) { bg = AppColors.success.withValues(alpha: 0.1); borderColor = AppColors.success; }
        else if (_revealed && isSelected && !isCorrect) { bg = AppColors.error.withValues(alpha: 0.1); borderColor = AppColors.error; }
        else if (isSelected) { bg = AppColors.primary.withValues(alpha: 0.08); borderColor = AppColors.primary; }

        return GestureDetector(
          onTap: _revealed ? null : () => setState(() { _selectedOption = e.key; _revealed = true; }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: isSelected || (_revealed && isCorrect) ? 1.5 : 0.5),
            ),
            child: Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text(e.key, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? AppColors.primary : AppColors.textSecondary))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(e.value, style: GoogleFonts.hindSiliguri(fontSize: 14, color: AppColors.textPrimary))),
              if (_revealed && isCorrect) const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              if (_revealed && isSelected && !isCorrect) const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
            ]),
          ),
        );
      }),
    ]);
  }

  // ── True / False ──────────────────────────────────────────────────────────

  Widget _buildTrueFalse() {
    return Row(children: [
      Expanded(child: _boolButton('✅ সত্য', true)),
      const SizedBox(width: 12),
      Expanded(child: _boolButton('❌ মিথ্যা', false)),
    ]);
  }

  Widget _boolButton(String label, bool value) {
    final isSelected = _selectedBool == value;
    final isCorrect = widget.qa.correctBool == value;
    Color bg = AppColors.cardBg;
    Color borderColor = AppColors.border;
    if (_revealed && isCorrect) { bg = AppColors.success.withValues(alpha: 0.1); borderColor = AppColors.success; }
    else if (_revealed && isSelected && !isCorrect) { bg = AppColors.error.withValues(alpha: 0.1); borderColor = AppColors.error; }
    else if (isSelected) { bg = AppColors.primary.withValues(alpha: 0.08); borderColor = AppColors.primary; }

    return GestureDetector(
      onTap: _revealed ? null : () => setState(() { _selectedBool = value; _revealed = true; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected || (_revealed && isCorrect) ? 1.5 : 0.5),
        ),
        child: Center(child: Text(label, style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
      ),
    );
  }

  // ── Fill in the Blank ─────────────────────────────────────────────────────

  Widget _buildFillBlank() {
    // If blank_options provided → choice chips (no typing)
    if (widget.qa.blankOptions != null && widget.qa.blankOptions!.isNotEmpty) {
      return _buildFillBlankChoices();
    }
    return _buildFillBlankInput();
  }

  Widget _buildFillBlankChoices() {
    final isCorrect = _revealed && _selectedBlankOption == widget.qa.blankAnswer;
    final isWrong = _revealed && !isCorrect;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'সঠিক উত্তরটি বেছে নিন:',
        style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.textSecondary),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.qa.blankOptions!.map((opt) {
          final isSelected = _selectedBlankOption == opt;
          final isCorrectOpt = opt == widget.qa.blankAnswer;
          Color bg = AppColors.cardBg;
          Color borderColor = AppColors.border;
          if (_revealed && isCorrectOpt) { bg = AppColors.success.withValues(alpha: 0.1); borderColor = AppColors.success; }
          else if (_revealed && isSelected && !isCorrectOpt) { bg = AppColors.error.withValues(alpha: 0.1); borderColor = AppColors.error; }
          else if (isSelected) { bg = AppColors.primary.withValues(alpha: 0.08); borderColor = AppColors.primary; }

          return GestureDetector(
            onTap: _revealed ? null : () => setState(() => _selectedBlankOption = opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: isSelected || (_revealed && isCorrectOpt) ? 1.5 : 0.5),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(opt, style: GoogleFonts.hindSiliguri(fontSize: 14, color: AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                if (_revealed && isCorrectOpt) ...[const SizedBox(width: 6), const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16)],
                if (_revealed && isSelected && !isCorrectOpt) ...[const SizedBox(width: 6), const Icon(Icons.cancel_rounded, color: AppColors.error, size: 16)],
              ]),
            ),
          );
        }).toList(),
      ),
      if (_selectedBlankOption != null && !_revealed) ...[
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _revealed = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('জমা দিন', style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
      if (_revealed) ...[
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCorrect ? AppColors.success.withValues(alpha: 0.08) : AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            Icon(isCorrect ? Icons.check_circle_rounded : Icons.info_rounded, color: isCorrect ? AppColors.success : AppColors.error, size: 18),
            const SizedBox(width: 8),
            isCorrect
                ? Text('চমৎকার! সঠিক উত্তর 🎉', style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.success))
                : Expanded(child: RichText(text: TextSpan(
                    children: [
                      TextSpan(text: 'সঠিক উত্তর: ', style: GoogleFonts.hindSiliguri(fontSize: 14, color: AppColors.error, fontWeight: FontWeight.w500)),
                      TextSpan(text: widget.qa.blankAnswer ?? '', style: GoogleFonts.hindSiliguri(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                    ],
                  ))),
            if (isWrong && isCorrect) const SizedBox.shrink(),
          ]),
        ),
      ],
    ]);
  }

  Widget _buildFillBlankInput() {
    final isCorrect = _revealed && _blankInput.trim().toLowerCase() == (widget.qa.blankAnswer ?? '').toLowerCase();
    final isWrong = _revealed && !isCorrect;

    return Column(children: [
      Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _revealed ? (isCorrect ? AppColors.success : AppColors.error) : AppColors.border,
            width: _revealed ? 1.5 : 0.5,
          ),
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _blankInput = v),
              enabled: !_revealed,
              style: GoogleFonts.hindSiliguri(fontSize: 15, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'এখানে উত্তর লিখুন...',
                hintStyle: GoogleFonts.hindSiliguri(color: AppColors.textHint, fontSize: 14),
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          if (!_revealed)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ElevatedButton(
                onPressed: _blankInput.trim().isNotEmpty ? () => setState(() => _revealed = true) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text('জমা দিন', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
        ]),
      ),
      if (_revealed) ...[
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isCorrect ? AppColors.success.withValues(alpha: 0.08) : AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(isCorrect ? Icons.check_circle_rounded : Icons.info_rounded, color: isCorrect ? AppColors.success : AppColors.error, size: 18),
              const SizedBox(width: 8),
              Text(isCorrect ? 'সঠিক! 🎉' : 'সঠিক উত্তর:', style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w600, color: isCorrect ? AppColors.success : AppColors.error)),
            ]),
            if (isWrong) ...[
              const SizedBox(height: 6),
              Text(widget.qa.blankAnswer ?? '', style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ]),
        ),
      ],
    ]);
  }
}

// ─── Drag-Connect Widget ─────────────────────────────────────────────────────

class _ConnectingAnswerWidget extends StatefulWidget {
  final ImportantPointQA qa;
  const _ConnectingAnswerWidget({required this.qa});

  @override
  State<_ConnectingAnswerWidget> createState() => _ConnectingAnswerWidgetState();
}

class _ConnectingAnswerWidgetState extends State<_ConnectingAnswerWidget> {
  final _stackKey = GlobalKey();
  late final Map<String, GlobalKey> _leftKeys;
  late final Map<String, GlobalKey> _rightKeys;

  final Map<String, String?> _matches = {};
  String? _draggingLeft;
  Offset? _dragLocalPos;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _leftKeys = {for (final l in (widget.qa.leftItems ?? [])) l: GlobalKey()};
    _rightKeys = {for (final r in (widget.qa.rightItems ?? [])) r: GlobalKey()};
  }

  Offset _localCenterOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stackBox == null) return Offset.zero;
    final pos = stackBox.globalToLocal(box.localToGlobal(Offset.zero));
    return pos + Offset(box.size.width / 2, box.size.height / 2);
  }

  void _startDrag(String left, DragStartDetails d) {
    if (_revealed) return;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return;
    _matches.remove(left);
    setState(() {
      _draggingLeft = left;
      _dragLocalPos = stackBox.globalToLocal(d.globalPosition);
    });
  }

  void _updateDrag(DragUpdateDetails d) {
    if (_draggingLeft == null) return;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return;
    setState(() => _dragLocalPos = stackBox.globalToLocal(d.globalPosition));
  }

  void _endDrag(DragEndDetails d) {
    if (_draggingLeft == null || _dragLocalPos == null) {
      setState(() { _draggingLeft = null; _dragLocalPos = null; });
      return;
    }
    String? hitRight;
    double minDist = 55.0;
    for (final r in (widget.qa.rightItems ?? [])) {
      final c = _localCenterOf(_rightKeys[r]!);
      final dist = (_dragLocalPos! - c).distance;
      if (dist < minDist && !_matches.containsValue(r)) {
        minDist = dist;
        hitRight = r;
      }
    }
    setState(() {
      if (hitRight != null) _matches[_draggingLeft!] = hitRight;
      _draggingLeft = null;
      _dragLocalPos = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.qa.leftItems ?? [];
    final right = widget.qa.rightItems ?? [];
    final allMatched = left.every((l) => _matches[l] != null);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Instructions
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.accentPink.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.accentPink.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          const Icon(Icons.swipe_rounded, size: 16, color: AppColors.accentPink),
          const SizedBox(width: 8),
          Expanded(child: Text('বাম থেকে টেনে ডানে মেলান', style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.accentPink))),
        ]),
      ),

      // Drag area (Stack)
      Stack(
        key: _stackKey,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                child: Column(
                  children: left.map((l) {
                    final isMatched = _matches[l] != null;
                    final isDragging = _draggingLeft == l;
                    bool isCorrect = false;
                    if (_revealed && isMatched) {
                      isCorrect = widget.qa.correctMatches?.any((m) => m.left == l && m.right == _matches[l]) ?? false;
                    }
                    return GestureDetector(
                      onPanStart: (d) => _startDrag(l, d),
                      onPanUpdate: _updateDrag,
                      onPanEnd: _endDrag,
                      child: AnimatedContainer(
                        key: _leftKeys[l],
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: _revealed
                              ? (isCorrect ? AppColors.success.withValues(alpha: 0.08) : AppColors.error.withValues(alpha: 0.08))
                              : isDragging
                                  ? AppColors.accentPink.withValues(alpha: 0.1)
                                  : isMatched
                                      ? AppColors.primary.withValues(alpha: 0.06)
                                      : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _revealed
                                ? (isCorrect ? AppColors.success : AppColors.error)
                                : isDragging
                                    ? AppColors.accentPink
                                    : isMatched
                                        ? AppColors.primary.withValues(alpha: 0.5)
                                        : AppColors.border,
                            width: isDragging || isMatched || _revealed ? 1.5 : 0.5,
                          ),
                        ),
                        child: Row(children: [
                          Expanded(child: Text(l, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                          if (_revealed && isCorrect) const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success)
                          else if (_revealed && !isCorrect) const Icon(Icons.cancel_rounded, size: 14, color: AppColors.error)
                          else Icon(Icons.drag_indicator_rounded, size: 16, color: isDragging ? AppColors.accentPink : AppColors.textHint),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(width: 44), // gap for bezier lines

              // Right column
              Expanded(
                child: Column(
                  children: right.map((r) {
                    final isUsed = _matches.containsValue(r);
                    String? matchedLeft;
                    for (final e in _matches.entries) { if (e.value == r) { matchedLeft = e.key; break; } }
                    bool isCorrect = false;
                    if (_revealed && matchedLeft != null) {
                      isCorrect = widget.qa.correctMatches?.any((m) => m.left == matchedLeft && m.right == r) ?? false;
                    }
                    return AnimatedContainer(
                      key: _rightKeys[r],
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: _revealed && isUsed
                            ? (isCorrect ? AppColors.success.withValues(alpha: 0.08) : AppColors.error.withValues(alpha: 0.08))
                            : isUsed
                                ? AppColors.primary.withValues(alpha: 0.06)
                                : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _revealed && isUsed
                              ? (isCorrect ? AppColors.success : AppColors.error)
                              : isUsed
                                  ? AppColors.primary.withValues(alpha: 0.5)
                                  : AppColors.border,
                          width: isUsed || _revealed ? 1.5 : 0.5,
                        ),
                      ),
                      child: Row(children: [
                        if (_revealed && isUsed && isCorrect) ...[const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success), const SizedBox(width: 6)],
                        if (_revealed && isUsed && !isCorrect) ...[const Icon(Icons.cancel_rounded, size: 14, color: AppColors.error), const SizedBox(width: 6)],
                        Expanded(child: Text(r, style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textPrimary))),
                      ]),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          // Connection lines overlay
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConnectionLinePainter(
                  matches: _matches,
                  draggingLeft: _draggingLeft,
                  dragLocalPos: _dragLocalPos,
                  leftKeys: _leftKeys,
                  rightKeys: _rightKeys,
                  stackKey: _stackKey,
                  revealed: _revealed,
                  correctMatches: widget.qa.correctMatches ?? [],
                ),
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 4),

      // Submit button
      if (!_revealed)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: allMatched ? () => setState(() => _revealed = true) : null,
            icon: Icon(allMatched ? Icons.check_rounded : Icons.link_rounded, size: 18),
            label: Text(
              allMatched ? 'উত্তর চেক করুন' : '${_matches.length}/${left.length} মেলানো হয়েছে',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPink,
              disabledBackgroundColor: AppColors.accentPink.withValues(alpha: 0.3),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),

      // Correct answers reveal
      if (_revealed) ...[
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('✅ সঠিক মিলকরণ:', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success)),
            const SizedBox(height: 8),
            ...widget.qa.correctMatches!.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Expanded(child: Text(m.left, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                Expanded(child: Text(m.right, style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textPrimary))),
              ]),
            )),
          ]),
        ),
      ],
    ]);
  }
}

// ─── Connection Line Painter ──────────────────────────────────────────────────

class _ConnectionLinePainter extends CustomPainter {
  final Map<String, String?> matches;
  final String? draggingLeft;
  final Offset? dragLocalPos;
  final Map<String, GlobalKey> leftKeys;
  final Map<String, GlobalKey> rightKeys;
  final GlobalKey stackKey;
  final bool revealed;
  final List<MatchPair> correctMatches;

  _ConnectionLinePainter({
    required this.matches,
    required this.draggingLeft,
    required this.dragLocalPos,
    required this.leftKeys,
    required this.rightKeys,
    required this.stackKey,
    required this.revealed,
    required this.correctMatches,
  });

  Offset _centerOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final stackBox = stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stackBox == null) return Offset.zero;
    final pos = stackBox.globalToLocal(box.localToGlobal(Offset.zero));
    return pos + Offset(box.size.width / 2, box.size.height / 2);
  }

  void _drawLine(Canvas canvas, Offset start, Offset end, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(start.dx, start.dy);
    final midX = (start.dx + end.dx) / 2;
    path.cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);

    // Dots at ends
    canvas.drawCircle(start, 4.5, Paint()..color = color);
    canvas.drawCircle(end, 4.5, Paint()..color = color);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final entry in matches.entries) {
      if (entry.value == null) continue;
      final start = _centerOf(leftKeys[entry.key]!);
      final end = _centerOf(rightKeys[entry.value]!);
      if (start == Offset.zero || end == Offset.zero) continue;

      Color color = const Color(0xFF4A6CF7);
      if (revealed) {
        final correct = correctMatches.any((m) => m.left == entry.key && m.right == entry.value);
        color = correct ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
      }
      _drawLine(canvas, start, end, color.withValues(alpha: 0.75));
    }

    // Active drag line
    if (draggingLeft != null && dragLocalPos != null) {
      final start = _centerOf(leftKeys[draggingLeft]!);
      if (start != Offset.zero) {
        _drawLine(canvas, start, dragLocalPos!, const Color(0xFFFF2E88).withValues(alpha: 0.7));
      }
    }
  }

  @override
  bool shouldRepaint(_ConnectionLinePainter old) => true;
}
