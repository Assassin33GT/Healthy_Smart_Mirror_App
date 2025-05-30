import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});
  @override
  State<StatefulWidget> createState() => _QRScannnerState();
}

class _QRScannnerState extends State<QRScanner> {
  bool isSending = false;

  void onDetect(BarcodeCapture capture) async {
    if (isSending) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() => isSending = true);

    try {
      final uri = Uri.parse('http://192.168.1.100:5000/userid'); // Pi's IP
      await http.post(uri, body: {'user_id': code});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sent User ID: $code')),
      );
    } catch (e) {
      print('Error sending to Pi: $e');
    } finally {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Web QR Scanner')),
      body: MobileScanner(onDetect: onDetect),
    );
  }
}
