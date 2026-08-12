import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/app.dart';

void main() {
  testWidgets('launches the durable home screen', (tester) async {
    await tester.pumpWidget(NotesApp());

    expect(find.text('Notes'), findsOneWidget);
  });
}
