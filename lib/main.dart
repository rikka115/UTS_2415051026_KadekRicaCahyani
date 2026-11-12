import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/quest_provider.dart';
import 'providers/quote_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vvqyhcousgmjrnaihmth.supabase.co',
    anonKey: 'sb_publishable_ZR5kdlkLQyGyXA9iFOsDDQ_h-b7RDmY',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestProvider()),
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const QuestLogApp(),
    ),
  );
}

class QuestLogApp extends StatelessWidget {
  const QuestLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'QuestLog TaskMate',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      
      // TEMA TERANG (LIGHT MODE) - KONTRAS TINGGI & TIDAK PUDAR
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.amber,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E1E24),
          elevation: 0.5,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.light().textTheme,
        ),
      ),

      // TEMA GELAP (DARK MODE) - RPG STYLISH
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.amber,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121216),
        cardTheme: const CardThemeData(
          color: Color(0xFF1C1C24),
          elevation: 2,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1C24),
          foregroundColor: Colors.white,
          elevation: 0.5,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const HomeView(),
    );
  }
}