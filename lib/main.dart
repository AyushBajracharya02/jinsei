import 'package:flutter/material.dart';
import 'package:jinsei/home.dart';
import './introduction_animation/introduction_animation_screen.dart';
import "package:shared_preferences/shared_preferences.dart";
import "dart:convert";
import 'fitness_app/fitness_app_home_screen.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:isolate';

const String url = "http://192.168.0.107:8000";

@pragma('vm:entry-point')
void printHello() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=${isolateId} function='$printHello'");
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  final Map<String, dynamic> cookie = await getCookie();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool? skipIntro = prefs.getBool("skipIntro");
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Roboto",
      ),
      home: cookie['access']
          ? const FitnessAppHomeScreen()
          : skipIntro == null
              ? const IntroductionAnimationScreen()
              : const Home(initialPage: 0),
    ),
  );
  final int helloAlarmID = 0;
  await AndroidAlarmManager.periodic(const Duration(minutes: 1), helloAlarmID, printHello);
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}

class SortWidget extends StatefulWidget {
  const SortWidget({super.key, required this.sort});
  final Function(String) sort;
  @override
  State<SortWidget> createState() => _SortWidgetState();
}

class _SortWidgetState extends State<SortWidget> {
  String selectedSortOption = 'Date';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedSortOption,
      onChanged: (String? newValue) {
        setState(() {
          selectedSortOption = newValue!;
        });
        widget.sort(newValue!);
      },
      items: <String>['Date', 'Name']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

String sexFullForm(String? sex) {
  return sex == null
      ? "Not Added"
      : sex == "M"
          ? "Male"
          : sex == "F"
              ? "Female"
              : "Other";
}

void setCookie(Map<String, dynamic> data) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String dataString = jsonEncode(data);
  await prefs.setString("cookie", dataString);
}

Future<Map<String, dynamic>> getCookie() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? cookieString = prefs.getString("cookie");
  if (cookieString == null) {
    return {"access": false};
  }
  return jsonDecode(cookieString);
}
