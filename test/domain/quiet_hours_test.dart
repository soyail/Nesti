import 'package:flutter_test/flutter_test.dart';
import 'package:nesti/domain/user_preferences.dart';

void main() {
  test('quiet hours support ranges that cross midnight', () {
    const quietHours = QuietHours(startMinute: 22 * 60, endMinute: 8 * 60);

    expect(quietHours.contains(DateTime(2026, 8, 19, 23)), isTrue);
    expect(quietHours.contains(DateTime(2026, 8, 20, 7, 59)), isTrue);
    expect(quietHours.contains(DateTime(2026, 8, 20, 12)), isFalse);
  });
}
