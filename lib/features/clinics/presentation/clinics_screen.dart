import 'package:flutter/material.dart';

import '../../../core/widgets/state_views.dart';

class ClinicsScreen extends StatelessWidget {
  const ClinicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinics')),
      body: const EmptyState(
        icon: Icons.local_hospital,
        title: 'No saved clinics',
        message: 'Save your favorite veterinary clinics for quick access.',
      ),
    );
  }
}
