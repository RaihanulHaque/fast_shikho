import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/app_services.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text('প্রোফাইল', style: GoogleFonts.hindSiliguri(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 24),
              // Avatar
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))]),
                child: Center(child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
              const SizedBox(height: 16),
              Text(user.fullName, style: GoogleFonts.hindSiliguri(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(user.phoneNumber, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              // Info cards
              _InfoRow(icon: Icons.school_rounded, label: 'ক্লাস লেভেল', value: user.classLevel),
              const SizedBox(height: 10),
              _InfoRow(icon: Icons.stars_rounded, label: 'পয়েন্ট', value: '${user.pointsBalance}'),
              const SizedBox(height: 10),
              _InfoRow(icon: Icons.folder_rounded, label: 'মোট সেশন', value: '${context.watch<SessionService>().sessions.length}'),
              const SizedBox(height: 32),
              // Edit class level
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border, width: 0.5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ক্লাস লেভেল পরিবর্তন', style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    Row(
                      children: ['SSC', 'HSC', 'Admission'].map((level) {
                        final isSelected = user.classLevel == level;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => auth.updateProfile(classLevel: level),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.scaffoldBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                              ),
                              child: Center(child: Text(level, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textSecondary))),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Logout
              SizedBox(
                width: double.infinity, height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: Text('লগআউট', style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border, width: 0.5)),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: GoogleFonts.hindSiliguri(fontSize: 14, color: AppColors.textSecondary))),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ]),
    );
  }
}
