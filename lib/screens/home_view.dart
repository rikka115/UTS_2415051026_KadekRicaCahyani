import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/quest_provider.dart';
import '../providers/quote_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_card.dart';
import 'quest_list_view.dart';
import 'profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestProvider>().loadQuests();
      context.read<QuoteProvider>().fetchDailyQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _HomeDashboardBody(),
      const QuestListView(),
      const ProfileView(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.castle_outlined),
            selectedIcon: Icon(Icons.castle_rounded),
            label: 'Hero Hub',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_turned_in_rounded),
            label: 'Quest Board',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeDashboardBody extends StatelessWidget {
  const _HomeDashboardBody();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final questProvider = context.watch<QuestProvider>();
    final quoteProvider = context.watch<QuoteProvider>();
    final isDark = themeProvider.isDarkMode;

    final level = questProvider.currentLevel;
    final expProgress = questProvider.currentLevelExpProgress;
    final totalExp = questProvider.totalExp;
    final completedCount = questProvider.quests.where((q) => q.isCompleted).length;
    final totalCount = questProvider.quests.length;

    // Warna teks adaptif
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E1E24);
    final textSecondary = isDark ? Colors.grey.shade400 : const Color(0xFF616161);
    final statBoxColor = isDark ? Colors.white.withAlpha(15) : const Color(0xFFEDEEF3);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shield_moon_rounded, color: Colors.amber),
            const SizedBox(width: 8),
            Text(
              'QuestLog TaskMate',
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
          IconButton(
            tooltip: 'Dark / Light Mode Toggle',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.amber,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<QuestProvider>().loadQuests(),
            context.read<QuoteProvider>().fetchDailyQuote(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomCard(
                borderColor: Colors.amber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.amber.shade700,
                          child: const Icon(Icons.military_tech_rounded, size: 42, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Level $level Hero',
                                style: GoogleFonts.cinzel(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withAlpha(isDark ? 40 : 50),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber.shade700, width: 0.8),
                                ),
                                child: Text(
                                  questProvider.rankTitle,
                                  style: TextStyle(
                                    color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              'Progress EXP ($expProgress / 100)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.stars_rounded, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              'Total: $totalExp EXP',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: expProgress / 100.0,
                        minHeight: 12,
                        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              color: statBoxColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded, size: 14, color: isDark ? Colors.greenAccent : Colors.green.shade700),
                                    const SizedBox(width: 4),
                                    Text('Selesai', style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$completedCount',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.greenAccent : Colors.green.shade800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              color: statBoxColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.hourglass_top_rounded, size: 14, color: isDark ? Colors.orangeAccent : Colors.orange.shade800),
                                    const SizedBox(width: 4),
                                    Text('Aktif', style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${totalCount - completedCount}',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.orangeAccent : Colors.orange.shade800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              color: statBoxColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.format_list_bulleted_rounded, size: 14, color: textSecondary),
                                    const SizedBox(width: 4),
                                    Text('Total Quest', style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$totalCount',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION HEADER DENGAN FONT KHUSUS CINZEL BOLD
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 20, color: Colors.deepPurpleAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Petuah Bijak Petualang',
                    style: GoogleFonts.cinzel(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Builder(
                builder: (context) {
                  if (quoteProvider.state == QuoteState.loading) {
                    return const CustomCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('Mengambil petuah bijak dari kuil kuno...'),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  if (quoteProvider.state == QuoteState.error) {
                    return CustomCard(
                      borderColor: Colors.redAccent,
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Gagal terhubung ke REST API: ${quoteProvider.errorMessage}',
                              style: TextStyle(fontSize: 13, color: textPrimary),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded),
                            onPressed: () => context.read<QuoteProvider>().fetchDailyQuote(),
                          )
                        ],
                      ),
                    );
                  }

                  final quoteTextColor = isDark ? Colors.white : const Color(0xFF2C1052);
                  final quoteSubColor = isDark ? Colors.grey.shade400 : const Color(0xFF5E35B1);

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF2A1B4E), const Color(0xFF1E1435)]
                            : [const Color(0xFFF0EBF9), const Color(0xFFDED2F3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: isDark ? Colors.deepPurpleAccent.withAlpha(120) : Colors.deepPurple.shade300,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withAlpha(isDark ? 40 : 25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.deepPurpleAccent,
                              child: const Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Grandmaster Sage',
                                    style: GoogleFonts.cinzel(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: quoteTextColor,
                                    ),
                                  ),
                                  Text(
                                    'Advice Slip API • ID #${quoteProvider.quote?.id ?? '00'}',
                                    style: TextStyle(fontSize: 11, color: quoteSubColor, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.refresh_rounded, size: 22, color: quoteTextColor),
                              tooltip: 'Ambil Petuah Baru',
                              onPressed: () => context.read<QuoteProvider>().fetchDailyQuote(),
                            ),
                          ],
                        ),
                        Divider(height: 20, color: isDark ? Colors.white24 : Colors.deepPurple.shade200),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.format_quote_rounded, size: 32, color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '"${quoteProvider.quote?.advice ?? 'Tetaplah fokus dan selesaikan setiap misi tepat waktu!'}"',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 15,
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                  color: quoteTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}