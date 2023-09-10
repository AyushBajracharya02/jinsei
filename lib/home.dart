import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'signup.dart';

class Home extends StatefulWidget {
  const Home({super.key,required this.initialPage});
  final int initialPage;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late PageController pageController;

  Future<void> setSkipIntro() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("skipIntro", true);
  }

  @override
  void initState() {
    setSkipIntro().then((value) {
      print("Skip animation Value set");
    },);
    super.initState();
    pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      children: [
        SignUpPage(),
        LoginPage(),
      ],
    );
  }
}