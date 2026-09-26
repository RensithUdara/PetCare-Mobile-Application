import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

/// Renders PDF bytes with the platform's native renderer (Android
/// PdfRenderer / iOS PDFKit): vertical scrolling, pinch-zoom and a page bar.
class PdfDocumentView extends StatefulWidget {
  const PdfDocumentView({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  State<PdfDocumentView> createState() => _PdfDocumentViewState();
}

class _PdfDocumentViewState extends State<PdfDocumentView> {
  late final _controller = PdfControllerPinch(document: PdfDocument.openData(widget.bytes));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: PdfViewPinch(
            controller: _controller,
            padding: 8,
            backgroundDecoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest),
            builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(),
              documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
              pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
              errorBuilder: (_, error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'This PDF couldn’t be displayed. Try opening it in another app.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ),
        ),
        Material(
          color: theme.colorScheme.surfaceContainer,
          child: PdfPageNumber(
            controller: _controller,
            builder: (context, state, page, pagesCount) {
              final total = pagesCount ?? 0;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Previous page',
                    icon: const Icon(Icons.chevron_left),
                    onPressed: page > 1
                        ? () => _controller.previousPage(
                              curve: Curves.easeOut,
                              duration: const Duration(milliseconds: 200),
                            )
                        : null,
                  ),
                  Text(total == 0 ? 'Loading…' : 'Page $page of $total',
                      style: theme.textTheme.labelLarge),
                  IconButton(
                    tooltip: 'Next page',
                    icon: const Icon(Icons.chevron_right),
                    onPressed: total > 0 && page < total
                        ? () => _controller.nextPage(
                              curve: Curves.easeOut,
                              duration: const Duration(milliseconds: 200),
                            )
                        : null,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
