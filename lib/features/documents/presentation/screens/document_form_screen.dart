import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/clock.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/medical_document.dart';
import '../controllers/document_editor_controller.dart';
import '../providers/document_providers.dart';
import '../services/document_picker.dart';
import '../widgets/document_widgets.dart';

/// Upload a new document for [petId], or edit [documentId]'s details.
class DocumentFormScreen extends ConsumerWidget {
  const DocumentFormScreen({
    super.key,
    this.petId,
    this.documentId,
    this.vaccinationId,
    this.initialType,
    this.initialName,
  }) : assert(petId != null || documentId != null);

  final String? petId;
  final String? documentId;
  final String? vaccinationId;
  final DocumentType? initialType;
  final String? initialName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (documentId == null) {
      return _DocumentForm(
        petId: petId!,
        initial: null,
        vaccinationId: vaccinationId,
        initialType: initialType,
        initialName: initialName,
      );
    }
    return ref.watch(documentProvider(documentId!)).when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (_, _) =>
              const Scaffold(body: ErrorView(message: 'Could not load this document.')),
          data: (d) => d == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: const EmptyState(icon: Icons.search_off, title: 'Document not found'),
                )
              : _DocumentForm(petId: d.petId, initial: d),
        );
  }
}

class _DocumentForm extends ConsumerStatefulWidget {
  const _DocumentForm({
    required this.petId,
    required this.initial,
    this.vaccinationId,
    this.initialType,
    this.initialName,
  });

  final String petId;
  final MedicalDocument? initial;
  final String? vaccinationId;
  final DocumentType? initialType;
  final String? initialName;

  @override
  ConsumerState<_DocumentForm> createState() => _DocumentFormState();
}

class _DocumentFormState extends ConsumerState<_DocumentForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name ?? widget.initialName);
  late final _description = TextEditingController(text: widget.initial?.description);
  late DocumentType _type = widget.initial?.type ?? widget.initialType ?? DocumentType.other;
  late DateTime? _date = widget.initial?.date ?? dateOnly(ref.read(clockProvider)());
  DocumentFile? _file;
  bool _fileMissing = false;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pick(DocumentSource source) async {
    try {
      final file = await ref.read(documentPickerProvider).pick(source);
      if (file == null || !mounted) return;
      setState(() {
        _file = file;
        _fileMissing = false;
        if (_name.text.trim().isEmpty) {
          // Suggest a name from the file ("blood_test.pdf" → "blood test").
          final base = file.fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
          _name.text = base.replaceAll(RegExp(r'[_-]+'), ' ').trim();
        }
      });
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not open the file picker. Check app permissions in Settings.'),
      ));
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState!.validate();
    if (!_isEditing && _file == null) setState(() => _fileMissing = true);
    if (!valid || (!_isEditing && _file == null)) return;

    final controller = ref.read(documentEditorControllerProvider.notifier);
    final ok = _isEditing
        ? await controller.update(
            widget.initial!,
            name: _name.text,
            type: _type,
            date: _date!,
            description: _description.text,
          )
        : await controller.add(
              petId: widget.petId,
              name: _name.text,
              type: _type,
              date: _date!,
              file: _file!,
              description: _description.text,
              vaccinationId: widget.vaccinationId,
            ) !=
            null;
    if (!ok || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Document updated' : 'Document uploaded')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(documentEditorControllerProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!.message)));
      }
    });
    final editor = ref.watch(documentEditorControllerProvider);
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    const gap = SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Document' : 'Add Document')),
      body: AbsorbPointer(
        absorbing: editor.isBusy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (_isEditing)
                Card(
                  child: ListTile(
                    leading: DocumentThumbnail(document: widget.initial!, size: 44),
                    title: Text(widget.initial!.fileName),
                    subtitle: Text(formatBytes(widget.initial!.sizeBytes)),
                  ),
                )
              else
                _FilePickerCard(
                  file: _file,
                  showError: _fileMissing,
                  onPick: _pick,
                ),
              gap,
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.required(v, field: 'Document name'),
                decoration: const InputDecoration(
                  labelText: 'Document name *',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              gap,
              Text('Type', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in DocumentType.values)
                    ChoiceChip(
                      avatar: Icon(t.icon, size: 18),
                      label: Text(t.label),
                      selected: _type == t,
                      onSelected: (_) => setState(() => _type = t),
                    ),
                ],
              ),
              gap,
              DateField(
                label: 'Document date *',
                initialValue: _date,
                firstDate: DateTime(1990),
                lastDate: now,
                clearable: false,
                validator: (d) => d == null ? 'Date is required' : null,
                onChanged: (d) => setState(() => _date = d),
              ),
              gap,
              TextFormField(
                controller: _description,
                minLines: 2,
                maxLines: 5,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              if (editor.uploadProgress != null) ...[
                LinearProgressIndicator(value: editor.uploadProgress),
                const SizedBox(height: 8),
                Text('Uploading ${(editor.uploadProgress! * 100).round()}%',
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: editor.isBusy ? null : _save,
                child: editor.isBusy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(_isEditing ? 'Save Changes' : 'Upload Document'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilePickerCard extends StatelessWidget {
  const _FilePickerCard({required this.file, required this.showError, required this.onPick});

  final DocumentFile? file;
  final bool showError;
  final ValueChanged<DocumentSource> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final f = file;
    return Card(
      shape: showError
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.error),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (f != null) ...[
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: f.contentType.startsWith('image/')
                        ? Image.memory(f.bytes, width: 64, height: 64, fit: BoxFit.cover)
                        : Container(
                            width: 64,
                            height: 64,
                            color: theme.colorScheme.primaryContainer,
                            alignment: Alignment.center,
                            child: Text('PDF',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                )),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(formatBytes(f.sizeBytes), style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ] else ...[
              Icon(Icons.upload_file, size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text('Choose a photo or PDF (max 10 MB)', textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
            ],
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                  onPressed: () => onPick(DocumentSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                  onPressed: () => onPick(DocumentSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                  onPressed: () => onPick(DocumentSource.pdf),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('PDF'),
                ),
              ],
            ),
            if (showError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Choose a file to upload',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
              ),
          ],
        ),
      ),
    );
  }
}
