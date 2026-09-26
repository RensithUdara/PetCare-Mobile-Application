import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/clock.dart';
import '../../../appointments/presentation/providers/appointment_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../medications/presentation/providers/medication_providers.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../../vaccinations/presentation/providers/vaccination_providers.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/usecases/watch_dashboard.dart';

final watchDashboardProvider = Provider(
  (ref) => WatchDashboard(
    ref.watch(petRepositoryProvider),
    ref.watch(appointmentRepositoryProvider),
    ref.watch(vaccinationRepositoryProvider),
    ref.watch(medicationRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final dashboardProvider = StreamProvider<Dashboard>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(Dashboard.empty);
  return ref.watch(watchDashboardProvider)(uid);
});
