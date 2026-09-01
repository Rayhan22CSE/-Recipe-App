import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe/app/app.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RecipeApp());
    expect(find.byType(RecipeApp), findsOneWidget);
  });
}
