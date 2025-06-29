import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // For base64 encoding
import 'package:image/image.dart' as img; // For image compression

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
  final TextEditingController wifiSsidController = TextEditingController();
  final TextEditingController wifiPasswordController = TextEditingController();

  double brightnessValue = 100;
  Color _currentColor = Colors.transparent;
  bool qrCode = false;
  String? _selectedImageBase64;

  final ImagePicker _picker = ImagePicker();

  Future<void> sendCommand(
    String action, {
    Map<String, dynamic>? payload,
    bool useSetupIp = false,
  }) async {
    String ip = useSetupIp ? '192.168.4.1' : ipController.text.trim();
    if (ip.isEmpty && !useSetupIp) {
      _showSnackBar("Please enter a valid IP address");
      return;
    }

    final url = Uri.parse('http://$ip:8080/remote');
    try {
      if (action == "CHANGE_BACKGROUND_IMAGE" && payload?["image"] != null) {
        // Use POST for image data
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'action': action, 'image': payload!['image']}),
            )
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          _showSnackBar("Background image sent successfully! (Check Mirror)");
          print("Response body: ${response.body}"); // Debug log
        } else {
          _showSnackBar(
            "Failed: ${response.statusCode} - ${response.reasonPhrase} - ${response.body}",
          );
          print("Error response: ${response.body}"); // Debug log
        }
      } else {
        // Use GET for other commands
        final queryParams = {
          "action": action,
          ...?payload?.map((key, value) => MapEntry(key, value.toString())),
        };
        final response = await http
            .get(url.replace(queryParameters: queryParams))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          _showSnackBar("Command '$action' sent successfully!");
          if (action == "CONFIGURE_WIFI" && useSetupIp) {
            _showSnackBar(
              "Wi-Fi configuration sent. Please reconnect to your Wi-Fi network and update the IP address.",
            );
          }
        } else {
          _showSnackBar(
            "Failed: ${response.statusCode} - ${response.reasonPhrase} - ${response.body}",
          );
        }
      }
    } catch (e) {
      _showSnackBar("Error: $e");
      print("Exception: $e"); // Debug log
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 1),
        backgroundColor: const Color.fromARGB(110, 76, 175, 79),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
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

  void hideSkinAnalysis() {
    toggleModule("MMM-SkinAnalysis", false);
  }

  void showSkinAnalysis() {
    toggleModule("MMM-SkinAnalysis", true);
  }

  void hideSkinAnalysisChart() {
    toggleModule("MMM-SkinAnalysisChart", false);
  }

  void showSkinAnalysisChart() {
    toggleModule("MMM-SkinAnalysisChart", true);
  }

  void hideQRScanner() {
    toggleModule("MMM-QRScanner", false);
  }

  void showQRScanner() {
    toggleModule("MMM-QRScanner", true);
  }

  void openBluetooth() {
    sendCommand("OPEN_BLUETOOTH");
  }

  void closeBluetooth() {
    sendCommand("CLOSE_BLUETOOTH");
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

  void stopVideo() {
    sendCommand("STOP_VIDEO");
  }

  void sendQCommand() {
    sendCommand("SEND_Q_COMMAND");
  }

  void startVideo() {
    final url = videoUrlController.text.trim();
    if (url.isEmpty) {
      _showSnackBar("Please enter a YouTube URL");
      return;
    }
    sendCommand("PLAY_VIDEO", payload: {"url": url});
  }

  void increaseVolume() {
    sendCommand("INCREASE_VOLUME");
  }

  void decreaseVolume() {
    sendCommand("DECREASE_VOLUME");
  }

  Future<void> changeBackgroundImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image != null) {
        // Compress image to reduce size (e.g., to 800px width)
        image = img.copyResize(image, width: 800);
        final compressedBytes = img.encodeJpg(image, quality: 85);
        final base64Image = base64Encode(compressedBytes);

        // Check size (limit to ~1MB to avoid issues)
        if (base64Image.length > 1000000) {
          _showSnackBar("Image too large. Please select a smaller image.");
          return;
        }

        sendCommand("CHANGE_BACKGROUND_IMAGE", payload: {"image": base64Image});
        setState(() {
          _selectedImageBase64 = base64Image;
        });
        _showSnackBar("Background image sent successfully!");
      } else {
        _showSnackBar("Failed to process image");
      }
    } else {
      _showSnackBar("No image selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        backgroundColor: const Color.fromARGB(175, 120, 137, 120),
        title: Text("Magic Mirror Control"),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(colors: [Colors.green, Colors.black87]),
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
                  // IP Address Input
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
                    "Hint: Find the IP in the bottom left of the mirror screen (phone and mirror must be on the same Wi-Fi).",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  // Wi-Fi Configuration Section
                  const Text(
                    "Wi-Fi Configuration",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: wifiSsidController,
                    decoration: const InputDecoration(
                      labelText: "Wi-Fi SSID",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      fillColor: Colors.white70,
                      filled: true,
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? "Please enter a Wi-Fi SSID"
                                : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: wifiPasswordController,
                    decoration: const InputDecoration(
                      labelText: "Wi-Fi Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      fillColor: Colors.white70,
                      filled: true,
                    ),
                    obscureText: true,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? "Please enter a Wi-Fi password"
                                : null,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: Colors.green),
                    ),
                    onPressed: () {
                      setState(() {
                        if (wifiSsidController.text.isNotEmpty &&
                            wifiPasswordController.text.isNotEmpty) {
                          qrCode = true;
                        } else {
                          _showSnackBar("Please enter SSID and Password!");
                        }
                      });
                    },
                    child: const Text(
                      "Generate Wi-Fi QRcode",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Generate QRcode for Wi-Fi
                  if (qrCode &&
                      wifiSsidController.text.isNotEmpty &&
                      wifiPasswordController.text.isNotEmpty)
                    Stack(
                      children: [
                        Center(
                          child: QrImageView(
                            data:
                                'WIFI:T:WPA;S:${wifiSsidController.text};P:${wifiPasswordController.text};;',
                            version: QrVersions.auto,
                            size: 200.0,
                            gapless: false,
                            backgroundColor: Colors.white,
                            errorStateBuilder: (cxt, err) {
                              return const Text(
                                'Error generating QR code',
                                style: TextStyle(color: Colors.red),
                              );
                            },
                          ),
                        ),
                      ],
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
                        child: const Icon(
                          Icons.timer_outlined,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => toggleModule("clock", false),
                        child: const Icon(
                          Icons.timer_off_outlined,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => refreshModule("clock"),
                        child: const Icon(Icons.refresh, color: Colors.white70),
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
                        child: const Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => toggleModule("calendar", false),
                        child: const Icon(
                          Icons.not_interested,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => refreshModule("calendar"),
                        child: const Icon(Icons.refresh, color: Colors.white70),
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
                        child: Icon(
                          Icons.cloud_outlined,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => toggleModule("weather", false),
                        child: const Icon(
                          Icons.cloud_off_outlined,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => refreshModule("weather"),
                        child: const Icon(Icons.refresh, color: Colors.white70),
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
                        child: const Icon(
                          Icons.link_sharp,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: hideMirrorIP,
                        child: const Icon(
                          Icons.link_off_sharp,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => refreshModule("MMM-Remote-Control"),
                        child: const Icon(Icons.refresh, color: Colors.white70),
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
                        child: const Icon(
                          Icons.fastfood_outlined,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: hideDietMeals,
                        child: const Icon(
                          Icons.no_food_outlined,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => refreshModule("MMM-FirebaseBridge"),
                        child: const Icon(Icons.refresh, color: Colors.white70),
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
                        onPressed: showSkinAnalysis,
                        child: const Icon(Icons.face, color: Colors.white70),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: hideSkinAnalysis,
                        child: const Icon(
                          Icons.face_retouching_off,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => refreshModule("MMM-SkinAnalysis"),
                        child: const Icon(Icons.refresh, color: Colors.white70),
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
                        onPressed: showSkinAnalysisChart,
                        child: const Icon(
                          Icons.analytics,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: hideSkinAnalysisChart,
                        child: const Icon(
                          Icons.not_interested_sharp,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => refreshModule("MMM-SkinAnalysisChart"),
                        child: const Icon(Icons.refresh, color: Colors.white70),
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
                        onPressed: showQRScanner,
                        child: const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: hideQRScanner,
                        child: const Icon(
                          Icons.not_interested_sharp,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => refreshModule("MMM-QRScanner"),
                        child: const Icon(Icons.refresh, color: Colors.white70),
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
                        child: const Text(
                          "Show All Modules",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: () => toggleAllModules(false),
                        child: const Text(
                          "Hide All Modules",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Bluetooth Control",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: openBluetooth,
                        child: const Icon(
                          Icons.bluetooth,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: closeBluetooth,
                        child: const Icon(
                          Icons.bluetooth_disabled,
                          color: Colors.white70,
                        ),
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
                    child: const Text(
                      "Restart Magic Mirror",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: Colors.green),
                    ),
                    onPressed: reloadMagicMirror,
                    child: const Text(
                      "Reload Magic Mirror",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: Colors.green),
                    ),
                    onPressed: minimizeMagicMirror,
                    child: const Text(
                      "Minimize Magic Mirror",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: Colors.green),
                    ),
                    onPressed: shutdownMagicMirror,
                    child: const Text(
                      "Shutdown Magic Mirror",
                      style: TextStyle(color: Colors.red),
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
                      side: BorderSide(color: Colors.green),
                    ),
                    child: const Icon(
                      Icons.color_lens_outlined,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Background Image Control",
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
                    onPressed: changeBackgroundImage,
                    child: const Text(
                      "Set Background Image",
                      style: TextStyle(color: Colors.white70),
                    ),
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
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: Colors.green),
                    ),
                    onPressed: playVideo,
                    child: const Text(
                      "Play Video",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Add this Row widget after the existing video control Row with minimize, maximize, close icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: stopVideo,
                        child: const Icon(
                          Icons.stop_circle_outlined,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: startVideo,
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white70,
                        ),
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
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: minimizeVideo,
                        child: const Icon(
                          Icons.minimize,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: maximizeVideo,
                        child: const Icon(
                          Icons.fullscreen,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: closeVideo,
                        child: const Icon(Icons.close, color: Colors.white70),
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
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: decreaseVolume,
                        child: const Icon(
                          Icons.volume_down,
                          color: Colors.white70,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: increaseVolume,
                        child: const Icon(
                          Icons.volume_up,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.green),
                        ),
                        onPressed: sendQCommand,
                        child: const Icon(Icons.wordpress, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
