import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'navbar.dart';
import 'sidebar.dart';

class MainLayout extends StatefulWidget {
  final User user;
  final String pageName;
  final Widget child;
  final Color primaryColor;

  const MainLayout({
    super.key,
    required this.user,
    required this.pageName,
    required this.child,
    this.primaryColor = Colors.green,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool isSidebarOpen = true; // pour desktop/tablet

  void _onMenuPressed() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
    });
  }

  void _onItemSelected(String route) {
    if (route == 'logout') {
      // logique logout
    } else {
      // navigation GetX ou Navigator
      print('Navigate to $route');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (isSidebarOpen)
            SizedBox(
              width: 220,
              child: Sidebar(
                primaryColor: widget.primaryColor,
                user: widget.user,
                onItemSelected: _onItemSelected,
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Navbar(
                  primaryColor: widget.primaryColor,
                  user: widget.user,
                  pageName: widget.pageName,
                  onMenuPressed: _onMenuPressed,
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}