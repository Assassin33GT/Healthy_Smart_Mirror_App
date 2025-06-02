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
  final TextEditingController videoUrlController = TextEditingController(text: "https://youtu.be/yul4gq_LrOI?si=tUY0BkVncvWSrl6b");

  double brightnessValue = 100;
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
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void toggleModule(String moduleName, bool show) {
    final action = show ? "SHOW" : "HIDE";
    sendCommand(action, payload: {"module": moduleName});
  }

  void toggleAllModules(bool show) {
    final action = show ? "SHOW" : "HIDE";
    sendCommand(action, payload: {"module": "all"});
  }

  void refreshModule(String moduleName) {
    sendCommand("REFRESH_MODULE", payload: {"module": moduleName});
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
      builder:
          (context) => AlertDialog(
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
                  changeBackgroundColor(
                    '#${_currentColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  void playVideo() {
    final url = videoUrlController.text.trim();
    if (url.isEmpty) {
      _showSnackBar("Please enter a YouTube URL");
      return;
    }
    sendCommand("PLAY_VIDEO", payload: {"url": url});
  }

  void minimizeVideo() {
    sendCommand("MINIMIZE_VIDEO");
  }

  void maximizeVideo() {
    sendCommand("MAXIMIZE_VIDEO");
  }

  void closeVideo() {
    sendCommand("CLOSE_VIDEO");
  }

  void increaseVolume() {
    sendCommand("INCREASE_VOLUME");
  }

  void decreaseVolume() {
    sendCommand("DECREASE_VOLUME");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Mirror Controller")),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Enter Mirror IP Address",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
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
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? "Please enter an IP address"
                                : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "hint: you will find it in the buttom left of the mirror screen (should mirror and phone be connected to the same wifi!)",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  // Brightness Control Section
                  const Text(
                    "Brightness Control",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => toggleModule("clock", true),
                        child: const Icon(Icons.timer_outlined),
                      ),
                      ElevatedButton(
                        onPressed: () => toggleModule("clock", false),
                        child: const Icon(Icons.timer_off_outlined),
                      ),
                      ElevatedButton(
                        onPressed: () => refreshModule("clock"),
                        child: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => toggleModule("calendar", true),
                        child: const Icon(Icons.calendar_month_outlined),
                      ),
                      ElevatedButton(
                        onPressed: () => toggleModule("calendar", false),
                        child: const Icon(
                          Icons.signal_cellular_no_sim_outlined,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => refreshModule("calendar"),
                        child: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => toggleModule("weather", true),
                        child: Icon(Icons.cloud_outlined),
                      ),
                      ElevatedButton(
                        onPressed: () => toggleModule("weather", false),
                        child: const Icon(Icons.cloud_off_outlined),
                      ),
                      ElevatedButton(
                        onPressed: () => refreshModule("weather"),
                        child: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: showMirrorIP,
                        child: const Icon(Icons.link_sharp),
                      ),
                      ElevatedButton(
                        onPressed: hideMirrorIP,
                        child: const Icon(Icons.link_off_sharp),
                      ),
                      ElevatedButton(
                        onPressed: () => refreshModule("MMM-Remote-Control"),
                        child: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: showDietMeals,
                        child: const Icon(Icons.fastfood_outlined),
                      ),

                      ElevatedButton(
                        onPressed: hideDietMeals,
                        child: const Icon(Icons.no_food_outlined),
                      ),
                      ElevatedButton(
                        onPressed: () => refreshModule("MMM-FirebaseBridge"),
                        child: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => toggleAllModules(true),
                        child: const Text("Show All Modules"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => toggleAllModules(false),
                        child: const Text("Hide All Modules"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // System Control Section
                  const Text(
                    "System Controls",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 246, 65, 52),
                    ),
                    onPressed: shutdownMagicMirror,
                    child: const Text("Shutdown Magic Mirror"),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Background Color Control",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _openColorPicker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentColor,
                    ),
                    child: const Icon(Icons.color_lens_outlined),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Display Video On Mirror",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: videoUrlController,
                    decoration: const InputDecoration(
                      labelText: "Enter YouTube URL",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      fillColor: Colors.white70,
                      filled: true,
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? "Please enter a URL"
                                : null,
                  ),
                  const SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: playVideo,
                    child: const Text("Play Video"),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: minimizeVideo,
                        child: const Icon(Icons.minimize),
                      ),
                      ElevatedButton(
                        onPressed: maximizeVideo,
                        child: const Icon(Icons.fullscreen),
                      ),
                      ElevatedButton(
                        onPressed: closeVideo,
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: decreaseVolume,
                        child: const Icon(Icons.volume_down),
                      ),
                      ElevatedButton(
                        onPressed: increaseVolume,
                        child: const Icon(Icons.volume_up),
                      ),
                    ],
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