import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/utils/greeting.dart';

void main() {
  DateTime at(int hour) => DateTime(2026, 1, 1, hour);

  test('greetingFor returns the right time-of-day greeting', () {
    expect(greetingFor(at(5)), 'Good Morning');
    expect(greetingFor(at(11)), 'Good Morning');
    expect(greetingFor(at(12)), 'Good Afternoon');
    expect(greetingFor(at(16)), 'Good Afternoon');
    expect(greetingFor(at(17)), 'Good Evening');
    expect(greetingFor(at(2)), 'Good Evening');
  });
}
