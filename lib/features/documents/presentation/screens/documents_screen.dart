import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../domain/entities/medical_document.dart';
import '../providers/document_providers.dart';
import '../widgets/document_widgets.dart';

/// A pet's documents with a type filter.
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  DocumentType? _filter;

  @override
  Widget build(BuildContext context) {
    final petName = ref.watch(petProvider(widget.petId)).value?.name;
    final docs = ref.watch(petDocumentsProvider(widget.petId));
    void add() => context.push(AppRoutes.documentNew(petId: widget.petId));

    return Scaffold(
      appBar: BrandAppBar.page(title: petName == null ? 'Documents' : '$petName’s Documents'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: add,
        icon: const Icon(Icons.upload_file),
        label: const Text('Add Document'),
      ),
      body: docs.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          message: 'Could not load documents.',
          onRetry: () => ref.invalidate(petDocumentsProvider(widget.petId)),
        ),
        data: (docs) {
          if (docs.isEmpty) {
            return const EmptyState(
              icon: Icons.folder_open_outlined,
              title: 'No documents yet',
              message: 'Keep certificates, test results, prescriptions and X-rays in one place.',
            );
          }
          // Only offer filters for types that exist.
          final types = [
            for (final t in DocumentType.values)
              if (docs.any((d) => d.type == t)) t,
          ];
          final filter = types.contains(_filter) ? _filter : null;
          final visible = filter == null ? docs : docs.where((d) => d.type == filter).toList();

          return Column(
            children: [
              if (types.length > 1)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      for (final t in <DocumentType?>[null, ...types])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(t?.label ?? 'All (${docs.length})'),
                            selected: filter == t,
                            onSelected: (_) => setState(() => _filter = t),
                          ),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => DocumentCard(
                    key: ValueKey(visible[i].id),
                    document: visible[i],
                    onTap: () => context.push(AppRoutes.documentViewer(visible[i].id)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
