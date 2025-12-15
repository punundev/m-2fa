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

    if (rawValue == null || _isProcessing) {
      return;
    }

    if (!rawValue.startsWith('otpauth://')) {
      _showErrorSnackBar(
        'Not a valid 2FA QR Code. Scan a code starting with "otpauth://".',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

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
      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      _showErrorSnackBar('Error saving account: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan 2FA QR Code'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
              autoStart: true,
              detectionTimeoutMs: 500,
            ),
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const SizedBox.shrink(),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Point the camera at the 2FA QR code displayed on your service\'s screen (e.g., GitHub).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator(color: Colors.red)),
        ],
      ),
    );
  }
}
