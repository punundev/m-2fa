import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants.dart';
import 'routes/app_routes.dart';
import 'controllers/auth_provider.dart';
import 'controllers/authenticator_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  final authProvider = AuthProvider();
  await authProvider.fetchProfile();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),

        ChangeNotifierProvider<AuthenticatorProvider>(
          create: (_) => AuthenticatorProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryAppColor = Color(0xFF0D47A1);

    return MaterialApp(
      title: 'Nun Auth',
      initialRoute: '/splash',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryAppColor,
          primary: primaryAppColor,
          secondary: primaryAppColor,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryAppColor,
          foregroundColor: Colors.white,
        ),
      ),

      routes: appRoutes,
    );
  }
}
