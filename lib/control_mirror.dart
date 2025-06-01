import 'package:demo/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ControlMirror extends StatefulWidget {
  const ControlMirror({super.key});

  @override
  State<ControlMirror> createState() => _ControlMirrorState();
}

class _ControlMirrorState extends State<ControlMirror> {
  final TextEditingController ipController = TextEditingController(
    text: '192.168.1.50',
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> sendCommand(
    String action, {
    Map<String, dynamic>? payload,
  }) async {
    final ip = ipController.text.trim();
    if (ip.isEmpty) {
      _showSnackBar("Please enter a valid IP address");
      return;
    }

    final queryParams = {
      "action": action,
      ...?payload?.map((key, value) => MapEntry(key, value.toString())),
    };
    final url = Uri.parse(
      'http://$ip:8080/remote',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _showSnackBar("Command '$action' sent successfully!");
      } else {
        _showSnackBar(
          "Failed: ${response.statusCode} - ${response.reasonPhrase} - ${response.body}",
        );
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void toggleModule(String moduleName, bool show) {
    final action = show ? "SHOW" : "HIDE";
    sendCommand(action, payload: {"module": moduleName});
  }

  void hideAllQRCodes() {
    toggleModule("MMM-Remote-Control", false);
    toggleModule("MMM-QRCode", false);
    toggleModule("MMM-DynamicQR", false);
  }

  void minimizeMagicMirror() {
    sendCommand("MINIMIZE");
  }

  void restartMagicMirror() {
    sendCommand("RESTART");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Magic Mirror Controller"),
        ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: ipController,
                  decoration: const InputDecoration(
                    labelText: "Enter Mirror IP Address",
                    border: OutlineInputBorder(),
                    fillColor: Colors.white70,
                    filled: true,
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? "Please enter an IP address"
                              : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => toggleModule("clock", true),
                  child: const Text("Show Clock"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => toggleModule("clock", false),
                  child: const Text("Hide Clock"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: restartMagicMirror,
                  child: const Text("Restart Magic Mirror"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: hideAllQRCodes,
                  child: const Text("Hide QR Codes"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: minimizeMagicMirror,
                  child: const Text("Minimize Magic Mirror"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
