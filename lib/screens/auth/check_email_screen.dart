import 'dart:ui';
import 'package:flutter/material.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  String getMaskedEmail(String email) {
    if (email.isEmpty) return 'your email address';
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final localPart = parts[0];
    final domainPart = parts[1];

    String maskedLocal = localPart.length > 4
        ? '${localPart.substring(0, 3)}****${localPart.substring(localPart.length - 1)}'
        : localPart;

    return '$maskedLocal@$domainPart';
  }

  @override
  Widget build(BuildContext context) {
    final String email =
        ModalRoute.of(context)?.settings.arguments as String? ??
        'your email address';
    final primaryColor = Theme.of(context).primaryColor;
    final maskedEmail = getMaskedEmail(email);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Dynamic Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withBlue(150),
                  primaryColor.withRed(100).withBlue(200),
                  primaryColor.withRed(50),
                ],
              ),
            ),
          ),
          // Floating Orbs
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.mark_email_read_rounded,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Verify Your Email',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'A verification link has been sent to:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            maskedEmail,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Please check your inbox and click the activation link to proceed.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/login');
                            },
                            icon: Icon(
                              Icons.login_rounded,
                              color: primaryColor,
                            ),
                            label: const Text(
                              'Go to Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 30,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Verification email sent again!',
                                  ),
                                  backgroundColor: Colors.green.withOpacity(
                                    0.8,
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: const Text(
                              'Resend Verification Email',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
