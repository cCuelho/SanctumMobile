import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sanctum_mobile/app.dart';
import 'package:sanctum_mobile/services/app_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppServices.resetForTesting();
    await AppServices.init();
  });

  testWidgets('App launches splash then routes to auth', (WidgetTester tester) async {
    await tester.pumpWidget(const SanctumApp());
    await tester.pump();

    expect(find.text('Sanctum'), findsOneWidget);
    expect(find.text('Track. Observe. Learn.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.text('Connect Sanctum'), findsOneWidget);
  });
}
