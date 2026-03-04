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
    final scheme = ColorScheme.fromSeed(seedColor: Color(seedColor), brightness: brightness);
    return ThemeData.from(colorScheme: scheme).copyWith(useMaterial3: true);
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final darkMode = box.read('settings:darkMode') ?? false;
    final accentColor = box.read('settings:accentColor') ?? 0xFF6B21A8;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clean Way',
      theme: _buildTheme(seedColor: accentColor, brightness: Brightness.light),
      darkTheme: _buildTheme(seedColor: accentColor, brightness: Brightness.dark),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.login,
      getPages: AppPages.routes,
    );
  }
}
