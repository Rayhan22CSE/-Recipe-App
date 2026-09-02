import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe/app/theme.dart';
import 'package:flutter_recipe/widgets/custom_button.dart';
import 'package:flutter_recipe/widgets/custom_text_field.dart';

void main() {
  testWidgets('CustomButton renders correctly with text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: CustomButton(
            text: 'Sign In',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(CustomButton), findsOneWidget);
  });

  testWidgets('CustomTextField renders with label and hint', (WidgetTester tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: CustomTextField(
            controller: controller,
            labelText: 'Email Address',
            hintText: 'Enter your email',
            prefixIcon: Icons.email_outlined,
          ),
        ),
      ),
    );

    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);
  });
}
