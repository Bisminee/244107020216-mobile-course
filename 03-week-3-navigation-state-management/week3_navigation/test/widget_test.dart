import 'package:flutter_test/flutter_test.dart';
import 'package:week3_navigation/main.dart';

void main() {
  testWidgets('menampilkan daftar item dan navigasi ke detail', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Item 1'), findsOneWidget);

    await tester.tap(find.text('Item 1'));
    await tester.pumpAndSettle();

    expect(find.text('Anda membuka item dengan id: 1'), findsOneWidget);
  });
}
