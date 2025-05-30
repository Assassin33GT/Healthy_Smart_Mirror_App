import 'package:demo/widgets/curvedNavigator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool isSending = false;
  bool hasPermission = false;
  late final MobileScannerController controller;
  User? user = FirebaseAuth.instance.currentUser;

  // Configurable server URL (replace with your Raspberry Pi's IP or use mDNS)
  final String serverUrl = 'http://192.168.1.100:5000/userid';

  @override
  void initState() {
    super.initState();
    print('Initializing QRScanner, user: ${user?.uid}');
    controller = MobileScannerController(
      // facing: CameraFacing.back, // Auto-select camera to avoid issues
      torchEnabled: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestCameraPermission();
    });
  }

  Future<void> _checkAndRequestCameraPermission() async {
    final status = await Permission.camera.status;
    print('Camera permission status: $status');
    if (status.isGranted) {
      setState(() => hasPermission = true);
    } else {
      final result = await Permission.camera.request();
      print('Camera permission request result: $result');
      if (result.isGranted) {
        setState(() => hasPermission = true);
      } else if (result.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Camera permission is permanently denied.'),
              action: SnackBarAction(
                label: 'Open Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Camera permission is required to scan QR codes.'),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: _checkAndRequestCameraPermission,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _sendToPi(String code) async {
    if (isSending || !mounted) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to scan QR codes.')),
      );
      return;
    }

    setState(() => isSending = true);
    print('Sending QR code: $code for user: ${user!.uid}');

    try {
      final uri = Uri.parse(serverUrl);
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': user!.uid, 'data': code}),
          )
          .timeout(const Duration(seconds: 10));

      print('Server response: ${response.statusCode}');
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sent User ID: ${user!.uid}')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      print('Error sending to Pi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $e'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _sendToPi(code),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  void onDetect(BarcodeCapture capture) {
    final code = capture.barcodes.first.rawValue;
    if (code != null) {
      print('Detected QR code: $code');
      _sendToPi(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building QRScanner: hasPermission=$hasPermission, isSending=$isSending');
    final screenWidth = MediaQuery.of(context).size.width;
    final scannerSize = screenWidth * 0.7; // Square scanner for better UX
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 126, 95, 227),
              Color.fromARGB(255, 60, 30, 182),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Scan QR Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.black87, // Higher opacity for readability
                  ),
                ),
                const SizedBox(height: 30),
                if (hasPermission)
                  Container(
                    width: scannerSize,
                    height: scannerSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16), // Slightly rounded corners
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: MobileScanner(
                        controller: controller,
                        onDetect: onDetect,
                        fit: BoxFit.cover, // Preserve aspect ratio
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      const Text(
                        'Waiting for camera permission...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _checkAndRequestCameraPermission,
                        child: const Text('Retry Permission'),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                if (isSending)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                const SizedBox(height: 20),
                Text(
                  user == null
                      ? 'Please log in to scan QR codes'
                      : 'Scan a QR code to send to Magic Mirror',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    backgroundColor: Colors.black87, // Higher opacity
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const Curvednavigator(),
    );
  }
}