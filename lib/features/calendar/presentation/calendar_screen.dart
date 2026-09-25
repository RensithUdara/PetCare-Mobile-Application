import 'package:flutter/material.dart';

import '../../../core/widgets/state_views.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: const EmptyState(
        icon: Icons.calendar_month,
        title: 'Nothing scheduled',
        message: 'Vaccinations, appointments and medications will show up here.',
      ),
    );
  }
}
