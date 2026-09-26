import 'package:flutter/material.dart';

/// Read-only form field that opens a time picker when tapped.
class TimeField extends FormField<TimeOfDay> {
  TimeField({
    super.key,
    required String label,
    super.initialValue,
    ValueChanged<TimeOfDay>? onChanged,
    super.validator,
    IconData icon = Icons.schedule,
  }) : super(
          builder: (field) {
            final context = field.context;
            final value = field.value;

            Future<void> pick() async {
              final picked = await showTimePicker(
                context: context,
                initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
              );
              if (picked != null) {
                field.didChange(picked);
                onChanged?.call(picked);
              }
            }

            return InkWell(
              onTap: pick,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                isEmpty: value == null,
                decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: Icon(icon),
                  errorText: field.errorText,
                ),
                child: Text(value == null ? '' : value.format(context)),
              ),
            );
          },
        );
}
