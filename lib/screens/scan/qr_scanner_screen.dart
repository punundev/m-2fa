import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:auth/controllers/authenticator_provider.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    autoStart: true,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, String> _parseOtpAuthUri(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      final secret = uri.queryParameters['secret'];

      if (secret == null || secret.isEmpty) {
        throw const FormatException(
          'QR Code does not contain a valid 2FA secret.',
        );
      }

      String label = uri.pathSegments.last;
      String serviceName = uri.queryParameters['issuer'] ?? 'Unknown Service';
      String email = label.contains(':') ? label.split(':').last : label;

      if (label.contains(':')) {
        serviceName = label.split(':').first;
      }

      return {
        'serviceName': serviceName.trim(),
        'email': email.trim(),
        'secret': secret.trim(),
      };
    } catch (e) {
      debugPrint('Parsing Error: $e');
      throw FormatException('Invalid QR code format: $uriString');
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    final barcode = capture.barcodes.first;
    final rawValue = barcode.rawValue;

    if (rawValue == null || _isProcessing) return;

    if (!rawValue.startsWith('otpauth://')) {
      _showErrorSnackBar('Not a valid 2FA QR Code.');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final data = _parseOtpAuthUri(rawValue);

      await context.read<AuthenticatorProvider>().addAccount(
        serviceName: data['serviceName']!,
        email: data['email']!,
        secret: data['secret']!,
      );

      await context.read<AuthenticatorProvider>().fetchAccounts();

      if (mounted) {
        Navigator.pop(context, true);
        _showSuccessSnackBar('Successfully added ${data['serviceName']}!');
      }
    } on FormatException catch (e) {
      _showErrorSnackBar(e.message);
      setState(() => _isProcessing = false);
    } catch (e) {
      _showErrorSnackBar('Error saving account: $e');
      setState(() => _isProcessing = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, child) {
              final torchState = state.torchState;
              switch (torchState) {
                case TorchState.off:
                  return IconButton(
                    icon: const Icon(
                      Icons.flash_off_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => _controller.toggleTorch(),
                  );
                case TorchState.on:
                  return IconButton(
                    icon: const Icon(
                      Icons.flash_on_rounded,
                      color: Colors.yellow,
                    ),
                    onPressed: () => _controller.toggleTorch(),
                  );
                case TorchState.auto:
                  return IconButton(
                    icon: const Icon(
                      Icons.flash_auto_rounded,
                      color: Colors.white70,
                    ),
                    onPressed: () => _controller.toggleTorch(),
                  );
                case TorchState.unavailable:
                  return const SizedBox.shrink();
              }
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.flip_camera_ios_rounded,
              color: Colors.white,
            ),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Glass Overlay with cutout
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Blurred edges
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 0,
                sigmaY: 0,
              ), // Placeholder for potential blur outside
              child: Container(color: Colors.transparent),
            ),
          ),
          // Scanning Frame
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70, width: 2),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Scanner "Laser" Animation (Simplified)
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 230),
                        duration: const Duration(seconds: 2),
                        builder: (context, value, child) {
                          return Positioned(
                            top: value,
                            left: 10,
                            right: 10,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        onEnd: () {
                          // Loop logic would go here, but this is a simplified view
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: const Text(
                        'Align QR Code within the frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Instructions
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Point the camera at the 2FA QR code displayed on your service\'s screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black45,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
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
