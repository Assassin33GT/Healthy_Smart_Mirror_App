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
    text: '192.168.1.1',
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double brightnessValue = 100; // Initial brightness value (0-200)

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void toggleModule(String moduleName, bool show) {
    final action = show ? "SHOW" : "HIDE";
    sendCommand(action, payload: {"module": moduleName});
  }

  void toggleAllModules(bool show) {
    final action = show ? "SHOW" : "HIDE";
    sendCommand(action, payload: {"module": "all"});
  }

  void hideMirrorIP() {
    toggleModule("MMM-Remote-Control", false);
  }

  void showMirrorIP() {
    toggleModule("MMM-Remote-Control", true);
  }

  void minimizeMagicMirror() {
    sendCommand("MINIMIZE");
  }

  void restartMagicMirror() {
    sendCommand("RESTART");
  }

  void reloadMagicMirror() {
    sendCommand("REFRESH");
  }

  void shutdownMagicMirror() {
    sendCommand("SHUTDOWN");
  }

  void adjustBrightness(double value) {
    setState(() {
      brightnessValue = value;
    });
    sendCommand("BRIGHTNESS", payload: {"value": brightnessValue.toInt()});
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
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Enter Mirror IP Address",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: ipController,
                    decoration: const InputDecoration(
                      //labelText: "Enter Mirror IP Address",
                      border: OutlineInputBorder(),
                      fillColor: Colors.white70,
                      filled: true,
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? "Please enter an IP address"
                            : null,
                  ),
                  const SizedBox(height: 10),
                  Text("hint: you will find it in the buttom left of the mirror screen (should mirror and phone be connected to the same wifi)",
                      style: TextStyle(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 30),
                  // Brightness Control Section
                  const Text(
                    "Brightness Control",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    value: brightnessValue,
                    min: 0,
                    max: 200,
                    divisions: 20,
                    label: brightnessValue.round().toString(),
                    onChanged: (value) {
                      adjustBrightness(value);
                    },
                  ),
                  const SizedBox(height: 20),
                  // Module Control Section
                  const Text(
                    "Module Controls",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
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
                    onPressed: () => toggleModule("calendar", true),
                    child: const Text("Show Calendar"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => toggleModule("calendar", false),
                    child: const Text("Hide Calendar"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => toggleModule("weather", true),
                    child: const Text("Show Weather"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => toggleModule("weather", false),
                    child: const Text("Hide Weather"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: showMirrorIP,
                    child: const Text("Show Mirror IP"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: hideMirrorIP,
                    child: const Text("Hide Mirror IP"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => toggleAllModules(true),
                    child: const Text("Show All Modules"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => toggleAllModules(false),
                    child: const Text("Hide All Modules"),
                  ),
                  const SizedBox(height: 20),

                  // System Control Section
                  const Text(
                    "System Controls",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: restartMagicMirror,
                    child: const Text("Restart Magic Mirror"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: reloadMagicMirror,
                    child: const Text("Reload Magic Mirror"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: minimizeMagicMirror,
                    child: const Text("Minimize Magic Mirror"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: shutdownMagicMirror,
                    child: const Text("Shutdown Magic Mirror"),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}