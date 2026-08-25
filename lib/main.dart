import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/jobs/providers/jobs_provider.dart';
import 'features/chat/providers/chat_provider.dart';
import 'features/applications/providers/applications_provider.dart';
import 'features/saved/providers/saved_provider.dart';
import 'features/notifications/providers/notifications_provider.dart';
import 'features/social/providers/social_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CareerConnectApp());
}

class CareerConnectApp extends StatelessWidget {
  const CareerConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => JobsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(
            create: (_) => ApplicationsProvider()),
        ChangeNotifierProvider(create: (_) => SavedProvider()),
        ChangeNotifierProvider(
            create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(
            create: (_) => SocialProvider()),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter(
            authProvider: context.read<AuthProvider>(),
          ).router;
          return MaterialApp.router(
            title: 'CareerConnect',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}