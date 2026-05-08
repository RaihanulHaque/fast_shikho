import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../models/top_question.dart';

class TopQuestionsTab extends StatefulWidget {
  final List<TopQuestion> questions;
  final VoidCallback? onNext;
  final int stepIndex;
  final String nextStepName;
  final int nextStepXP;
  final void Function(double)? onScrollProgress;
  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;

  const TopQuestionsTab({
    super.key,
    required this.questions,
    this.onNext,
    this.stepIndex = 2,
    this.nextStepName = '',
    this.nextStepXP = 0,
    this.onScrollProgress,
    this.onCorrect,
    this.onWrong,
  });

  @override
  State<TopQuestionsTab> createState() => _TopQuestionsTabState();
}

class _TopQuestionsTabState extends State<TopQuestionsTab> {
  String _sourceFilter = 'all';
  String _typeFilter = 'all';
  int _answeredCount = 0;
  late final ScrollController _sc;

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

  List<TopQuestion> get _filteredQuestions {
    return widget.questions.where((q) {
      // Source filter
      if (_sourceFilter == 'board') {
        final src = q.source.toLowerCase();
        if (!src.contains('board') && !src.contains('বোর্ড')) return false;
      } else if (_sourceFilter == 'admission') {
        final src = q.source.toLowerCase();
        if (!src.contains('admission') &&
            !src.contains('du') &&
            !src.contains('buet') &&
            !src.contains('medical') &&
            !src.contains('cuet') &&
            !src.contains('ভর্তি')) {
          return false;
        }
      }

      // Type filter
      if (_typeFilter == 'mcq') {
        if (q.questionType != 'mcq') return false;
      } else if (_typeFilter == 'cq') {
        if (q.questionType == 'mcq') return false;
      }

      return true;
    }).toList();
  }

  /// Convert English digit to Bengali digit
  static String _toBengaliNumeral(int n) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return n.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? bengaliDigits[d] : c;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredQuestions;

    return ListView(
      controller: _sc,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        // ── Filter Chips ──────────────────────────────────────────────────
        _FilterChipBar(
          sourceFilter: _sourceFilter,
          typeFilter: _typeFilter,
          onSourceChanged: (v) => setState(() => _sourceFilter = v),
          onTypeChanged: (v) => setState(() => _typeFilter = v),
        ),
        const SizedBox(height: 20),

        // ── Question list ─────────────────────────────────────────────────
        ...filtered.asMap().entries.map((entry) {
          final i = entry.key;
          final q = entry.value;
          return _QuestionCard(
            question: q,
            displayIndex: i + 1,
            bengaliIndex: _toBengaliNumeral(i + 1),
            onAnswered: () => setState(() => _answeredCount++),
            onCorrect: widget.onCorrect,
            onWrong: widget.onWrong,
          );
        }),

        // ── Empty state ───────────────────────────────────────────────────
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.filter_list_off_rounded,
                      size: 40, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text(
                    'এই ফিল্টারে কোনো প্রশ্ন নেই',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Next step button ──────────────────────────────────────────────
        if (widget.onNext != null) ...[
          const SizedBox(height: 16),
          _DuoBtn(label: 'কুইজ দেই 🚀', onTap: widget.onNext!),
        ],
      ],
    );
  }
}

// ─── Filter Chip Bar ──────────────────────────────────────────────────────────

class _FilterChipBar extends StatelessWidget {
  final String sourceFilter;
  final String typeFilter;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<String> onTypeChanged;

  const _FilterChipBar({
    required this.sourceFilter,
    required this.typeFilter,
    required this.onSourceChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Source type
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _FilterChip(
              label: 'বোর্ড প্রশ্ন',
              isActive: sourceFilter == 'board',
              onTap: () => onSourceChanged(
                  sourceFilter == 'board' ? 'all' : 'board'),
            ),
            _FilterChip(
              label: 'ভর্তি পরীক্ষা',
              isActive: sourceFilter == 'admission',
              onTap: () => onSourceChanged(
                  sourceFilter == 'admission' ? 'all' : 'admission'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2: Question type
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _FilterChip(
              label: 'MCQ',
              isActive: typeFilter == 'mcq',
              onTap: () =>
                  onTypeChanged(typeFilter == 'mcq' ? 'all' : 'mcq'),
            ),
            _FilterChip(
              label: 'CQ',
              isActive: typeFilter == 'cq',
              onTap: () =>
                  onTypeChanged(typeFilter == 'cq' ? 'all' : 'cq'),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.cardBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Question Card ────────────────────────────────────────────────────────────

class _QuestionCard extends StatefulWidget {
  final TopQuestion question;
  final int displayIndex;
  final String bengaliIndex;
  final VoidCallback onAnswered;
  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;

  const _QuestionCard({
    required this.question,
    required this.displayIndex,
    required this.bengaliIndex,
    required this.onAnswered,
    this.onCorrect,
    this.onWrong,
  });

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

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Source badge ─────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              q.source,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // ── Question text with Bengali numeral ──────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              '${widget.bengaliIndex}. ${q.questionText}',
              style: GoogleFonts.hindSiliguri(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),

          // ── Answer area ─────────────────────────────────────────────
          if (q.questionType == 'mcq') _buildMCQ(q),
          if (q.questionType == 'short_answer' ||
              q.questionType == 'creative')
            _buildShortAnswer(q),
          if (q.questionType == 'broad_answer') _buildBroadAnswer(q),

          // ── Explanation ─────────────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: _revealed
                ? Container(
                    margin: const EdgeInsets.only(top: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppColors.primary.withValues(alpha: 0.07),
                        AppColors.secondary.withValues(alpha: 0.04),
                      ]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💬',
                            style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            q.explanation,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // ── Separator ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Divider(color: AppColors.divider, height: 1),
          ),
        ],
      ),
    );
  }

  // ── MCQ: full-width dark option cards ──────────────────────────────────

  Widget _buildMCQ(TopQuestion q) {
    return Column(
      children: q.options!.entries.map((e) {
        final sel = _selectedMCQ == e.key;
        final correct = e.key == q.correctOption;

        Color bg = AppColors.cardBg;
        Color borderColor = AppColors.cardBorder;

        if (_revealed && correct) {
          bg = AppColors.success.withValues(alpha: 0.1);
          borderColor = AppColors.success;
        } else if (_revealed && sel && !correct) {
          bg = AppColors.error.withValues(alpha: 0.1);
          borderColor = AppColors.error;
        } else if (sel && !_revealed) {
          bg = AppColors.primary.withValues(alpha: 0.08);
          borderColor = AppColors.primary;
        }

        return GestureDetector(
          onTap: _revealed
              ? null
              : () {
                  final isCorrect = e.key == q.correctOption;
                  setState(() => _selectedMCQ = e.key);
                  _reveal();
                  if (isCorrect) {
                    widget.onCorrect?.call();
                  } else {
                    widget.onWrong?.call();
                  }
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: (sel || (_revealed && correct)) ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    e.value,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (_revealed && correct)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 20),
                if (_revealed && sel && !correct)
                  const Icon(Icons.cancel_rounded,
                      color: AppColors.error, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Short / Creative answer ───────────────────────────────────────────

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
                label: Text('উত্তর দেখুন',
                    style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Text('উত্তর',
                        style: GoogleFonts.hindSiliguri(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success)),
                  ]),
                  const SizedBox(height: 8),
                  Text(q.answer ?? '',
                      style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.5)),
                ],
              ),
            ),
    );
  }

  // ── Broad answer: selectable points ───────────────────────────────────

  Widget _buildBroadAnswer(TopQuestion q) {
    final points = q.selectablePoints ?? [];
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10)),
        child: Text('✅ সঠিক বিবৃতিগুলো বাছাই করুন:',
            style: GoogleFonts.hindSiliguri(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500)),
      ),
      ...points.asMap().entries.map((e) {
        final sel = _selectedPoints.contains(e.key);
        Color bg = AppColors.cardBg;
        Color borderColor = AppColors.cardBorder;
        if (_revealed && e.value.isCorrect) {
          bg = AppColors.success.withValues(alpha: 0.08);
          borderColor = AppColors.success;
        } else if (_revealed && sel && !e.value.isCorrect) {
          bg = AppColors.error.withValues(alpha: 0.08);
          borderColor = AppColors.error;
        } else if (sel) {
          bg = AppColors.primary.withValues(alpha: 0.06);
          borderColor = AppColors.primary;
        }

        return GestureDetector(
          onTap: _revealed
              ? null
              : () => setState(() {
                    if (sel) {
                      _selectedPoints.remove(e.key);
                    } else {
                      _selectedPoints.add(e.key);
                    }
                  }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: borderColor,
                  width: sel || _revealed ? 1.5 : 1),
            ),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.cardBg,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                      color: sel ? AppColors.primary : AppColors.border,
                      width: 1.5),
                ),
                child: sel
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(e.value.point,
                      style: GoogleFonts.hindSiliguri(
                          fontSize: 13, color: AppColors.textPrimary))),
              if (_revealed && e.value.isCorrect)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 18),
              if (_revealed && !e.value.isCorrect)
                const Icon(Icons.cancel_rounded,
                    color: AppColors.error, size: 18),
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
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text('চেক করুন',
                  style: GoogleFonts.hindSiliguri(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
    ]);
  }
}

// ─── Duo 3D press button ───────────────────────────────────────────────────────

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
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24, _pressed ? 18 : 16, 24, _pressed ? 14 : 16),
        margin: EdgeInsets.only(top: _pressed ? 2 : 0),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            bottom: BorderSide(color: AppColors.primaryDark, width: _pressed ? 1 : 3),
          ),
        ),
        child: Text(
          widget.label,
          textAlign: TextAlign.center,
          style: GoogleFonts.hindSiliguri(
            fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black,
          ),
        ),
      ),
    );
  }
}
