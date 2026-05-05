import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';    // ← AJOUTER
import 'services/notification_service.dart';

final ValueNotifier<bool> darkModeNotifier = ValueNotifier(true);
final ValueNotifier<double> fontSizeNotifier = ValueNotifier(22);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  darkModeNotifier.value = prefs.getBool('dark_mode') ?? true;
  fontSizeNotifier.value = prefs.getDouble('font_size') ?? 22;
  await NotificationService.initialize();
  runApp(const NebuleuseApp());
}

class NebuleuseApp extends StatelessWidget {
  const NebuleuseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Nébuleuse',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(isDark),
          home: const SplashScreen(), // ← MODIFIÉ
        );
      },
    );
  }

  ThemeData _buildTheme(bool isDark) {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF5F0E8),
      primaryColor: const Color(0xFFD4A843),
      colorScheme: isDark
          ? const ColorScheme.dark(
        primary: Color(0xFFD4A843),
        secondary: Color(0xFFC8A97E),
        surface: Color(0xFF1A1A1A),
      )
          : const ColorScheme.light(
        primary: Color(0xFFD4A843),
        secondary: Color(0xFFC8A97E),
        surface: Color(0xFFF0EBE0),
      ),
      textTheme: GoogleFonts.cormorantGaramondTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
    );
  }
}