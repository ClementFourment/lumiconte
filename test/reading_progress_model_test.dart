import 'package:flutter_test/flutter_test.dart';
import 'package:lumiconte/models/reading_progress_model.dart';

void main() {
  test('le champ moraleUnlocked est prioritaire sur la progression', () {
    expect(
      ReadingProgressModel.moraleUnlockedFrom(
          {'progress': 10, 'moraleUnlocked': true}),
      isTrue,
    );
    expect(
      ReadingProgressModel.moraleUnlockedFrom(
          {'progress': 100, 'moraleUnlocked': false}),
      isFalse,
    );
  });

  test('sans le champ, une histoire terminée garde sa morale', () {
    expect(ReadingProgressModel.moraleUnlockedFrom({'progress': 100}), isTrue);
    expect(ReadingProgressModel.moraleUnlockedFrom({'progress': 42.5}), isFalse);
    expect(ReadingProgressModel.moraleUnlockedFrom({}), isFalse);
  });
}
