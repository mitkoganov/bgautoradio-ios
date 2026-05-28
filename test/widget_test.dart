import 'package:flutter_test/flutter_test.dart';
import 'package:bulgarian_auto_radio/data/models/radio_category.dart';

void main() {
  test('RadioCategory.fromString returns correct category', () {
    expect(RadioCategory.fromString('pop'), RadioCategory.pop);
    expect(RadioCategory.fromString('news'), RadioCategory.news);
    expect(RadioCategory.fromString('unknown'), RadioCategory.other);
  });

  test('RadioCategory displayName is not empty', () {
    for (final c in RadioCategory.values) {
      expect(c.displayName.isNotEmpty, true);
    }
  });
}
