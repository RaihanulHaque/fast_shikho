import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/app_services.dart';
import '../../models/study_package.dart';
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
  static const _stepXP = [20, 30, 25, 25];

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final ss = context.read<SessionService>();
    final pkg = await ss.getSessionContent(widget.sessionId);
    if (mounted) setState(() { _package = pkg; _loading = false; });
  }

  void _goToStep(int step) {
    if (step < 0 || step > 3) return;
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = step);
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
        title: Text(
          _package?.sessionTitle ?? 'লোড হচ্ছে...',
          style: GoogleFonts.hindSiliguri(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: _loading
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(54),
                child: _StepIndicator(
                  currentStep: _currentStep,
                  labels: _stepLabels,
                  onTap: (i) { if (i <= _currentStep) _goToStep(i); },
                ),
              ),
      ),
      body: _loading
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text('কন্টেন্ট লোড হচ্ছে...', style: GoogleFonts.hindSiliguri(color: AppColors.textSecondary)),
              ]),
            )
          : PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                KeyPointsTab(
                  keyPoints: _package!.keyPoints,
                  onNext: () => _goToStep(1),
                  stepIndex: 0,
                  nextStepName: _stepLabels[1],
                  nextStepXP: _stepXP[1],
                ),
                PracticeTab(
                  problems: _package!.practiceExamples,
                  onNext: () => _goToStep(2),
                  stepIndex: 1,
                  nextStepName: _stepLabels[2],
                  nextStepXP: _stepXP[2],
                ),
                TopQuestionsTab(
                  questions: _package!.topQuestions,
                  onNext: () => _goToStep(3),
                  stepIndex: 2,
                  nextStepName: _stepLabels[3],
                  nextStepXP: _stepXP[3],
                ),
                QuickTestTab(
                  questions: _package!.quickTest,
                  stepIndex: 3,
                ),
              ],
            ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> labels;
  final void Function(int) onTap;

  const _StepIndicator({
    required this.currentStep,
    required this.labels,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isActive = i == currentStep;
          final isDone = i < currentStep;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Padding(
                padding: EdgeInsets.only(right: i < labels.length - 1 ? 6 : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: isActive ? AppColors.primaryGradient : null,
                        color: isDone ? AppColors.success : (isActive ? null : AppColors.border),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      labels[i],
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                        color: isActive
                            ? AppColors.primary
                            : isDone
                                ? AppColors.success
                                : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
