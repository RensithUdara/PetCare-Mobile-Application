import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/modern_widgets.dart';
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
                  appBar: const BrandAppBar.page(title: 'Document'),
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
    await showSuccessDialog(
      context,
      title: _isEditing ? 'Document updated' : 'Document uploaded',
      message: _isEditing ? null : 'It\u2019s safely stored with your pet\u2019s records.',
    );
    if (mounted) context.pop();
  }

  static String _shortLabel(DocumentType t) => switch (t) {
        DocumentType.vaccinationCertificate => 'Certificate',
        DocumentType.medicalReport => 'Report',
        _ => t.label,
      };

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
    const accent = FeatureAccent.documents;

    return Scaffold(
      appBar: BrandAppBar.page(title: _isEditing ? 'Edit Document' : 'Add Document'),
      bottomNavigationBar: FormSaveBar(
        label: _isEditing ? 'Save Changes' : 'Upload Document',
        icon: _isEditing ? Icons.check_rounded : Icons.cloud_upload_outlined,
        busy: editor.isBusy,
        busyLabel: editor.uploadProgress == null
            ? 'Saving…'
            : 'Uploading ${(editor.uploadProgress! * 100).round()}%',
        onPressed: _save,
      ),
      body: AbsorbPointer(
        absorbing: editor.isBusy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              GradientHeader(
                floating: true,
                margin: const EdgeInsets.only(top: 16),
                gradient: accent.gradient,
                padding: const EdgeInsets.all(20),
                child: _isEditing
                    ? _FilePreview(
                        name: widget.initial!.fileName,
                        size: widget.initial!.sizeBytes,
                        thumbnail: DocumentThumbnail(document: widget.initial!, size: 56),
                      )
                    : _UploadPanel(file: _file, onPick: _pick),
              ),
              if (_fileMissing)
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 4),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
                      const SizedBox(width: 6),
                      Text('Choose a file to upload',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                    ],
                  ),
                ),
              if (editor.uploadProgress != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: editor.uploadProgress,
                    minHeight: 6,
                    color: accent.color,
                    backgroundColor: accent.color.withValues(alpha: 0.15),
                  ),
                ),
              ],
              FormSection(
                title: 'Details',
                icon: Icons.description_outlined,
                accent: accent,
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.required(v, field: 'Document name'),
                    decoration: const InputDecoration(
                      labelText: 'Document name *',
                      hintText: 'e.g. Annual blood panel',
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FieldLabel('Type'),
                      TileGrid(
                        children: [
                          for (final t in DocumentType.values)
                            SelectTile(
                              label: _shortLabel(t),
                              icon: t.icon,
                              accent: accent,
                              selected: _type == t,
                              onTap: () => setState(() => _type = t),
                            ),
                        ],
                      ),
                    ],
                  ),
                  DateField(
                    label: 'Document date *',
                    initialValue: _date,
                    firstDate: DateTime(1990),
                    lastDate: now,
                    clearable: false,
                    validator: (d) => d == null ? 'Date is required' : null,
                    onChanged: (d) => setState(() => _date = d),
                  ),
                ],
              ),
              FormSection(
                title: 'Description',
                icon: Icons.sticky_note_2_outlined,
                accent: FeatureAccent.calendar,
                children: [
                  TextFormField(
                    controller: _description,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Results, what the vet said, follow-ups…',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero content for a new document: choose a file, or preview the chosen one.
class _UploadPanel extends StatelessWidget {
  const _UploadPanel({required this.file, required this.onPick});

  final DocumentFile? file;
  final ValueChanged<DocumentSource> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final f = file;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (f == null) ...[
          Text('Upload a document',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('A photo or PDF, up to 10 MB',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
        ] else
          _FilePreview(
            name: f.fileName,
            size: f.sizeBytes,
            thumbnail: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: f.contentType.startsWith('image/')
                  ? Image.memory(f.bytes, width: 56, height: 56, fit: BoxFit.cover)
                  : Container(
                      width: 56,
                      height: 56,
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Text('PDF',
                          style: TextStyle(color: FeatureAccent.documents.deep, fontWeight: FontWeight.w800)),
                    ),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final (i, (source, icon, label)) in const [
              (DocumentSource.camera, Icons.photo_camera_outlined, 'Camera'),
              (DocumentSource.gallery, Icons.photo_library_outlined, 'Gallery'),
              (DocumentSource.pdf, Icons.picture_as_pdf_outlined, 'PDF'),
            ].indexed) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: _SourceTile(icon: icon, label: label, onTap: () => onPick(source))),
            ],
          ],
        ),
        if (f != null) ...[
          const SizedBox(height: 8),
          Text('Tap a source to choose a different file',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
        ],
      ],
    );
  }
}

/// White card with the file's thumbnail, name and size.
class _FilePreview extends StatelessWidget {
  const _FilePreview({required this.name, required this.size, required this.thumbnail});

  final String name;
  final int size;
  final Widget thumbnail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          thumbnail,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                Text(formatBytes(size),
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Colors.white),
        ],
      ),
    );
  }
}

/// Big glass button for a file source.
class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(18);
    return Material(
      color: Colors.white,
      borderRadius: shape,
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: shape,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, size: 28, color: FeatureAccent.documents.deep),
              const SizedBox(height: 6),
              Text(label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: FeatureAccent.documents.deep,
                        fontWeight: FontWeight.w800,
                      )),
            ],
          ),
        ),
      ),
    );
  }
}
