import 'package:get/get.dart';
import 'package:jinsei/fitness_app/ui_view/medicine_dosage.dart';
import 'package:jinsei/fitness_app/ui_view/title_view.dart';
import 'package:jinsei/fitness_app/fitness_app_theme.dart';
import 'package:jinsei/fitness_app/my_diary/meals_list_view.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:jinsei/main.dart';
import 'dart:convert';

class MyDiaryScreen extends StatefulWidget {
  const MyDiaryScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  State<MyDiaryScreen> createState() => _MyDiaryScreenState();
}

class _MyDiaryScreenState extends State<MyDiaryScreen>
    with TickerProviderStateMixin {
  List<Widget> listViews = <Widget>[];
  double topBarOpacity = 0.0;
  Map<String, dynamic> cookie = {};

  int calculateTimeDifference(TimeOfDay startTime, TimeOfDay endTime) {
    int startMinutes = startTime.hour * 60 + startTime.minute;
    int endMinutes = endTime.hour * 60 + endTime.minute;

    int difference = endMinutes - startMinutes;
    if (difference < 0) {
      difference += 24 *
          60; // Add 24 hours in minutes if the end time is before the start time
    }

    return difference;
  }

  Map<String, dynamic> nextMedication(Map<String, dynamic> schedule) {
    String medicationname = schedule['name'];
    TimeOfDay? nextmedication = TimeOfDay.now();
    dynamic userschedule = cookie['userdata']['mealschedule'];
    if (schedule['mealbased'] is Map) {
      Map<String, dynamic> medicationschedule = Map.from(schedule['mealbased']);
      medicationschedule.forEach((key, value) {
        if (medicationschedule[key] != null) {
          medicationschedule[key] = TimeOfDay(
              hour: int.parse(userschedule[key].substring(0, 2)),
              minute: int.parse(userschedule[key].substring(3, 5)));
        }
      });
      nextmedication = TimeOfDay(
          hour: int.parse(userschedule["breakfast"].substring(0, 2)),
          minute: int.parse(userschedule["breakfast"].substring(3, 5)));
      medicationschedule.forEach((key, value) {
        if (medicationschedule[key] != null) {
          if (calculateTimeDifference(TimeOfDay.now(), value) <
              calculateTimeDifference(TimeOfDay.now(), nextmedication!)) {
            nextmedication = value;
          }
        }
      });
    }
    if (schedule['timebased'] is List) {
      var times = schedule['timebased']
          .map((e) => TimeOfDay(
              hour: int.parse(e.substring(0, 2)),
              minute: int.parse(e.substring(3, 5))))
          .toList();
      nextmedication = times[0];
      for (var time in times) {
        if (calculateTimeDifference(TimeOfDay.now(), time) <
            calculateTimeDifference(TimeOfDay.now(), nextmedication!)) {
          nextmedication = time;
        }
      }
    }
    return {
      'name': medicationname,
      "time": nextmedication,
    };
  }

  bool upcomingToday(dynamic schedule) {
    Map<String, dynamic> nextmedication = nextMedication(schedule);
    int timedifference =
        calculateTimeDifference(TimeOfDay.now(), nextmedication['time']);
    int timeTillEndOfDay = calculateTimeDifference(
        TimeOfDay.now(), const TimeOfDay(hour: 24, minute: 00));
    return timedifference < timeTillEndOfDay;
  }

  bool scheduleHasNextMealAt(Map<String, dynamic> schedule, TimeOfDay time) {
    dynamic userschedule = cookie['userdata']['mealschedule'];
    List<bool> returnval = [];
    if (schedule['mealbased'] is Map) {
      Map<String, dynamic> medicationschedule = Map.from(schedule['mealbased']);
      medicationschedule.forEach((key, value) {
        if (medicationschedule[key] != null) {
          medicationschedule[key] = TimeOfDay(
              hour: int.parse(userschedule[key].substring(0, 2)),
              minute: int.parse(userschedule[key].substring(3, 5)));
          returnval
              .add(calculateTimeDifference(medicationschedule[key], time) == 0);
        }
      });
    }
    if (schedule['timebased'] is List) {
      var times = schedule['timebased'];
    }
    return returnval.contains(true);
  }

  void addDataToListView(Map<String, dynamic>? data) {
    List<dynamic> medicationdetails = data!['medications'];
    List<dynamic> medications =
        medicationdetails.map((e) => e['medication']).toList();
    List<dynamic> upcomingMedications = <dynamic>[];
    for (int i = 0; i < medications.length; i++) {
      medications[i].sort((a, b) {
        Map<String, dynamic> nextmedicationA = nextMedication(a);
        Map<String, dynamic> nextmedicationB = nextMedication(b);
        TimeOfDay timeOfDayA = nextmedicationA['time'];
        TimeOfDay timeOfDayB = nextmedicationB['time'];
        return calculateTimeDifference(TimeOfDay.now(), timeOfDayA)
            .compareTo(calculateTimeDifference(TimeOfDay.now(), timeOfDayB));
      });
      for (var medication in medications[i]) {
        upcomingMedications.add(medication);
      }
    }
    upcomingMedications.sort((a, b) {
      Map<String, dynamic> nextmedicationA = nextMedication(a);
      Map<String, dynamic> nextmedicationB = nextMedication(b);
      TimeOfDay timeOfDayA = nextmedicationA['time'];
      TimeOfDay timeOfDayB = nextmedicationB['time'];
      return calculateTimeDifference(TimeOfDay.now(), timeOfDayA)
          .compareTo(calculateTimeDifference(TimeOfDay.now(), timeOfDayB));
    });
    TimeOfDay upcomingTime = nextMedication(upcomingMedications[0])['time'];
    upcomingMedications = upcomingMedications.where((medication) {
      Map<String, dynamic> nextmedication = nextMedication(medication);
      TimeOfDay timeOfMedication = nextmedication['time'];
      return calculateTimeDifference(upcomingTime, timeOfMedication) == 0;
    }).toList();
    listViews.add(
      MedicineDosage(
        nextMedicationTime: upcomingTime,
        upcomingMedications: upcomingMedications,
        animation: Tween<double>(begin: 10.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(
              (1 / medications.length) * 1,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        animationController: widget.animationController!,
      ),
    );
    listViews.add(
      TitleView(
        titleTxt: 'All Prescription',
      ),
    );
    for (int i = 0; i < medications.length; i++) {
      listViews.add(
        MealsListView(
          prescription: medications[i],
          mainScreenAnimation: Tween<double>(begin: 1.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController!,
                  curve: Interval((1 / listViews.length) * 3, 1.0,
                      curve: Curves.fastOutSlowIn))),
          mainScreenAnimationController: widget.animationController,
        ),
      );
    }
  }

  @override
  void initState() {
    getCookie().then((value) {
      setState(() {
        cookie = value;
      });
    });
    addAllListData();
    super.initState();
  }

  void addAllListData() {
    const int count = 10;

    listViews.add(
      TitleView(
        titleTxt: 'Upcoming Medications',
      ),
    );
  }

  Future<Map<String, dynamic>> getData() async {
    Dio dio = Dio();
    final response = await dio.get(
      '$url/medication',
      queryParameters: {
        'id': cookie['userdata']['id'],
        'isdoctor': cookie['userdata']['isdoctor'],
      },
    );
    return response.data;
  }

  @override
  Widget build(BuildContext context) {
    if (cookie.isEmpty) {
      return const CircularProgressIndicator();
    }
    listViews = <Widget>[];
    addAllListData();
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            FutureBuilder<Map<String, dynamic>>(
              future: getData(),
              builder: (BuildContext context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                } else {
                  addDataToListView(snapshot.data);
                  return Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 70),
                    child: ListView.builder(
                      itemCount: listViews.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        widget.animationController?.forward();
                        return listViews[index];
                      },
                    ),
                  );
                }
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<Map<String, dynamic>>(
      future: getData(),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              addDataToListView(snapshot.data);
              return listViews[index];
            },
          );
        }
      },
    );
  }
}
