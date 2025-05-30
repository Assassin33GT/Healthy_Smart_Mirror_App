import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<StatefulWidget> createState() => _QRScannerState(); // ✅ fixed typo
}

class _QRScannerState extends State<QRScanner> {
  bool isSending = false;
  late final MobileScannerController controller;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onDetect(BarcodeCapture capture) async {
    if (isSending) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() => isSending = true);

    try {
      final uri = Uri.parse('http://192.168.1.100:5000/userid'); // Pi IP
      final response = await http.post(
        uri,
        body: {'user_id': user?.uid ?? 'unknown', 'data': code},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sent User ID: ${user?.uid}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error sending to Pi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    } finally {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: MobileScanner(
        controller: controller,
        onDetect: onDetect,
      ),
    );
  }
}
