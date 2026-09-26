import 'package:flutter/material.dart';

/// A text field that suggests values from [suggestions] as you type (e.g.
/// saved clinic names). Free text is still allowed.
class SuggestionField extends StatefulWidget {
  const SuggestionField({
    super.key,
    required this.controller,
    required this.suggestions,
    required this.label,
    required this.icon,
    this.textCapitalization = TextCapitalization.words,
  });

  final TextEditingController controller;
  final List<String> suggestions;
  final String label;
  final IconData icon;
  final TextCapitalization textCapitalization;

  @override
  State<SuggestionField> createState() => _SuggestionFieldState();
}

class _SuggestionFieldState extends State<SuggestionField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  Iterable<String> _options(TextEditingValue value) {
    final q = value.text.trim().toLowerCase();
    final unique = widget.suggestions.toSet();
    if (q.isEmpty) return unique.take(6);
    return unique.where((s) => s.toLowerCase().contains(q) && s.toLowerCase() != q).take(6);
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focus,
      optionsBuilder: _options,
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) => TextFormField(
        controller: controller,
        focusNode: focusNode,
        textCapitalization: widget.textCapitalization,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(labelText: widget.label, prefixIcon: Icon(widget.icon)),
      ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 400),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final option in options)
                  ListTile(
                    dense: true,
                    leading: Icon(widget.icon, size: 18),
                    title: Text(option),
                    onTap: () => onSelected(option),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
