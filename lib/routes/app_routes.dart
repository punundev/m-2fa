import 'package:auth/screens/auth/2fa_screen.dart';
import 'package:auth/screens/auth/forgot_password_screen.dart';
import 'package:auth/screens/auth/login_screen.dart';
import 'package:auth/screens/auth/signup_screen.dart';
import 'package:auth/screens/home/home_screen.dart';
import 'package:auth/screens/home/profile_screen.dart';
import 'package:auth/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/splash': (_) => SplashScreen(),
  '/login': (_) => LoginScreen(),
  '/signup': (_) => SignupScreen(),
  '/2fa': (_) => TwoFAScreen(),
  '/home': (_) => HomeScreen(),
  '/profile': (_) => ProfileScreen(),
  '/forgot-password': (_) => const ForgotPasswordScreen(),
};
