import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TrackitApp(),
    ),
  );
}

class TrackitApp extends StatelessWidget {
  const TrackitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trackit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5), // Very light grey background
        primaryColor: const Color(0xFF9C27B0), // Purple FAB / accents
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C27B0),
          surface: const Color(0xFFF0F2F5),
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
