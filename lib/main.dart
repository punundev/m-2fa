import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants.dart';
import 'routes/app_routes.dart';
import 'controllers/auth_provider.dart';
// <<< NEW IMPORT REQUIRED
import 'controllers/authenticator_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(
    MultiProvider(
      providers: [
        // Your existing AuthProvider
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),

        // <<< FIX: Add the AuthenticatorProvider here
        ChangeNotifierProvider<AuthenticatorProvider>(
          create: (_) => AuthenticatorProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth App',
      initialRoute: '/splash',
      debugShowCheckedModeBanner: false,
      routes: appRoutes,
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import 'core/constants.dart';
// import 'routes/app_routes.dart';
// import 'controllers/auth_provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
//       ],
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Auth App',
//       initialRoute: '/splash',
//       debugShowCheckedModeBanner: false,
//       routes: appRoutes,
//     );
//   }
// }
