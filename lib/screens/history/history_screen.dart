import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/app_services.dart';

import '../session/session_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ss = context.watch<SessionService>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text('সেশন ইতিহাস', style: GoogleFonts.hindSiliguri(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ),
            Expanded(
              child: ss.sessions.isEmpty
                  ? Center(child: Text('কোনো সেশন নেই', style: GoogleFonts.hindSiliguri(color: AppColors.textHint)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: ss.sessions.length,
                      itemBuilder: (context, i) {
                        final s = ss.sessions[i];
                        return Dismissible(
                          key: Key(s.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => showDialog<bool>(context: context, builder: (c) => AlertDialog(
                            title: Text('ডিলিট?', style: GoogleFonts.hindSiliguri()),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('না')),
                              TextButton(onPressed: () => Navigator.pop(c, true), child: Text('হ্যাঁ', style: TextStyle(color: AppColors.error))),
                            ],
                          )),
                          onDismissed: (_) => ss.deleteSession(s.id),
                          background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), margin: const EdgeInsets.symmetric(vertical: 6), decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.delete_outline, color: Colors.white)),
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SessionDetailScreen(sessionId: s.id))),
                            onLongPress: () {
                              final c = TextEditingController(text: s.title);
                              showDialog(context: context, builder: (ctx) => AlertDialog(
                                title: Text('রিনেম', style: GoogleFonts.hindSiliguri()),
                                content: TextField(controller: c, autofocus: true),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
                                  TextButton(onPressed: () { ss.renameSession(s.id, c.text.trim()); Navigator.pop(ctx); }, child: const Text('সেভ')),
                                ],
                              ));
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border, width: 0.5)),
                              child: Row(children: [
                                Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.description_outlined, color: AppColors.secondary, size: 22)),
                                const SizedBox(width: 14),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text('${s.detectedSubject ?? ''} • ${DateFormat('dd MMM').format(s.createdAt)}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textHint)),
                                ])),
                                const Icon(Icons.chevron_right, color: AppColors.textHint),
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
