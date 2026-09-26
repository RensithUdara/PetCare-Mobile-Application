import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../domain/entities/medical_document.dart';
import '../controllers/document_editor_controller.dart';
import '../providers/document_providers.dart';
import '../widgets/document_widgets.dart';

/// Full-screen view of a document: zoomable image, or a PDF summary that
/// opens in the device's PDF viewer.
class DocumentViewerScreen extends ConsumerWidget {
  const DocumentViewerScreen({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(documentProvider(documentId)).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) => Scaffold(
            appBar: AppBar(),
            body: const ErrorView(message: 'Could not load this document.'),
          ),
          data: (d) => d == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: const EmptyState(
                    icon: Icons.search_off,
                    title: 'Document not found',
                    message: 'It may have been deleted.',
                  ),
                )
              : _Viewer(document: d),
        );
  }
}

class _Viewer extends ConsumerWidget {
  const _Viewer({required this.document});

  final MedicalDocument document;

  Future<void> _openExternally(BuildContext context) async {
    final ok = await launchUrl(Uri.parse(document.fileUrl), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No app available to open this file.')),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Delete document?'),
          content: Text('“${document.name}” and its file will be permanently deleted.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (await ref.read(documentEditorControllerProvider.notifier).delete(document)) {
      router.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Document deleted')));
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(ref.read(documentEditorControllerProvider).error?.message ??
            'Could not delete document.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final petName = ref.watch(petProvider(document.petId)).value?.name;
    final busy = ref.watch(documentEditorControllerProvider).isBusy;

    return Scaffold(
      appBar: AppBar(
        title: Text(document.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Open in another app',
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _openExternally(context),
          ),
          PopupMenuButton<String>(
            enabled: !busy,
            onSelected: (v) => v == 'edit'
                ? context.push(AppRoutes.documentEdit(document.id))
                : _delete(context, ref),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit details')),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (busy) const LinearProgressIndicator(),
          Expanded(
            child: document.isImage
                ? InteractiveViewer(
                    maxScale: 5,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: document.fileUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, _) => const LoadingView(),
                        errorWidget: (_, _, _) => const EmptyState(
                          icon: Icons.broken_image_outlined,
                          title: 'Could not load image',
                        ),
                      ),
                    ),
                  )
                : _PdfBody(document: document, onOpenExternally: () => _openExternally(context)),
          ),
          Material(
            color: theme.colorScheme.surfaceContainer,
            child: SafeArea(
              top: false,
              child: ListTile(
                leading: Icon(document.type.icon),
                title: Text([document.type.label, ?petName].join(' · ')),
                subtitle: Text([
                  DateFormat.yMMMd().format(document.date),
                  ?document.description,
                ].join('\n')),
                isThreeLine: document.description != null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Downloads (or reads from cache) and renders a PDF in-app, with a
/// fallback to an external viewer.
class _PdfBody extends ConsumerWidget {
  const _PdfBody({required this.document, required this.onOpenExternally});

  final MedicalDocument document;
  final VoidCallback onOpenExternally;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(documentBytesProvider(document)).when(
          loading: () => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Loading PDF · ${formatBytes(document.sizeBytes)}'),
              ],
            ),
          ),
          error: (error, _) => EmptyState(
            icon: Icons.picture_as_pdf_outlined,
            title: 'Couldn’t open this PDF',
            message: error is Failure ? error.message : 'Please try again.',
            action: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: () => ref.invalidate(documentBytesProvider(document)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: onOpenExternally,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open in another app'),
                ),
              ],
            ),
          ),
          data: (bytes) => ref.watch(pdfViewBuilderProvider)(bytes),
        );
  }
}
