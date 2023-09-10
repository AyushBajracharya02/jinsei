import 'package:jinsei/fitness_app/models/tabIcon_data.dart';
import 'package:jinsei/fitness_app/training/training_screen.dart';
import 'package:flutter/material.dart';
import 'package:jinsei/fitness_app/user_profile.dart';
import 'package:jinsei/new_appointment.dart';
import 'bottom_navigation_view/bottom_bar_view.dart';
import 'fitness_app_theme.dart';
import 'my_diary/my_diary_screen.dart';
import 'package:dio/dio.dart';
import 'package:jinsei/main.dart';
import 'appoinments.dart';

class FitnessAppHomeScreen extends StatefulWidget {
  const FitnessAppHomeScreen({super.key});

  @override
  State<FitnessAppHomeScreen> createState() => _FitnessAppHomeScreenState();
}

class _FitnessAppHomeScreenState extends State<FitnessAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  Widget tabBody = Container(
    color: FitnessAppTheme.background,
  );

  String pageText = "Your Prescriptions";
  Map<String, dynamic> cookie = {};

  @override
  void initState() {
    getCookie().then((value) {
      setState(() {
        cookie = value;
      });
    });
    for (TabIconData tab in tabIconsList) {
      tab.isSelected = false;
    }
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = MyDiaryScreen(animationController: animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  Future<List<dynamic>> getDoctors() async {
    Dio dio = Dio();
    final response = await dio.get("$url/doctors");
    Map<String, dynamic> responseData = response.data;
    return responseData['doctors'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        appBar: AppBar(
          title: Text(pageText),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          foregroundColor: Colors.black,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody,
                  bottomBar(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          changeIndex: (int index) async {
            if (index == 0) {
              animationController?.reverse().then<dynamic>(
                (data) {
                  if (!mounted) {
                    return;
                  }
                  setState(
                    () {
                      tabBody = MyDiaryScreen(
                          animationController: animationController);
                      pageText = "Your Prescriptions";
                    },
                  );
                },
              );
            }
            if (index == 1) {
              animationController?.reverse().then<dynamic>(
                (data) {
                  if (!mounted) {
                    return;
                  }
                  setState(
                    () {
                      tabBody = TrainingScreen(
                          animationController: animationController);
                      pageText = "Medical History";
                    },
                  );
                },
              );
            }
            if (index == 2) {
              animationController?.reverse().then<dynamic>(
                (data) {
                  if (!mounted) {
                    return;
                  }
                  setState(
                    () {
                      tabBody = const Appointments();
                      pageText = "Upcoming Appointments";
                    },
                  );
                },
              );
            }
            if (index == 3) {
              animationController?.reverse().then<dynamic>(
                (data) {
                  if (!mounted) {
                    return;
                  }
                  setState(
                    () {
                      tabBody = UserProfileContainer();
                      pageText =
                          "${cookie['userdata']['firstname']} ${cookie['userdata']['lastname']}'s Profile";
                    },
                  );
                },
              );
            }
            if (index == 4) {
              animationController?.reverse().then<dynamic>(
                (data) {
                  if (!mounted) {
                    return;
                  }
                  getDoctors().then((doctors) {
                    setState(
                      () {
                        tabBody = Appointment(doctordescriptions: doctors);
                        pageText = "Book an Appointment";
                      },
                    );
                  });
                },
              );
            }
          },
        ),
      ],
    );
  }
}
