import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DateWeather extends StatefulWidget {
  const DateWeather({super.key});

  @override
  State<DateWeather> createState() => _DateWeatherState();
}

class _DateWeatherState extends State<DateWeather> {
  String? _currentDate;
  String? _currentWeather;
  String? _temperature;
  String _cityName = "Loading...";
  
  final String apiKey = 'e3cb3437d76d3bf7bbb3457583a0c8b9'; // Replace with your actual API key
  final String cityName = 'Cairo'; // Change to any city of your choice

  @override
  void initState() {
    super.initState();
    _getCurrentDate();
    _fetchWeatherData();
    _fetchCity();
  }

   // Get the current date and format it
  void _getCurrentDate() {
    DateTime now = DateTime.now();
    setState(() {
      _currentDate = DateFormat('yMMMMd').format(now); // Example: December 27, 2024
    });
  }

  Future<String> getUserCityByIP() async {
  final response = await http.get(Uri.parse('http://ip-api.com/json/'));
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['city'] ?? 'Unknown';
  } else {
    throw Exception('Failed to load location data');
  }
}

  Future<void> _fetchCity() async {
  try {
    String city = await getUserCityByIP();
    setState(() {
      _cityName = city;
    });
    //await _fetchWeatherData(city);
  } catch (e) {
    print("Error fetching city: $e");
    setState(() {
      _cityName = "Cairo";
    });
    //await _fetchWeatherData("Cairo");
  }
}
  Future<void> _fetchWeatherData() async {
  try {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      // Parse the JSON data
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _currentWeather = data['weather'][0]['description'];
        _temperature = data['main']['temp'].toString();
      });
    } else {
      print('Failed to load weather data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching weather data: $e');
  }
}

  @override
  Widget build(context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 35.0),
          child: Row(
            children: [
              Text("Date", style: TextStyle(color: Colors.white, fontSize: 15)),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.4, right: 8.0),
                // child: Text (
                //   "${getCity()}",
                //   style: TextStyle(color: Colors.white, fontSize: 15),
                // ),
                child: Text(
              _currentDate != null ? '$_cityName' : 'Loading City...',
              style: TextStyle(color: Colors.white, fontSize: 16,),
            ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Text(
              _currentDate != null ? '$_currentDate' : 'Loading date...',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                  _temperature != null ? '$_temperature°C' : 'Loading temperature...',
                  style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.25,
                        child: Text(
                          _currentWeather != null ? '$_currentWeather' : 'Loading weather...',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
