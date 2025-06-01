import 'package:demo/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  Color _currentColor = Colors.purpleAccent;

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 500)));
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

  void hideDietMeals() {
    toggleModule("MMM-FirebaseBridge", false);
  }

  void showDietMeals() {
    toggleModule("MMM-FirebaseBridge", true);
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

  void changeBackgroundColor(String color) {
    sendCommand("CHANGE_BACKGROUND", payload: {"color": color});
  }
  
  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a Background Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _currentColor,
            onColorChanged: (color) {
              setState(() {
                _currentColor = color;
              });
            },
            
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Set'),
            onPressed: () {
              changeBackgroundColor('#${_currentColor.value.toRadixString(16).padLeft(8, '0').substring(2)}');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Mirror Controller"),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      fillColor: Colors.white70,
                      filled: true,
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? "Please enter an IP address"
                            : null,
                  ),
                  const SizedBox(height: 10),
                  Text("hint: you will find it in the buttom left of the mirror screen (should mirror and phone be connected to the same wifi!)",
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
                    onPressed: showDietMeals,
                    child: const Text("Show Diets Meals"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: hideDietMeals,
                    child: const Text("Hide Diets Meals"),
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
                  const SizedBox(height: 10),
                  const Text(
                    "Background Color Control",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  // ElevatedButton(
                  //   onPressed: () => changeBackgroundColor("red"),
                  //   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  //   child: const Text("Set Red Background"),
                  // ),
                  // const SizedBox(height: 10),
                  // ElevatedButton(
                  //   onPressed: () => changeBackgroundColor("green"),
                  //   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  //   child: const Text("Set Green Background"),
                  // ),
                  // const SizedBox(height: 10),
                  // ElevatedButton(
                  //   onPressed: () => changeBackgroundColor("blue"),
                  //   style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  //   child: const Text("Set Blue Background"),
                  // ),
                  // const SizedBox(height: 10),
                  // ElevatedButton(
                  //   onPressed: () => changeBackgroundColor("black"),
                  //   style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  //   child: const Text("Set Black Background", style: TextStyle(color: Colors.white)),
                  // ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _openColorPicker,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: const Text("Pick Background Color"),
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