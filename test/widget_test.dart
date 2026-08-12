import 'package:flutter_test/flutter_test.dart';
import 'package:notes_m_one/app.dart';

void main() {
  testWidgets('renders the bootstrap home placeholder', (tester) async {
    await tester.pumpWidget(const NotesApp());

    expect(find.text('Notes'), findsOneWidget);
  });
}
