import 'package:auth/screens/auth/2fa_screen.dart';
import 'package:auth/screens/auth/check_email_screen.dart';
import 'package:auth/screens/auth/forgot_password_screen.dart';
import 'package:auth/screens/auth/login_screen.dart';
import 'package:auth/screens/auth/signup_screen.dart';
import 'package:auth/screens/home/change_password_screen.dart';
import 'package:auth/screens/home/change_pin_screen.dart';
import 'package:auth/screens/home/edit_profile_screen.dart';
import 'package:auth/screens/security/register_2fa_screen.dart';
import 'package:auth/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:auth/screens/main_wrapper.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/splash': (_) => const SplashScreen(),
  '/login': (_) => const LoginScreen(),
  '/signup': (_) => const SignupScreen(),
  '/2fa': (_) => TwoFAScreen(),
  '/home': (_) => const MainWrapper(),
  '/forgot-password': (_) => const ForgotPasswordScreen(),
  '/change-password': (_) => const ChangePasswordScreen(),
  '/change-pin': (_) => const ChangePinScreen(),
  '/edit-profile': (_) => const EditProfileScreen(),
  '/register-2fa': (context) => const Register2FAScreen(),
  '/check-email': (context) => const CheckEmailScreen(),
};
