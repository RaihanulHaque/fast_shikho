import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../models/quick_test.dart';
import '../../widgets/panda_face.dart';

class QuickTestTab extends StatefulWidget {
  final List<QuickTestMCQ> questions;
  final int stepIndex;
  final void Function(double)? onScrollProgress;
  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;

  const QuickTestTab({
    super.key,
    required this.questions,
    this.stepIndex = 3,
    this.onScrollProgress,
    this.onCorrect,
    this.onWrong,
  });

  @override
  State<QuickTestTab> createState() => _QuickTestTabState();
}

class _QuickTestTabState extends State<QuickTestTab> {
  int _currentIndex = 0;
  bool _showScoreCard = false;
  int _correct = 0;
  int _xp = 0;
  String? _selectedOption;
  bool _answeredCurrent = false;

  void _reportProgress() {
    if (widget.questions.isEmpty) return;
    widget.onScrollProgress?.call((_currentIndex + 1) / widget.questions.length);
  }

  void _onOptionTap(String option) {
    if (_answeredCurrent) return;
    HapticFeedback.mediumImpact();
    final isCorrect = option == widget.questions[_currentIndex].correctAnswer;
    setState(() {
      _selectedOption = option;
      _answeredCurrent = true;
      if (isCorrect) {
        _correct++;
        _xp += 10;
      } else {
        _xp += 2;
      }
    });
    if (isCorrect) {
      widget.onCorrect?.call();
    } else {
      widget.onWrong?.call();
    }
  }

  void _onNext() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answeredCurrent = false;
      });
      _reportProgress();
    } else {
      setState(() => _showScoreCard = true);
      widget.onScrollProgress?.call(1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showScoreCard) return _buildScoreCard();

    final q = widget.questions[_currentIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_bengali(_currentIndex + 1)}. ${q.question}',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ...q.options.entries.map((e) => _buildOption(e.key, e.value, q.correctAnswer)),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: _answeredCurrent
              ? Container(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: _DuoBtn(
                    label: _currentIndex == widget.questions.length - 1
                        ? 'ফলাফল দেখুন'
                        : 'পরবর্তী প্রশ্ন',
                    enabled: true,
                    onTap: _onNext,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildOption(String key, String value, String correctAnswer) {
    final isSelected = key == _selectedOption;
    final isCorrect = key == correctAnswer;

    Color bg = AppColors.darkCard;
    Color borderColor = AppColors.border;
    Color textColor = AppColors.textPrimary;
    Color? trailingColor;
    IconData? trailingIcon;

    if (_answeredCurrent) {
      if (isCorrect) {
        bg = AppColors.primary.withValues(alpha: 0.12);
        borderColor = AppColors.primary;
        textColor = AppColors.primary;
        trailingIcon = Icons.check;
        trailingColor = AppColors.primary;
      } else if (isSelected) {
        bg = AppColors.error.withValues(alpha: 0.12);
        borderColor = AppColors.error;
        textColor = AppColors.error;
        trailingIcon = Icons.close;
        trailingColor = AppColors.error;
      }
    }

    return GestureDetector(
      onTap: () => _onOptionTap(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: (isSelected || (_answeredCurrent && isCorrect)) ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (trailingIcon != null) Icon(trailingIcon, color: trailingColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    final pct = widget.questions.isEmpty ? 0.0 : _correct / widget.questions.length;
    final String title;
    final String subtitle;
    if (pct >= 0.8) {
      title = 'দারুণ হয়েছে!';
      subtitle = 'পান্ডা খুব খুশি\nএভাবেই চালিয়ে যাও!';
    } else if (pct >= 0.5) {
      title = 'মোটামুটি ভালো';
      subtitle = 'আরেকটু ভালো করতে পারতে\nআবার চেষ্টা করো!';
    } else {
      title = 'এইটা কিন্তু ঠিক হয় নাই';
      subtitle = 'এভাবে হলে পান্ডা খুশি না\nআবার ট্রাই করো, তুমি পারবে';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          PandaFace(
            size: 110,
            expression: pct >= 0.8
                ? PandaExpression.happy
                : pct >= 0.5
                    ? PandaExpression.idle
                    : PandaExpression.sad,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.hindSiliguri(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: pct >= 0.5 ? AppColors.primary : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(children: [
                    Text('কুইজ স্কোর',
                        style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textHint)),
                    const SizedBox(height: 6),
                    Text('$_correct/${widget.questions.length}',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  ]),
                ),
              ),
              Container(width: 1, height: 50, color: AppColors.border),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(children: [
                    Text('প্রাপ্ত পয়েন্ট',
                        style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textHint)),
                    const SizedBox(height: 6),
                    Text('+$_xp',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.xpYellow)),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 28),
          _DuoBtn(label: 'সব উত্তর দেখুন', enabled: true, onTap: () {}),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              'ড্যাশবোর্ডে ফিরে যান',
              style: GoogleFonts.hindSiliguri(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _bengali(int n) {
    const d = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return n.toString().split('').map((c) {
      final i = int.tryParse(c);
      return i != null ? d[i] : c;
    }).join();
  }
}

// ─── Duo 3D press button ───────────────────────────────────────────────────────

class _DuoBtn extends StatefulWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const _DuoBtn({required this.label, required this.enabled, required this.onTap});

  @override
  State<_DuoBtn> createState() => _DuoBtnState();
}

class _DuoBtnState extends State<_DuoBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final en = widget.enabled;
    return GestureDetector(
      onTapDown: en ? (_) => setState(() => _pressed = true) : null,
      onTapUp: en
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24, _pressed ? 18 : 16, 24, _pressed ? 14 : 16),
        margin: EdgeInsets.only(top: _pressed ? 2 : 0),
        decoration: BoxDecoration(
          color: en ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            bottom: BorderSide(
              color: en ? AppColors.primaryDark : Colors.transparent,
              width: _pressed ? 1 : 3,
            ),
          ),
        ),
        child: Text(
          widget.label,
          textAlign: TextAlign.center,
          style: GoogleFonts.hindSiliguri(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: en ? Colors.black : Colors.black.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

