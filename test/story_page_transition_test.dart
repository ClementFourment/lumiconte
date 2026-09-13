import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiconte/pages/story/story_widgets.dart';

void main() {
  Widget page(int index, String text) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: StoryPageTransition(pageIndex: index, child: Text(text)),
            ),
          ),
        ),
      );

  testWidgets('remplace la page sans erreur de mise en page', (tester) async {
    await tester.pumpWidget(page(0, 'Page un'));
    await tester.pumpWidget(page(1, 'Page deux\nplus longue\nsur trois lignes'));

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Page un'), findsOneWidget);
    expect(find.textContaining('Page deux'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Page un'), findsNothing);
    expect(find.textContaining('Page deux'), findsOneWidget);

    await tester.pumpWidget(page(0, 'Page un'));
    await tester.pumpAndSettle();
    expect(find.text('Page un'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
