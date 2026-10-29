import 'package:arqamy/core/widgets/app_snack_bar.dart';
import 'package:arqamy/config/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('error snackbars use the error style', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showAppSnackBar(context, 'Something went wrong',
                  isError: true),
              child: const Text('Show error'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show error'));
    await tester.pump();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, ThemeData.light().colorScheme.error);
    expect(find.byIcon(Icons.error), findsOneWidget);
    expect(find.text('Something went wrong'), findsOneWidget);
  });

  testWidgets('success snackbars use the success style', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showAppSnackBar(context, 'Saved'),
              child: const Text('Show success'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show success'));
    await tester.pump();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, LightColors.success);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
  });
}
