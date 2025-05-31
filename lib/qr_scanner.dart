import 'package:demo/widgets/curvednavigator.dart';
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

  // Server URL for Windows PC
  final String serverUrl = 'http://192.168.190.129:5000/userid';

  @override
  void initState() {
    super.initState();
    print('Initializing QRScanner, user: ${user?.uid}');
    controller = MobileScannerController(
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
      print('Starting camera');
      await controller.start().catchError((e) {
        print('Error starting camera: $e');
      });
    } else {
      final result = await Permission.camera.request();
      print('Camera permission request result: $result');
      if (result.isGranted) {
        setState(() => hasPermission = true);
        print('Starting camera after permission granted');
        await controller.start().catchError((e) {
          print('Error starting camera: $e');
        });
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

  Future<void> _closeQRCamera() async {
    if (hasPermission) {
      print('Stopping camera');
      await controller.stop().catchError((e) {
        print('Error stopping camera: $e');
      });
    }
  }

  @override
  void dispose() {
    print('Disposing QRScanner');
    controller.dispose();
    super.dispose();
  }

  Future<void> _sendToServer(String code) async {
    if (isSending || !mounted) return;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to scan QR codes.')),
        );
      }
      return;
    }

    setState(() => isSending = true);
    print('Sending QR code: $code for user: ${user?.uid}');

    // Parse QR code if it's a URL or JSON
    String qrData = code;
    if (code.startsWith('http')) {
      var uri = Uri.parse(code);
      qrData = uri.queryParameters['user_id'] ?? code;
    } else if (code.startsWith('{')) {
      try {
        var json = jsonDecode(code);
        qrData = json['user_id'] ?? code;
      } catch (e) {
        print('Error parsing JSON QR code: $e');
      }
    }

    try {
      final uri = Uri.parse(serverUrl);
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': user!.uid, 'data': qrData}),
          )
          .timeout(const Duration(seconds: 10));

      print('Server response: ${response.statusCode}, Body: ${response.body}');
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
      print('Error sending to server: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $e'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _sendToServer(code),
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
      _sendToServer(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building QRScanner: hasPermission=$hasPermission, isSending=$isSending');
    final screenWidth = MediaQuery.of(context).size.width;
    final scannerSize = screenWidth * 0.7;
    return WillPopScope(
      onWillPop: () async {
        print('Back button pressed, stopping camera');
        await _closeQRCamera();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QR Scanner'),
          backgroundColor: const Color.fromARGB(255, 60, 30, 182),
          actions: [
            IconButton(
              icon: const Icon(Icons.flashlight_on),
              onPressed: hasPermission ? () => controller.toggleTorch() : null,
              tooltip: 'Toggle Torch',
            ),
          ],
        ),
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
                      backgroundColor: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (hasPermission)
                    Container(
                      width: scannerSize,
                      height: scannerSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: MobileScanner(
                          controller: controller,
                          onDetect: onDetect,
                          fit: BoxFit.cover,
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
                      backgroundColor: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _closeQRCamera,
                    child: const Text(
                      'Close Camera',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Curvednavigator(
        ),
      ),
    );
  }
}