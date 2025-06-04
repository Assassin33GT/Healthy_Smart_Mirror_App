import 'package:demo/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatelessWidget {
  const QRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'No user signed in';

    return Scaffold(
      backgroundColor: color1 != Colors.black87 ?Colors.white : color1,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24)
          ),
        ), 
        title: const Text(
          'User QR Code',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: color1 == Colors.black87 ? Colors.black87 : Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Scan this QR code by the Raspberry Pi Camera",
                style: TextStyle(
                  fontSize: 20,
                  color: color1 == Colors.black87 ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (user != null)
                QrImageView(
                  data: uid,
                  version: QrVersions.auto,
                  size: 200.0,
                  gapless: false,
                  backgroundColor: color1 == Colors.black87 ? Colors.white : Colors.white,
                  errorStateBuilder: (cxt, err) {
                    return const Text(
                      'Error generating QR code',
                      style: TextStyle(color: Colors.red),
                    );
                  },
                )
              else
                const Text(
                  'Please sign in to view your QR code',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    ),
                ),
              const SizedBox(height: 20),
              Text(
                user != null ? 'User UID: $uid' : 'No user signed in',
                style: TextStyle(
                  fontSize: 16,
                  color: color1 == Colors.black87 ? Colors.white : Colors.black
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}