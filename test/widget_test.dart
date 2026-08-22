import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:careerconnect/firebase_options.dart';
import 'package:careerconnect/main.dart';

void main() {
  testWidgets('CareerConnect app loads without crashing', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await tester.pumpWidget(const CareerConnectApp());

    expect(find.byType(CareerConnectApp), findsOneWidget);
  });
}
