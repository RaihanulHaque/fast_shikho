import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/app_services.dart';
import '../../models/study_package.dart';
import '../widgets/panda_face.dart';
import 'widgets/key_points_tab.dart';
import 'widgets/practice_tab.dart';
import 'widgets/top_questions_tab.dart';
import 'widgets/quick_test_tab.dart';

class SessionDetailScreen extends StatefulWidget {
  final String sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  StudyPackage? _package;
  bool _loading = true;

  static const _stepLabels = ['পাঠ', 'অনুশীলন', 'প্রশ্নব্যাংক', 'কুইক টেস্ট'];
  static const _appBarLabels = ['কনসেপ্ট', 'একটু অনুশীলন', 'বার বার আসা প্রশ্ন', 'কুইজ দেই'];
  static const _stepXP = [80, 250, 120, 1250];

  double _tabScrollProgress = 0.0;
  final _pandaExpression = ValueNotifier<PandaExpression>(PandaExpression.idle);

  void _onCorrectAnswer() {
    _pandaExpression.value = PandaExpression.happy;
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) _pandaExpression.value = PandaExpression.idle;
    });
  }

  void _onWrongAnswer() {
    _pandaExpression.value = PandaExpression.sad;
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _pandaExpression.value = PandaExpression.idle;
    });
  }

  void _onTabProgress(double p) {
    // Only track progress for Key Points tab (step 0)
    if (_currentStep != 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (_tabScrollProgress - p).abs() > 0.001) {
        setState(() => _tabScrollProgress = p);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final ss = context.read<SessionService>();
    final pkg = await ss.getSessionContent(widget.sessionId);
    if (mounted) {
      setState(() {
        _package = pkg;
        _loading = false;
      });
    }
  }

  void _goToStep(int step) {
    if (step < 0 || step > 3) return;
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentStep = step;
      _tabScrollProgress = 0.0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          _loading ? 'লোড হচ্ছে...' : _appBarLabels[_currentStep],
          style: GoogleFonts.hindSiliguri(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (_package != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder<PandaExpression>(
                    valueListenable: _pandaExpression,
                    builder: (ctx, expr, _) => PandaFace(size: 34, expression: expr),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.bolt_rounded, color: AppColors.xpYellow, size: 18),
                  Text(
                    '${_stepXP[_currentStep]}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.xpYellow,
                    ),
                  ),
                ],
              ),
            ),
        ],
        bottom: _loading || _currentStep != 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: AppColors.cardBorder),
              )
            : PreferredSize(
                preferredSize: const Size.fromHeight(58),
                child: _StepHeader(
                  progressValue: _tabScrollProgress,
                  onTap: (i) {
                    if (i <= _currentStep) _goToStep(i);
                  },
                ),
              ),
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'কন্টেন্ট লোড হচ্ছে...',
                    style: GoogleFonts.hindSiliguri(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                KeyPointsTab(
                  keyPoints: _package!.keyPoints,
                  sessionTitle: _package!.sessionTitle,
                  detectedSubject: _package!.detectedSubject,
                  onNext: () => _goToStep(1),
                  stepIndex: 0,
                  nextStepName: _stepLabels[1],
                  nextStepXP: _stepXP[1],
                  onScrollProgress: _onTabProgress,
                  onCorrect: _onCorrectAnswer,
                  onWrong: _onWrongAnswer,
                ),
                PracticeTab(
                  problems: _package!.practiceExamples,
                  onNext: () => _goToStep(2),
                  stepIndex: 1,
                  nextStepName: _stepLabels[2],
                  nextStepXP: _stepXP[2],
                  onScrollProgress: _onTabProgress,
                  onCorrect: _onCorrectAnswer,
                  onWrong: _onWrongAnswer,
                ),
                TopQuestionsTab(
                  questions: _package!.topQuestions,
                  onNext: () => _goToStep(3),
                  stepIndex: 2,
                  nextStepName: _stepLabels[3],
                  nextStepXP: _stepXP[3],
                  onScrollProgress: _onTabProgress,
                  onCorrect: _onCorrectAnswer,
                  onWrong: _onWrongAnswer,
                ),
                QuickTestTab(
                  questions: _package!.quickTest,
                  stepIndex: 3,
                  onScrollProgress: _onTabProgress,
                  onCorrect: _onCorrectAnswer,
                  onWrong: _onWrongAnswer,
                ),
              ],
            ),
    );
  }
}

// ─────────────────── Step Header ───────────────────

class _StepHeader extends StatelessWidget {
  final double progressValue;
  final void Function(int) onTap;

  const _StepHeader({
    required this.progressValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: progressValue.clamp(0.0, 1.0),
          minHeight: 8,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }
}
