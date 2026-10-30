import 'package:flutter_test/flutter_test.dart';
import 'package:lokasi_flutter/main.dart';

void main() {
  testWidgets('LocationScreen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title and action button are displayed.
    expect(find.text('Lokasi Saya'), findsOneWidget);
    expect(find.text('TAMPILKAN LOKASI SAAT INI'), findsOneWidget);
  });
}