import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildTheme({required int seedColor, required Brightness brightness}) {
    final seed = Color(seedColor);
    final base = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    final scheme = brightness == Brightness.dark
        ? base.copyWith(
            surface: const Color(0xFF1B2333),
            onSurface: const Color(0xFFE6EDF7),
            primary: const Color(0xFF5ED3C6),
            onPrimary: const Color(0xFF0C1B22),
            secondary: const Color(0xFF8FA8FF),
            onSecondary: const Color(0xFF101B3E),
            error: const Color(0xFFFF7D7D),
            onError: const Color(0xFF2D1111),
          )
        : base.copyWith(
            surface: const Color(0xFFFFFFFF),
            onSurface: const Color(0xFF1A2433),
            primary: const Color(0xFF00A896),
            onPrimary: Colors.white,
            secondary: const Color(0xFF3D7EFF),
            onSecondary: Colors.white,
            error: const Color(0xFFE5484D),
            onError: Colors.white,
          );

    final scaffoldBg =
        brightness == Brightness.dark ? const Color(0xFF131A26) : const Color(0xFFF3F7FC);
    final cardBg =
        brightness == Brightness.dark ? const Color(0xFF202A3D) : const Color(0xFFFFFFFF);
    final inputBg =
        brightness == Brightness.dark ? const Color(0xFF243049) : const Color(0xFFF8FBFF);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      appBarTheme: AppBarTheme(
        backgroundColor: cardBg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: brightness == Brightness.dark ? 0.28 : 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: scheme.primary.withValues(alpha: brightness == Brightness.dark ? 0.20 : 0.10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBg,
        hintStyle: TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.62),
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: scheme.onSurface.withValues(alpha: 0.72),
        suffixIconColor: scheme.onSurface.withValues(alpha: 0.72),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: scheme.primary.withValues(alpha: 0.12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: scheme.primary.withValues(alpha: 0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: scheme.primary,
            width: 1.6,
          ),
        ),
      ),
      dividerColor: scheme.onSurface.withValues(alpha: 0.12),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final darkMode = box.read('settings:darkMode') ?? false;
    final accentColor = box.read('settings:accentColor') ?? 0xFF00A896;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clean Way',
      theme: _buildTheme(seedColor: accentColor, brightness: Brightness.light),
      darkTheme: _buildTheme(seedColor: accentColor, brightness: Brightness.dark),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.home,
      getPages: AppPages.routes,
    );
  }
}
