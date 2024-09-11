import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
      final Map<dynamic, dynamic>? result =
          await _platform.invokeMethod<Map<dynamic, dynamic>>(
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

  String getDate(final String? date) {
    if (date == null) {
      return 'Null';
    }
    final DateTime convertedDate = DateTime.parse(date);
    final DateFormat format = DateFormat('dd-MM-yyyy');

    return format.format(convertedDate);
  }

  String getDateAndTime(final String? date) {
    if (date == null) {
      return 'Null';
    }
    final DateTime convertedDate = DateTime.parse(date).toLocal();
    final DateFormat format = DateFormat('dd/MM - hh:mm a');
    return format.format(convertedDate);
  }

  // Method to build the health data into a ListView
  Widget _buildHealthDataList() {
    if (_healthData == null) {
      return const Center(child: Text('Fetching health data...'));
    }

    final List<Widget> healthWidgets = <Widget>[
      const SizedBox(height: 50),
    ];

    // Iterate through each health data type and build a list
    _healthData!.forEach((Object key, dynamic value) {
      final List<dynamic> dataList = value as List<dynamic>;

      healthWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            key.toString().toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );

      for (final dynamic data in dataList) {
        healthWidgets.add(
          ListTile(
            title: Text(
              'Value: ${data[key.toString() == 'sleep' ? 'state' : 'value']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            subtitle: Text(
              key.toString() == 'sleep'
                  ? '${getDateAndTime(data['startDate'])} - ${getDateAndTime(data['endDate'])}'
                  : 'Date: ${getDate(data['date'] ?? '')}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    });

    return ListView(
      padding: const EdgeInsets.all(32.0),
      children: healthWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _buildHealthDataList(),
        backgroundColor: Colors.black,
      ),
    );
  }
}
