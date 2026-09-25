import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Read-only form field that opens a date picker when tapped.
class DateField extends FormField<DateTime> {
  DateField({
    super.key,
    required String label,
    super.initialValue,
    required DateTime firstDate,
    required DateTime lastDate,
    ValueChanged<DateTime?>? onChanged,
    super.validator,
    bool clearable = true,
    IconData icon = Icons.calendar_today_outlined,
  }) : super(
          builder: (field) {
            final context = field.context;
            final value = field.value;

            Future<void> pick() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ??
                    (lastDate.isBefore(DateTime.now()) ? lastDate : DateTime.now()),
                firstDate: firstDate,
                lastDate: lastDate,
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
                  suffixIcon: clearable && value != null
                      ? IconButton(
                          tooltip: 'Clear date',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            field.didChange(null);
                            onChanged?.call(null);
                          },
                        )
                      : null,
                ),
                child: Text(value == null ? '' : DateFormat.yMMMd().format(value)),
              ),
            );
          },
        );
}
