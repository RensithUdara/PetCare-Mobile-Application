import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts a Firestore document into plain JSON for `Model.fromJson`,
/// replacing [Timestamp]s (including nested ones) with [DateTime]s and
/// injecting the document id as `id`.
Map<String, dynamic> firestoreDocToJson(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data() ?? {};
  return {..._convert(data) as Map<String, dynamic>, 'id': doc.id};
}

Object? _convert(Object? value) => switch (value) {
      Timestamp t => t.toDate(),
      Map<String, dynamic> m => {for (final e in m.entries) e.key: _convert(e.value)},
      List l => l.map(_convert).toList(),
      _ => value,
    };
