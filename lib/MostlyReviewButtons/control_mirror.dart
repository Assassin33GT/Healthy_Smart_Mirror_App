import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';

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
  final TextEditingController videoUrlController = TextEditingController(
    text: "https://youtu.be/ko2OffMrn2s?si=G_van8LJBjwbKuYl",
  );

  double brightnessValue = 100;
  Color _currentColor = Colors.purpleAccent;

  // Bluetooth-related variables
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _selectedDevice;
  BluetoothConnection? _connection;
  bool _isBluetoothConnected = false;
  bool _isDiscovering = false;
  bool _useBluetooth = false; // Toggle between Wi-Fi and Bluetooth

  @override
  void initState() {
    super.initState();
    _checkBluetoothEnabled();
  }

  // Check if Bluetooth is enabled and request to enable it if not
  Future<void> _checkBluetoothEnabled() async {
    bool isEnabled = await _bluetooth.isEnabled ?? false;
    if (!isEnabled) {
      await _bluetooth.requestEnable();
    }
  }

  // Discover Bluetooth devices
  Future<void> _discoverDevices() async {
    setState(() {
      _isDiscovering = true;
      _devicesList = [];
    });

    try {
      var devices = await _bluetooth.getBondedDevices();
      setState(() {
        _devicesList = devices;
        _isDiscovering = false;
      });

      if (devices.isEmpty) {
        _showSnackBar("No Bluetooth devices found. Ensure the Magic Mirror is paired.");
      }
    } catch (e) {
      setState(() {
        _isDiscovering = false;
      });
      _showSnackBar("Error discovering devices: $e");
    }
  }

  // Connect to a Bluetooth device
  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_connection != null && _connection!.isConnected) {
      await _connection!.close();
    }

    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        _connection = connection;
        _selectedDevice = device;
        _isBluetoothConnected = true;
        _useBluetooth = true; // Switch to Bluetooth mode
      });
      _showSnackBar("Connected to ${device.name ?? device.address}");
    } catch (e) {
      setState(() {
        _isBluetoothConnected = false;
        _useBluetooth = false;
      });
      _showSnackBar("Error connecting to device: $e");
    }
  }

  // Disconnect from the Bluetooth device
  Future<void> _disconnectBluetooth() async {
    if (_connection != null && _connection!.isConnected) {
      await _connection!.close();
    }
    setState(() {
      _connection = null;
      _selectedDevice = null;
      _isBluetoothConnected = false;
      _useBluetooth = false; // Switch back to Wi-Fi mode
    });
    _showSnackBar("Disconnected from Bluetooth device");
  }

  // Send command over Bluetooth
  Future<void> _sendBluetoothCommand(String command) async {
    if (_connection == null || !_connection!.isConnected) {
      _showSnackBar("Not connected to any Bluetooth device");
      return;
    }

    try {
      _connection!.output.add(Uint8List.fromList(command.codeUnits));
      await _connection!.output.allSent;
      _showSnackBar("Command '$command' sent via Bluetooth!");
    } catch (e) {
      _showSnackBar("Error sending Bluetooth command: $e");
    }
  }

  Future<void> sendCommand(
    String action, {
    Map<String, dynamic>? payload,
  }) async {
    if (_useBluetooth) {
      // Send via Bluetooth
      final queryParams = {
        "action": action,
        ...?payload?.map((key, value) => MapEntry(key, value.toString())),
      };
      final command = Uri(path: "/remote", queryParameters: queryParams).toString();
      await _sendBluetoothCommand(command);
    } else {
      // Send via Wi-Fi (original implementation)
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
      backgroundColor: Colors.black87,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        backgroundColor: const Color.fromARGB(175, 120, 137, 120),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.green, Colors.black87],
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
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? "Please enter an IP address"
                            : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "hint: you will find it in the bottom left of the mirror screen (should mirror and phone be connected to the same wifi!)",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  // Bluetooth Control Section
                  const Text(
                    "Bluetooth Controls",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: _isDiscovering ? null : _discoverDevices,
                        child: _isDiscovering
                            ? CircularProgressIndicator(color: Colors.white70)
                            : const Text("Discover Devices", style: TextStyle(color: Colors.white70)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: _isBluetoothConnected ? _disconnectBluetooth : null,
                        child: const Text("Disconnect", style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_devicesList.isNotEmpty)
                    Column(
                      children: [
                        const Text(
                          "Available Devices:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ..._devicesList.map((device) => ListTile(
                              title: Text(
                                device.name ?? device.address,
                                style: TextStyle(color: Colors.white70),
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  side: BorderSide(color: Colors.green),
                                ),
                                onPressed: () => _connectToDevice(device),
                                child: const Text("Connect", style: TextStyle(color: Colors.white70)),
                              ),
                            )),
                      ],
                    ),
                  if (_isBluetoothConnected)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Connected to: ${_selectedDevice!.name ?? _selectedDevice!.address}",
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 20),
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
                    activeColor: Colors.green,
                    inactiveColor: const Color.fromARGB(50, 0, 0, 0),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => toggleModule("clock", true),
                        child: const Icon(Icons.timer_outlined, color: Colors.white70,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => toggleModule("clock", false),
                        child: const Icon(Icons.timer_off_outlined, color: Colors.white70,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => refreshModule("clock"),
                        child: const Icon(Icons.refresh, color: Colors.white70,),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => toggleModule("calendar", true),
                        child: const Icon(Icons.calendar_month_outlined, color: Colors.white70,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => toggleModule("calendar", false),
                        child: const Icon(
                          Icons.signal_cellular_no_sim_outlined,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => refreshModule("calendar"),
                        child: const Icon(Icons.refresh, color: Colors.white70,),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => toggleModule("weather", true),
                        child: Icon(Icons.cloud_outlined, color: Colors.white70,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => toggleModule("weather", false),
                        child: const Icon(Icons.cloud_off_outlined, color: Colors.white70,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => refreshModule("weather"),
                        child: const Icon(Icons.refresh, color: Colors.white70,),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: showMirrorIP,
                        child: const Icon(Icons.link_sharp, color: Colors.white70,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: hideMirrorIP,
                        child: const Icon(Icons.link_off_sharp, color: Colors.white70,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => refreshModule("MMM-Remote-Control"),
                        child: const Icon(Icons.refresh, color: Colors.white70,),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: showDietMeals,
                        child: const Icon(Icons.fastfood_outlined, color: Colors.white70,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: hideDietMeals,
                        child: const Icon(Icons.no_food_outlined, color: Colors.white70,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => refreshModule("MMM-FirebaseBridge"),
                        child: const Icon(Icons.refresh, color: Colors.white70,),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => toggleAllModules(true),
                        child: const Text("Show All Modules", style: TextStyle(color: Colors.white70,),),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => toggleAllModules(false),
                        child: const Text("Hide All Modules", style: TextStyle(color: Colors.white70,),),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: Colors.green),
                    ),
                    onPressed: restartMagicMirror,
                    child: const Text("Restart Magic Mirror", style: TextStyle(color: Colors.white70),),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: Colors.green),
                    ),
                    onPressed: reloadMagicMirror,
                    child: const Text("Reload Magic Mirror", style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: Colors.green),
                    ),
                    onPressed: minimizeMagicMirror,
                    child: const Text("Minimize Magic Mirror", style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(0, 198, 74, 65),
                      side: BorderSide(
                        color: Colors.green,
                      ),
                    ),
                    onPressed: shutdownMagicMirror,
                    child: const Text(
                      "Shutdown Magic Mirror",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
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
                      side: BorderSide(
                        color: Colors.green,
                      ),
                    ),
                    child: const Icon(Icons.color_lens_outlined, color: Colors.white70,),
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
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? "Please enter a URL"
                            : null,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: Colors.green,
                      ),
                    ),
                    onPressed: playVideo,
                    child: const Text("Play Video", style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Colors.green,
                          ),
                        ),
                        onPressed: minimizeVideo,
                        child: const Icon(Icons.minimize, color: Colors.white70,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Colors.green,
                          ),
                        ),
                        onPressed: maximizeVideo,
                        child: const Icon(Icons.fullscreen, color: Colors.white70,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Colors.green,
                          ),
                        ),
                        onPressed: closeVideo,
                        child: const Icon(Icons.close, color: Colors.white70,),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Colors.green,
                          ),
                        ),
                        onPressed: decreaseVolume,
                        child: const Icon(Icons.volume_down, color: Colors.white70,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Colors.green,
                          ),
                        ),
                        onPressed: increaseVolume,
                        child: const Icon(Icons.volume_up, color: Colors.white70,),
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

  @override
  void dispose() {
    _connection?.close();
    super.dispose();
  }
}