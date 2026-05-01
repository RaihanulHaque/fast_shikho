import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/app_services.dart';
import 'session_detail_screen.dart';

class NewSessionScreen extends StatefulWidget {
  const NewSessionScreen({super.key});

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  final List<String> _selectedFiles = [];
  bool _isUploading = false;
  String _uploadType = 'image'; // 'image' or 'pdf'

  void _addDummyFile() {
    if (_selectedFiles.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('সর্বোচ্চ ৬টি ফাইল!', style: GoogleFonts.hindSiliguri()), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() {
      _selectedFiles.add(_uploadType == 'pdf' ? 'document_page_${_selectedFiles.length + 1}.pdf' : 'image_${_selectedFiles.length + 1}.jpg');
    });
  }

  Future<void> _submit() async {
    if (_selectedFiles.isEmpty) return;
    setState(() => _isUploading = true);

    final ss = context.read<SessionService>();
    final session = await ss.createSession();
    final completed = await ss.uploadAndProcess(session.id);

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SessionDetailScreen(sessionId: completed.id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text('নতুন সেশন', style: GoogleFonts.hindSiliguri(fontSize: 20, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.scaffoldBg,
      ),
      body: _isUploading
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 3)),
                ),
                const SizedBox(height: 24),
                Text('প্রসেস হচ্ছে...', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text('AI তোমার নোট বিশ্লেষণ করছে', style: GoogleFonts.hindSiliguri(fontSize: 14, color: AppColors.textSecondary)),
              ]),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upload type toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border, width: 0.5)),
                    child: Row(
                      children: [
                        _TypeTab(label: 'ছবি', icon: Icons.image_outlined, isActive: _uploadType == 'image', onTap: () => setState(() => _uploadType = 'image')),
                        _TypeTab(label: 'PDF', icon: Icons.picture_as_pdf_outlined, isActive: _uploadType == 'pdf', onTap: () => setState(() => _uploadType = 'pdf')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Upload area
                  GestureDetector(
                    onTap: _addDummyFile,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5, strokeAlign: BorderSide.strokeAlignInside),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: Icon(_uploadType == 'pdf' ? Icons.upload_file_rounded : Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(height: 12),
                        Text(_uploadType == 'pdf' ? 'PDF আপলোড করুন (সর্বোচ্চ ৬ পৃষ্ঠা)' : 'ছবি আপলোড করুন (সর্বোচ্চ ৬টি)', style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Text('ট্যাপ করুন ফাইল যোগ করতে', style: GoogleFonts.hindSiliguri(fontSize: 12, color: AppColors.textHint)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // File list
                  if (_selectedFiles.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _selectedFiles.length,
                        itemBuilder: (context, i) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, width: 0.5)),
                          child: Row(children: [
                            Icon(_uploadType == 'pdf' ? Icons.picture_as_pdf : Icons.image, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text(_selectedFiles[i], style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary))),
                            GestureDetector(
                              onTap: () => setState(() => _selectedFiles.removeAt(i)),
                              child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textHint),
                            ),
                          ]),
                        ),
                      ),
                    )
                  else
                    const Spacer(),

                  // Counter
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('${_selectedFiles.length}/6 ফাইল', textAlign: TextAlign.center, style: GoogleFonts.hindSiliguri(fontSize: 13, color: AppColors.textSecondary)),
                  ),

                  // Send button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _selectedFiles.isEmpty ? null : _submit,
                      icon: const Icon(Icons.send_rounded, size: 20),
                      label: Text('পাঠাও', style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  const _TypeTab({required this.label, required this.icon, required this.isActive, required this.onTap});

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
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: isActive ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w600, color: isActive ? Colors.white : AppColors.textSecondary)),
          ]),
        ),
      ),
    );
  }
}
