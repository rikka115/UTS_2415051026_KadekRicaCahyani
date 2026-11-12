import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quest_model.dart';
import '../providers/quest_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_badge.dart';
import 'quest_detail_view.dart';
import 'add_quest_view.dart';

class QuestListView extends StatefulWidget {
  const QuestListView({super.key});

  @override
  State<QuestListView> createState() => _QuestListViewState();
}

class _QuestListViewState extends State<QuestListView> {
  String _selectedFilter = 'Semua';
  int _selectedDayOffset = 0;

  // Lencana Urgensi Deadline
  Widget _buildDeadlineBadge(DateTime? deadline) {
    if (deadline == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final difference = deadline.difference(now);

    Color badgeColor = Colors.blueGrey;
    IconData icon = Icons.event_rounded;
    String text = '${deadline.day}/${deadline.month}';

    if (difference.isNegative) {
      badgeColor = Colors.red.shade900;
      icon = Icons.error_outline_rounded;
      text = 'Terlewat';
    } else if (difference.inHours <= 24) {
      badgeColor = Colors.redAccent.shade700;
      icon = Icons.alarm_rounded;
      text = 'Hari ini!';
    } else if (difference.inDays <= 3) {
      badgeColor = Colors.orange.shade800;
      icon = Icons.hourglass_top_rounded;
      text = '${difference.inDays} hari lagi';
    } else {
      icon = Icons.schedule_rounded;
      text = '${deadline.day}/${deadline.month}';
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Widget Kalender Mingguan
  Widget _buildInteractiveCalendarStrip(bool isDark) {
    final now = DateTime.now();
    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final calBg = isDark ? Colors.amber.withAlpha(20) : Colors.amber.shade50;
    final calBorder = isDark ? Colors.amber.withAlpha(60) : Colors.amber.shade200;
    final headerColor = isDark ? Colors.amber.shade300 : Colors.amber.shade900;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: calBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: calBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 16, color: headerColor),
              const SizedBox(width: 6),
              Text(
                'Kalender Agenda Minggu Ini',
                style: GoogleFonts.cinzel(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: headerColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayDate = now.add(Duration(days: index - now.weekday + 1));
              final isToday = dayDate.day == now.day && dayDate.month == now.month;
              final isSelected = _selectedDayOffset == index;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDayOffset = index;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.amber.shade700
                        : (isSelected
                            ? (isDark ? Colors.white12 : Colors.amber.shade100)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                    border: isToday
                        ? Border.all(color: Colors.amberAccent, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayNames[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? Colors.white
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${dayDate.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
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

    return Scaffold(
      appBar: AppBar(
        // TANPA CONST AGAR BEBAS ERROR DENGAN GOOGLEFONTS
        title: Row(
          children: [
            const Icon(Icons.assignment_turned_in_rounded, color: Colors.amber),
            const SizedBox(width: 8),
            Text(
              'QUEST BOARD',
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.w900,
                fontSize: 19,
                letterSpacing: 1.1,
                color: textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<SortCriteria>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Urutkan Misi',
            onSelected: (criteria) {
              context.read<QuestProvider>().setSortCriteria(criteria);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortCriteria.deadline,
                child: Row(
                  children: [
                    Icon(Icons.hourglass_bottom_rounded, size: 20, color: Colors.amber),
                    SizedBox(width: 10),
                    Text('Deadline Terdekat (Prioritas)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortCriteria.exp,
                child: Row(
                  children: [
                    Icon(Icons.military_tech_rounded, size: 20, color: Colors.deepPurpleAccent),
                    SizedBox(width: 10),
                    Text('Reward EXP Terbesar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortCriteria.newest,
                child: Row(
                  children: [
                    Icon(Icons.fiber_new_rounded, size: 20, color: Colors.lightBlueAccent),
                    SizedBox(width: 10),
                    Text('Paling Baru Ditambahkan'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload Quests',
            onPressed: () => context.read<QuestProvider>().loadQuests(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_task_rounded),
        label: Text(
          'Post Quest',
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddQuestView()),
          );
        },
      ),
      body: Consumer<QuestProvider>(
        builder: (context, questProv, child) {
          if (questProv.state == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (questProv.state == ViewState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 50, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat: ${questProv.errorMessage}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textPrimary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => questProv.loadQuests(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (questProv.quests.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield_outlined, size: 72, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Papan Quest Masih Kosong!',
                      style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w900, color: textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada misi petualangan. Mulai buat tugas baru atau isi data demo instan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, foregroundColor: Colors.white),
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('Isi 4 Quest Demo Otomatis'),
                      onPressed: () async {
                        await questProv.seedDummyQuests();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('4 Quest RPG dengan deadline berhasil ditambahkan!'), backgroundColor: Colors.green),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          final sortedQuests = questProv.getSortedQuests(_selectedFilter);

          return Column(
            children: [
              _buildInteractiveCalendarStrip(isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', questProv.quests.length, Icons.all_inbox_rounded, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('Aktif', questProv.quests.where((q) => !q.isCompleted).length, Icons.pending_actions_rounded, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('Selesai', questProv.quests.where((q) => q.isCompleted).length, Icons.task_alt_rounded, isDark),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: sortedQuests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.filter_list_off_rounded, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text('Tidak ada quest berstatus "$_selectedFilter"', style: TextStyle(color: textSecondary)),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 600;

                          if (isWide) {
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.1,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: sortedQuests.length,
                              itemBuilder: (context, index) => _buildQuestCard(context, sortedQuests[index], textPrimary, textSecondary),
                            );
                          } else {
                            return ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: sortedQuests.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) => _buildQuestCard(context, sortedQuests[index], textPrimary, textSecondary),
                            );
                          }
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, IconData icon, bool isDark) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.black87 : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
      ),
      label: Text(
        '$label ($count)',
        style: TextStyle(
          color: isSelected ? Colors.black87 : (isDark ? Colors.white : Colors.black87),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedColor: Colors.amber,
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = label);
      },
    );
  }

  Widget _buildQuestCard(BuildContext context, QuestModel quest, Color textPrimary, Color textSecondary) {
    return CustomCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => QuestDetailView(quest: quest)),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(
              quest.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: quest.isCompleted ? Colors.green : Colors.grey.shade500,
              size: 28,
            ),
            onPressed: () async {
              final success = await context.read<QuestProvider>().toggleQuestCompletion(quest);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text(
                      !quest.isCompleted ? 'Quest Selesai! +${quest.expReward} EXP claimed!' : 'Quest dibuka kembali.',
                    ),
                    backgroundColor: !quest.isCompleted ? Colors.green : Colors.orange,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        quest.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: quest.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                          color: quest.isCompleted ? Colors.grey : textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusBadge(isCompleted: quest.isCompleted, expReward: quest.expReward),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  quest.description.isEmpty ? 'Tidak ada rincian objektif.' : quest.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
                _buildDeadlineBadge(quest.deadline),
              ],
            ),
          ),
        ],
      ),
    );
  }
}