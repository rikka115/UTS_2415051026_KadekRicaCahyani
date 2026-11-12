import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quest_model.dart';
import '../providers/quest_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_badge.dart';
import 'edit_quest_view.dart';

class QuestDetailView extends StatelessWidget {
  final QuestModel quest;

  const QuestDetailView({super.key, required this.quest});

  // Helper format tanggal murni Dart
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Tidak ditentukan';
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year pukul $hour:$minute';
  }

  // Dialog konfirmasi penghapusan sesuai rubrik
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.redAccent),
        title: Text(
          'Hapus & Batalkan Quest?',
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${quest.title}"? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            icon: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 18),
            label: const Text('Hapus', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.pop(dialogCtx);

              if (quest.id == null) return;

              final success = await context.read<QuestProvider>().removeQuest(quest.id!);
              
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quest berhasil dihapus!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: ${context.read<QuestProvider>().errorMessage}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E1E24);
    final textSecondary = isDark ? Colors.grey.shade400 : const Color(0xFF616161);

    final currentQuest = context.watch<QuestProvider>().quests.firstWhere(
          (q) => q.id == quest.id,
          orElse: () => quest,
        );

    final createdDateStr = _formatDateTime(currentQuest.createdAt);
    final deadlineStr = _formatDateTime(currentQuest.deadline);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_stories_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              'RINCIAN QUEST',
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1.0,
                color: textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            tooltip: 'Edit Quest',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditQuestView(quest: currentQuest),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
            tooltip: 'Hapus Quest',
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge(
                        isCompleted: currentQuest.isCompleted,
                        expReward: currentQuest.expReward,
                      ),
                      Text(
                        'ID: ${currentQuest.id != null && currentQuest.id!.length >= 8 ? currentQuest.id!.substring(0, 8) : 'N/A'}...',
                        style: TextStyle(fontSize: 12.0, color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // JUDUL QUEST DENGAN FONT RPG CINZEL ULTRA-BOLD
                  Text(
                    currentQuest.title,
                    style: GoogleFonts.cinzel(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 14.0),

                  // WAKTU DIBUAT
                  Row(
                    children: [
                      Icon(Icons.history_rounded, size: 16, color: textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Dibuat: $createdDateStr',
                        style: TextStyle(fontSize: 12.0, color: textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6.0),

                  // TENGGAT WAKTU (DEADLINE)
                  Row(
                    children: [
                      Icon(
                        Icons.alarm_rounded,
                        size: 16,
                        color: isDark ? Colors.amber : Colors.amber.shade900,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tenggat Waktu: $deadlineStr',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: currentQuest.deadline != null
                              ? (isDark ? Colors.amber.shade300 : Colors.amber.shade900)
                              : textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 26.0),

                  // SECTION HEADER OBJEKTIF
                  Row(
                    children: [
                      const Icon(Icons.crisis_alert_rounded, size: 18, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        'Objektif & Rincian Tugas',
                        style: GoogleFonts.cinzel(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8.0),

                  Text(
                    currentQuest.description.isEmpty
                        ? 'Tidak ada rincian objektif khusus.'
                        : currentQuest.description,
                    style: TextStyle(
                      fontSize: 15.0,
                      height: 1.5,
                      color: isDark ? Colors.white70 : const Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),

            // TOMBOL SELESAIKAN QUEST DENGAN FONT CINZEL BOLD
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                backgroundColor: currentQuest.isCompleted ? Colors.orange.shade800 : Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              icon: Icon(
                currentQuest.isCompleted ? Icons.restore_rounded : Icons.verified_rounded,
              ),
              label: Text(
                currentQuest.isCompleted
                    ? 'Tandai Belum Selesai'
                    : 'Klaim Selesai (+${currentQuest.expReward} EXP)',
                style: GoogleFonts.cinzel(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              onPressed: () async {
                final success = await context
                    .read<QuestProvider>()
                    .toggleQuestCompletion(currentQuest);

                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          !currentQuest.isCompleted
                              ? 'Quest selesai! +${currentQuest.expReward} EXP berhasil diklaim!'
                              : 'Status quest diubah kembali menjadi In Progress.',
                        ),
                        backgroundColor: !currentQuest.isCompleted ? Colors.green : Colors.orange,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal memperbarui status: ${context.read<QuestProvider>().errorMessage}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 12.0),

            // TOMBOL HAPUS QUEST
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
              ),
              icon: const Icon(Icons.delete_forever_rounded),
              label: Text(
                'Hapus & Batalkan Quest',
                style: GoogleFonts.cinzel(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }
}