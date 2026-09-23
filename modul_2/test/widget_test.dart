import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modul_2/main.dart';

void main() {
  testWidgets('Row and Column grid test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Memastikan judul AppBar tampil
    expect(find.text('Row and Column'), findsOneWidget);

    // Memastikan 4 icon favorite berwarna merah ditemukan
    expect(find.byIcon(Icons.favorite), findsNWidgets(4));

    // Memastikan widget KotakBiru sebanyak 4 ditemukan
    expect(find.byType(KotakBiru), findsNWidgets(4));
  });
}
