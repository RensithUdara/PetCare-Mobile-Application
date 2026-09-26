import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/routing/app_routes.dart';
import 'package:petcare/core/utils/stream_utils.dart';

void main() {
  group('combineLatest', () {
    test('waits for every source, then emits on each change', () async {
      final a = StreamController<int>();
      final b = StreamController<String>();
      final out = <String>[];
      final sub = combineLatest([a.stream, b.stream], (v) => '${v[0]}${v[1]}').listen(out.add);

      a.add(1);
      await pumpEventQueue();
      expect(out, isEmpty, reason: 'b has not emitted yet');

      b.add('x');
      a.add(2);
      b.add('y');
      await pumpEventQueue();
      expect(out, ['1x', '2x', '2y']);

      await sub.cancel();
      await a.close();
      await b.close();
    });

    test('forwards errors', () async {
      final a = StreamController<int>();
      final errors = <Object>[];
      final sub = combineLatest([a.stream], (v) => v).listen(null, onError: errors.add);

      a.addError(StateError('boom'));
      await pumpEventQueue();
      expect(errors.single, isA<StateError>());

      await sub.cancel();
      await a.close();
    });
  });

  group('AppRoutes', () {
    test('appointmentNew builds optional query parameters', () {
      expect(AppRoutes.appointmentNew(), '/edit/appointment');
      expect(AppRoutes.appointmentNew(petId: 'p1'), '/edit/appointment?petId=p1');
      expect(
        AppRoutes.appointmentNew(petId: 'p1', date: DateTime(2026, 10, 5, 14)),
        '/edit/appointment?petId=p1&date=2026-10-05',
      );
    });

    test('forms live outside the tabs', () {
      expect(AppRoutes.petNew, startsWith('/edit/'));
      expect(AppRoutes.vaccinationEdit('v1'), '/edit/vaccination/v1');
      expect(AppRoutes.appointmentEdit('a1'), '/edit/appointment/a1');
    });
  });
}
