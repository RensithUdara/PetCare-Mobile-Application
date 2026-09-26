import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'date_utils.dart';

/// Source of "now" — overridden in tests so date logic is deterministic.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
