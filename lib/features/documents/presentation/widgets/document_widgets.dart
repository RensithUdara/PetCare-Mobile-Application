import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_routes.dart';
import '../../domain/entities/medical_document.dart';
import '../providers/document_providers.dart';

extension DocumentTypeIcon on DocumentType {
  IconData get icon => switch (this) {
        DocumentType.vaccinationCertificate => Icons.verified_outlined,
        DocumentType.bloodTest => Icons.bloodtype_outlined,
        DocumentType.prescription => Icons.receipt_long_outlined,
        DocumentType.xRay => Icons.monitor_heart_outlined,
        DocumentType.medicalReport => Icons.description_outlined,
        DocumentType.invoice => Icons.request_quote_outlined,
        DocumentType.other => Icons.insert_drive_file_outlined,
      };
}

/// "845 KB", "2.4 MB".
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// Image thumbnail, or a type icon for PDFs.
class DocumentThumbnail extends StatelessWidget {
  const DocumentThumbnail({super.key, required this.document, this.size = 56});

  final MedicalDocument document;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fallback = Container(
      width: size,
      height: size,
      color: scheme.primaryContainer,
      alignment: Alignment.center,
      child: document.isPdf
          ? Text('PDF',
              style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800, fontSize: size / 4))
          : Icon(document.type.icon, color: scheme.primary),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: document.isImage
          ? CachedNetworkImage(
              imageUrl: document.fileUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              memCacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
              placeholder: (_, _) => fallback,
              errorWidget: (_, _, _) => fallback,
            )
          : fallback,
    );
  }
}

class DocumentCard extends StatelessWidget {
  const DocumentCard({super.key, required this.document, this.onTap});

  final MedicalDocument document;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              DocumentThumbnail(document: document),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${document.type.label} · ${DateFormat.yMMMd().format(document.date)}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    Text(
                      '${document.isPdf ? 'PDF' : 'Image'} · ${formatBytes(document.sizeBytes)}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Summary row on the pet profile linking to the documents screen.
class PetDocumentsTile extends ConsumerWidget {
  const PetDocumentsTile({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(petDocumentsProvider(petId)).value;
    final subtitle = switch (docs) {
      null => 'Loading…',
      [] => 'No documents yet',
      [final latest, ...] =>
        '${docs.length} file${docs.length == 1 ? '' : 's'} · Latest: ${latest.name}',
    };
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: const Text('Documents'),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(AppRoutes.documents(petId)),
    );
  }
}

/// Certificates attached to a vaccination, plus an "Attach" action.
class VaccinationCertificatesCard extends ConsumerWidget {
  const VaccinationCertificatesCard({
    super.key,
    required this.petId,
    required this.vaccinationId,
    required this.vaccineName,
  });

  final String petId;
  final String vaccinationId;
  final String vaccineName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(vaccinationDocumentsProvider(vaccinationId)).value ?? const [];
    final theme = Theme.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Certificate', style: theme.textTheme.titleSmall),
          ),
          for (final doc in docs)
            ListTile(
              leading: DocumentThumbnail(document: doc, size: 40),
              title: Text(doc.name),
              subtitle: Text(DateFormat.yMMMd().format(doc.date)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.documentViewer(doc.id)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.push(AppRoutes.documentNew(
                  petId: petId,
                  vaccinationId: vaccinationId,
                  type: DocumentType.vaccinationCertificate.name,
                  name: '$vaccineName certificate',
                )),
                icon: const Icon(Icons.attach_file),
                label: Text(docs.isEmpty ? 'Attach certificate' : 'Attach another'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
