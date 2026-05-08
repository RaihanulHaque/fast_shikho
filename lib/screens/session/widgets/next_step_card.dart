import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

class NextStepCard extends StatelessWidget {
  final int stepIndex; // 0-based current step (0–2)
  final String nextStepName;
  final int xp;
  final VoidCallback onNext;

  const NextStepCard({
    super.key,
    required this.stepIndex,
    required this.nextStepName,
    required this.xp,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final completionPct = ((stepIndex + 1) / 4 * 100).round();
    final nextStepNum = (stepIndex + 2).toString().padLeft(2, '0');

    return Column(
      children: [
        // Divider
        Row(children: [
          Expanded(child: Divider(color: AppColors.border, thickness: 0.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '// পরের ধাপ //',
              style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.textHint, letterSpacing: 2),
            ),
          ),
          Expanded(child: Divider(color: AppColors.border, thickness: 0.5)),
        ]),
        const SizedBox(height: 16),

        // Gradient card (matches app primary palette)
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Step badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1),
                      ),
                      child: Text(
                        'STEP $nextStepNum',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Labels
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextStepName,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'পরবর্তী ধাপ  ·  +$xp XP',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.75),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arrow button (white circle)
                    GestureDetector(
                      onTap: onNext,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress strip
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: completionPct / 100,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$completionPct% সম্পন্ন',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
