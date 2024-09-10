import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppleHealthUsingMethodChannel extends StatefulWidget {
  const AppleHealthUsingMethodChannel({super.key});

  @override
  State<AppleHealthUsingMethodChannel> createState() =>
      _AppleHealthUsingMethodChannelState();
}

class _AppleHealthUsingMethodChannelState
    extends State<AppleHealthUsingMethodChannel> {
  static const MethodChannel _platform = MethodChannel('com.apple_health_poc');
  Map<Object, Object>? _healthData;

  // Method to request health data authorization
  static Future<void> _requestAuthorization() async {
    try {
      final String result =
          await _platform.invokeMethod('requestAuthorization');
      debugPrint(result); // Should print "Authorization granted"
    } on PlatformException catch (e) {
      debugPrint("Failed to request authorization: '${e.message}'.");
    }
  }

  // Fetching health data
  Future<void> _getHealthData() async {
    Map<Object, Object>? healthData;
    try {
      final result = await _platform.invokeMethod<Map<dynamic, dynamic>>(
        'fetchHealthData',
        <String, String>{'dataType': 'steps'},
      );
      // Casting from dynamic to Object
      if (result != null) {
        healthData = Map<Object, Object>.from(result);
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to get health data: ${e.message}');
    }

    setState(() {
      _healthData = healthData;
    });
  }

  @override
  void initState() {
    _initializeHealthData();
    super.initState();
  }

  Future<void> _initializeHealthData() async {
    await _requestAuthorization();
    await _getHealthData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            _healthData.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w200,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class HealthDataFetcher {
  static const MethodChannel _channel = MethodChannel('com.apple_health_poc');

  // Request authorization
  static Future<void> requestAuthorization() async {
    try {
      final result = await _channel.invokeMethod('requestAuthorization');
      debugPrint('Authorization result: $result');
    } on PlatformException catch (e) {
      debugPrint('Error in requesting authorization: ${e.message}');
    }
  }

  // Fetch health data
  static Future<void> fetchHealthData(String dataType) async {
    try {
      final result = await _channel.invokeMethod(
          'fetchHealthData', <String, String>{'dataType': dataType});
      debugPrint('Health data: $result');
    } on PlatformException catch (e) {
      debugPrint('Error fetching health data: ${e.message}');
    }
  }
}
