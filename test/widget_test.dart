import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_ai/main.dart';

void main() {
  testWidgets('TutorAI app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const TutorAiApp());

    expect(find.text('TutorAI'), findsOneWidget);
    expect(find.text('Good evening! 👋'), findsOneWidget);
    expect(find.text('Snap a Question'), findsOneWidget);
  });
}
