import 'package:flutter/material.dart';
import '../../../widgets/app_layout.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      pageName: 'Help & Support',
      child: const Center(
        child: Text('Page d\'aide et support en construction'),
      ),
    );
  }
}
