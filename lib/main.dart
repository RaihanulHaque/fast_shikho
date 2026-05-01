import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/app_services.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SessionService()),
      ],
      child: const FastShikhoApp(),
    ),
  );
}

class FastShikhoApp extends StatelessWidget {
  const FastShikhoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'দ্রুত শিখো',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (auth.isLoggedIn) {
            return const MainShell();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
