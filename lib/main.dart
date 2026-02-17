import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'pages/splash_page.dart';
import 'pages/auth/registre_page.dart';
import 'pages/driver/driver_dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Clean Way',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
     
      getPages: [
        GetPage(
          name: '/',
          page: () => RegisterPage(),
        ),
        GetPage(
          name: '/driver-dashboard',
          page: () => const DriverDashboardPage(),
        ),
      ],
    );
  }
}
