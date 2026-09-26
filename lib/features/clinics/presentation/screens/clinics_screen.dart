import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/clinic.dart';
import '../providers/clinic_providers.dart';
import '../widgets/clinic_widgets.dart';

/// Saved clinics and veterinarians, with search.
class ClinicsScreen extends ConsumerStatefulWidget {
  const ClinicsScreen({super.key});

  @override
  ConsumerState<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends ConsumerState<ClinicsScreen> with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 2, vsync: this)..addListener(() => setState(() {}));
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  bool _matches(List<String?> fields) =>
      _query.isEmpty || fields.any((f) => f != null && f.toLowerCase().contains(_query));

  @override
  Widget build(BuildContext context) {
    final clinics = ref.watch(clinicsProvider);
    final vets = ref.watch(vetsProvider);
    final clinicNames = {for (final c in clinics.value ?? const <Clinic>[]) c.id: c.name};
    final onVetsTab = _tabs.index == 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinics'),
        actions: [
          IconButton(
            tooltip: 'Map & nearby clinics',
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.push(AppRoutes.clinicsMap),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search clinics and vets',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              _search.clear();
                              _query = '';
                            }),
                          ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabs,
                tabs: [
                  Tab(text: 'Clinics (${clinics.value?.length ?? 0})'),
                  Tab(text: 'Veterinarians (${vets.value?.length ?? 0})'),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(onVetsTab ? AppRoutes.vetNew() : AppRoutes.clinicNew),
        icon: const Icon(Icons.add),
        label: Text(onVetsTab ? 'Add Vet' : 'Add Clinic'),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          clinics.when(
            loading: () => const LoadingView(),
            error: (_, _) => ErrorView(
              message: 'Could not load clinics.',
              onRetry: () => ref.invalidate(clinicsProvider),
            ),
            data: (all) {
              if (all.isEmpty) {
                return EmptyState(
                  icon: Icons.local_hospital_outlined,
                  title: 'No saved clinics',
                  message: 'Add your vet clinic, or find clinics near you on the map.',
                  action: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                    onPressed: () => context.push(AppRoutes.clinicsMap),
                    icon: const Icon(Icons.near_me_outlined),
                    label: const Text('Find nearby clinics'),
                  ),
                );
              }
              final visible = all.where((c) => _matches([c.name, c.address, c.phone])).toList();
              if (visible.isEmpty) return EmptyState(icon: Icons.search_off, title: 'No clinics match “$_query”');
              final vetCounts = <String, int>{};
              for (final v in vets.value ?? const <Veterinarian>[]) {
                if (v.clinicId != null) vetCounts[v.clinicId!] = (vetCounts[v.clinicId!] ?? 0) + 1;
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                itemCount: visible.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => ClinicCard(
                  key: ValueKey(visible[i].id),
                  clinic: visible[i],
                  vetCount: vetCounts[visible[i].id] ?? 0,
                  onTap: () => context.push(AppRoutes.clinicDetails(visible[i].id)),
                ),
              );
            },
          ),
          vets.when(
            loading: () => const LoadingView(),
            error: (_, _) => ErrorView(
              message: 'Could not load veterinarians.',
              onRetry: () => ref.invalidate(vetsProvider),
            ),
            data: (all) {
              if (all.isEmpty) {
                return const EmptyState(
                  icon: Icons.medical_information_outlined,
                  title: 'No veterinarians yet',
                  message: 'Save your vets’ details for quick calls and appointments.',
                );
              }
              final visible = all
                  .where((v) => _matches([v.name, v.specialization, clinicNames[v.clinicId]]))
                  .toList();
              if (visible.isEmpty) return EmptyState(icon: Icons.search_off, title: 'No vets match “$_query”');
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
                itemCount: visible.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) => VetTile(
                  key: ValueKey(visible[i].id),
                  vet: visible[i],
                  clinicName: clinicNames[visible[i].clinicId],
                  onTap: () => context.push(AppRoutes.vetEdit(visible[i].id)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
