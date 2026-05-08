import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/app_services.dart';
import '../widgets/panda_loading.dart';
import 'session_detail_screen.dart';

class NewSessionScreen extends StatefulWidget {
  const NewSessionScreen({super.key});

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  final List<String> _selectedFiles = [];
  bool _isUploading = false;
  String _uploadType = 'image';

  void _addDummyFile() {
    if (_selectedFiles.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('সর্বোচ্চ ৬টি ফাইল!',
              style: GoogleFonts.hindSiliguri()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() {
      _selectedFiles.add(_uploadType == 'pdf'
          ? 'document_page_${_selectedFiles.length + 1}.pdf'
          : 'image_${_selectedFiles.length + 1}.jpg');
    });
  }

  Future<void> _submit() async {
    if (_selectedFiles.isEmpty) return;
    setState(() => _isUploading = true);

    final ss = context.read<SessionService>();
    final session = await ss.createSession();
    final completed = await ss.uploadAndProcess(session.id);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SessionDetailScreen(sessionId: completed.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUploading) return const PandaLoadingScreen();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'নতুন সেশন',
          style: GoogleFonts.hindSiliguri(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.cardBorder),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Type toggle ──
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  _TypeTab(
                    label: 'ছবি',
                    icon: Icons.image_outlined,
                    isActive: _uploadType == 'image',
                    onTap: () => setState(() => _uploadType = 'image'),
                  ),
                  _TypeTab(
                    label: 'PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    isActive: _uploadType == 'pdf',
                    onTap: () => setState(() => _uploadType = 'pdf'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Upload area ──
            GestureDetector(
              onTap: _addDummyFile,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 200,
                decoration: BoxDecoration(
                  color: _selectedFiles.isNotEmpty
                      ? AppColors.primaryTintBg
                      : Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedFiles.isNotEmpty
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: Icon(
                        _uploadType == 'pdf'
                            ? Icons.upload_file_rounded
                            : Icons.add_photo_alternate_outlined,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _uploadType == 'pdf'
                          ? 'PDF আপলোড করুন (সর্বোচ্চ ৬ পৃষ্ঠা)'
                          : 'ছবি আপলোড করুন (সর্বোচ্চ ৬টি)',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ট্যাপ করুন ফাইল যোগ করতে',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── File list ──
            if (_selectedFiles.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, i) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _uploadType == 'pdf'
                              ? Icons.picture_as_pdf
                              : Icons.image,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedFiles[i],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _selectedFiles.removeAt(i)),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              const Spacer(),

            // ── Counter ──
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${_selectedFiles.length}/6 ফাইল',
                textAlign: TextAlign.center,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // ── Submit button (Duolingo-style 3D) ──
            _DuoButton(
              label: 'পাঠাও',
              onTap: _selectedFiles.isEmpty ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────── Duolingo-style button ───────────────────

class _DuoButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const _DuoButton({required this.label, this.onTap});

  @override
  State<_DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<_DuoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: 56,
        margin: EdgeInsets.only(top: _pressed ? 3 : 0),
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            bottom: BorderSide(
              color: enabled ? AppColors.primaryDark : Colors.transparent,
              width: _pressed ? 1 : 3,
            ),
          ),
          boxShadow: (!_pressed && enabled)
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            widget.label,
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────── Type Tab ───────────────────

class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TypeTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? Colors.black : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.black : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
