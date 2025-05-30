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
    controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    // Delay permission check to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestCameraPermission();
    });
  }

  Future<void> _checkAndRequestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() => hasPermission = true);
    } else {
      final result = await Permission.camera.request();
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
            const SnackBar(
              content: Text('Camera permission is required to scan QR codes.'),
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

    try {
      final uri = Uri.parse(serverUrl);
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': user!.uid, 'data': code}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Sent User ID: ${user!.uid}')));
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
      _sendToPi(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 126, 95, 227),
              Color.fromARGB(255, 60, 30, 182),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Scan QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (hasPermission)
                Center(
                  child: Container(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: MobileScanner(
                      controller: controller,
                      onDetect: onDetect,
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              else
                const Center(child: Text('Waiting for camera permission...')),
              const SizedBox(height: 20),
              if (isSending) const Center(child: CircularProgressIndicator()),
              Center(
                child: Text(
                  user == null
                      ? 'Please log in to scan QR codes'
                      : 'Scan a QR code to send to Magic Mirror',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Curvednavigator(),
    );
  }
}
