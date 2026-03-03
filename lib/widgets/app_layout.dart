import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';
import 'navbar.dart';
import 'sidebar.dart';

class AppLayout extends StatefulWidget {
  final Widget child;
  final String pageName;
  final FloatingActionButton? floatingActionButton;

  const AppLayout({
    super.key,
    required this.child,
    required this.pageName,
    this.floatingActionButton,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool isSidebarOpen = false;

  void toggleSidebar() {
    setState(() => isSidebarOpen = !isSidebarOpen);
  }

  void handleNavigation(String route) {
  if (route == 'logout') {
    GetStorage().erase();
    Get.offAllNamed(AppRoutes.login);
    return;
  }
  
  if (route == AppRoutes.login) {
    GetStorage().erase();
    Get.offAllNamed(AppRoutes.login);
    return;
  }

  toggleSidebar();
  Get.toNamed(route);
}

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFDC2626);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 800;

    return Scaffold(
      floatingActionButton: widget.floatingActionButton,

      drawer: !isDesktop
          ? Drawer(
              child: Sidebar(
                primaryColor: primaryColor,
                onItemSelected: (route) {
                  Navigator.of(context).pop();
                  handleNavigation(route);
                },
              ),
            )
          : null,

      body: SafeArea(
        child: Stack(
          children: [

            /// 🔹 Main Content
            Column(
              children: [
                Navbar(
                  primaryColor: primaryColor,
                  pageName: widget.pageName,
                  onMenuPressed: toggleSidebar,
                ),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),

            /// 🔹 Backdrop (click outside to close)
            if (isSidebarOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: toggleSidebar,
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
              ),

            /// 🔹 Sidebar overlay
            if (isSidebarOpen)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 250,
                  child: Sidebar(
                    primaryColor: primaryColor,
                    onItemSelected: handleNavigation,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}