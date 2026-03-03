import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/app_layout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // user info can be read from storage if needed
    return AppLayout(
      pageName: 'Paramètres',
      child: const Center(
        child: Text('Page des paramètres en construction'),
      ),
    );
  }
}
