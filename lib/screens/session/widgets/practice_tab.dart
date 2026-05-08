import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../models/practice_example.dart';

class PracticeTab extends StatefulWidget {
  final List<PracticeExample> problems;
  final VoidCallback? onNext;
  final int stepIndex;
  final String nextStepName;
  final int nextStepXP;
  final void Function(double)? onScrollProgress;
  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;

  const PracticeTab({
    super.key,
    required this.problems,
    this.onNext,
    this.stepIndex = 1,
    this.nextStepName = '',
    this.nextStepXP = 0,
    this.onScrollProgress,
    this.onCorrect,
    this.onWrong,
  });

  @override
  State<PracticeTab> createState() => _PracticeTabState();
}

class _PracticeTabState extends State<PracticeTab> {
  int _points = 500;
  String _typeFilter = 'all'; // 'all' | 'mcq' | 'cq'
  late final ScrollController _sc;

  void _earnPoints(int amount) => setState(() => _points += amount);

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

  void _spendPoints(int cost) => setState(() => _points = (_points - cost).clamp(0, 9999));

  List<PracticeExample> get _filtered {
    if (_typeFilter == 'cq') return widget.problems.where((p) => p.isMath).toList();
    if (_typeFilter == 'mcq') return widget.problems.where((p) => !p.isMath).toList();
    return widget.problems;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(children: [
      // ── Filter pills ────────────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Row(children: [
          _Pill(
            label: 'MCQ',
            active: _typeFilter == 'mcq',
            onTap: () => setState(() => _typeFilter = _typeFilter == 'mcq' ? 'all' : 'mcq'),
          ),
          const SizedBox(width: 10),
          _Pill(
            label: 'CQ (গাণিতিক)',
            active: _typeFilter == 'cq',
            onTap: () => setState(() => _typeFilter = _typeFilter == 'cq' ? 'all' : 'cq'),
          ),
        ]),
      ),
      const SizedBox(height: 14),

      // ── Problem list ────────────────────────────────────────────────────────
      Expanded(
        child: ListView.builder(
          controller: _sc,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          itemCount: filtered.isEmpty ? 1 : filtered.length,
          itemBuilder: (ctx, i) {
            if (filtered.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'এই ফিল্টারে কোনো সমস্যা নেই',
                    style: GoogleFonts.hindSiliguri(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ),
              );
            }
            return _ProblemCard(
              key: ValueKey('${_typeFilter}_$i'),
              problem: filtered[i],
              index: i,
              pointsAvailable: _points,
              onSpendPoints: _spendPoints,
              onEarnPoints: _earnPoints,
              onCorrect: widget.onCorrect,
              onWrong: widget.onWrong,
            );
          },
        ),
      ),

      // ── Sticky bottom button ────────────────────────────────────────────────
      if (widget.onNext != null)
        Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: _DuoBtn(
            label: 'পরের ধাপ',
            onTap: widget.onNext!,
          ),
        ),
    ]);
  }
}

// ─── Filter pill ──────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Pill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.cardBorder,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Problem card (flat, always expanded) ────────────────────────────────────

class _ProblemCard extends StatefulWidget {
  final PracticeExample problem;
  final int index;
  final int pointsAvailable;
  final void Function(int) onSpendPoints;
  final void Function(int) onEarnPoints;
  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;

  const _ProblemCard({
    super.key,
    required this.problem,
    required this.index,
    required this.pointsAvailable,
    required this.onSpendPoints,
    required this.onEarnPoints,
    this.onCorrect,
    this.onWrong,
  });

  @override
  State<_ProblemCard> createState() => _ProblemCardState();
}

class _ProblemCardState extends State<_ProblemCard> {
  final Set<int> _revealedHints = {};
  bool _answerRevealed = false;
  String? _selectedChoice; // which answer option the user tapped

  static const _hintCost = 25;

  void _unlockHint(int i) {
    if (_revealedHints.contains(i)) return;
    if (widget.pointsAvailable < _hintCost) return;
    HapticFeedback.lightImpact();
    widget.onSpendPoints(_hintCost);
    setState(() => _revealedHints.add(i));
  }

  void _revealAnswer() {
    HapticFeedback.mediumImpact();
    setState(() => _answerRevealed = true);
  }

  static String _bengali(int n) {
    const d = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return n.toString().split('').map((c) {
      final i = int.tryParse(c);
      return i != null ? d[i] : c;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.problem;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Type tag + label
          Row(children: [
            _TypePill(isMath: p.isMath),
            const SizedBox(width: 10),
            Text(
              p.isMath ? 'সমস্যা সমাধান' : 'ধারণাগত প্রশ্ন',
              style: GoogleFonts.hindSiliguri(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ]),
          const SizedBox(height: 14),

          // Question number + text
          Text(
            '${_bengali(widget.index + 1)}. ${p.question}',
            style: GoogleFonts.hindSiliguri(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary, height: 1.5,
            ),
          ),
          const SizedBox(height: 18),

          // Hints
          ...p.steps.asMap().entries.map((e) => _buildHint(e.key, e.value)),

          const SizedBox(height: 12),

          // Answer choice grid (if available)
          if (p.answerChoices != null && p.answerChoices!.isNotEmpty)
            _buildChoiceGrid(p.answerChoices!, p.answer),

          const SizedBox(height: 8),

          // Reveal button (only if no choice made yet)
          if (!_answerRevealed)
            GestureDetector(
              onTap: _revealAnswer,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  'সঠিক উত্তর দেখা',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            )
          else ...[
            // Answer box
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text('সঠিক উত্তর: ${p.answer}',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary, height: 1.5,
                  )),
            ),
            // Reward badge (only shown when user guessed)
            if (_selectedChoice != null) ...[
              const SizedBox(height: 10),
              _selectedChoice == p.answer ||
                      (p.answerChoices?.any((c) =>
                              c == _selectedChoice &&
                              p.answer.toLowerCase().contains(c.toLowerCase().split(' ').first)) ==
                          true)
                  ? _RewardBadge(correct: true, points: 50)
                  : _RewardBadge(correct: false, points: 10),
            ],
          ],
        ]),
      ),
    );
  }

  Widget _buildChoiceGrid(List<String> choices, String correctAnswer) {
    final cols = choices.length <= 3 ? 3 : 2;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GridView.count(
        crossAxisCount: cols,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: cols == 3 ? 2.2 : 3.0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: choices.map((opt) {
          final isSel = _selectedChoice == opt;
          final isCorrect = opt == correctAnswer;

          Color bg = AppColors.darkCard;
          Color borderColor = AppColors.cardBorder;
          Color textColor = AppColors.textPrimary;

          if (_answerRevealed) {
            if (isCorrect) {
              bg = AppColors.primary.withValues(alpha: 0.12);
              borderColor = AppColors.primary;
              textColor = AppColors.primary;
            } else if (isSel) {
              bg = AppColors.error.withValues(alpha: 0.12);
              borderColor = AppColors.error;
              textColor = AppColors.error;
            }
          } else if (isSel) {
            bg = AppColors.primary.withValues(alpha: 0.1);
            borderColor = AppColors.primary;
          }

          return GestureDetector(
            onTap: _answerRevealed
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    final isCorrect = opt == correctAnswer;
                    setState(() {
                      _selectedChoice = opt;
                      _answerRevealed = true;
                    });
                    widget.onEarnPoints(isCorrect ? 50 : 10);
                    if (isCorrect) {
                      widget.onCorrect?.call();
                    } else {
                      widget.onWrong?.call();
                    }
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Text(
                  opt,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHint(int index, String content) {
    final isRevealed = _revealedHints.contains(index);
    final canAfford = widget.pointsAvailable >= _hintCost;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: isRevealed
            ? Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                    child: Row(children: [
                      Icon(Icons.lock_open_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('হিন্ট আনলকড!',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          )),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Text(content,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 13, color: AppColors.textPrimary, height: 1.5,
                        )),
                  ),
                ]),
              )
            : GestureDetector(
                onTap: canAfford ? () => _unlockHint(index) : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 16, color: canAfford ? AppColors.accentCyan : AppColors.textHint),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'হিন্ট ${_bengali(index + 1)} দেখতে ট্যাপ করুন (-${_bengali(_hintCost)} পয়েন্ট)',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 13,
                          color: canAfford ? AppColors.accentCyan : AppColors.textHint,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
      ),
    );
  }
}

// ─── Reward badge ─────────────────────────────────────────────────────────────

class _RewardBadge extends StatelessWidget {
  final bool correct;
  final int points;
  const _RewardBadge({required this.correct, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: correct
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: correct
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(children: [
        Text(correct ? '🎯 সঠিক উত্তর!' : '❌ ভুল হয়েছে',
            style: GoogleFonts.hindSiliguri(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: correct ? AppColors.primary : AppColors.error,
            )),
        const Spacer(),
        Text('+$points পয়েন্ট',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: correct ? AppColors.primary : AppColors.textSecondary,
            )),
      ]),
    );
  }
}

// ─── Type pill badge ──────────────────────────────────────────────────────────

class _TypePill extends StatelessWidget {
  final bool isMath;
  const _TypePill({required this.isMath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isMath
            ? const Color(0xFF7B2FBE).withValues(alpha: 0.15)
            : AppColors.accentCyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isMath ? 'গাণিতিক' : 'ধারণাগত',
        style: GoogleFonts.hindSiliguri(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isMath ? const Color(0xFFBB6BD9) : AppColors.accentCyan,
        ),
      ),
    );
  }
}

// ─── Duo 3D press button ──────────────────────────────────────────────────────

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
            bottom: BorderSide(
              color: AppColors.primaryDark,
              width: _pressed ? 1 : 3,
            ),
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
