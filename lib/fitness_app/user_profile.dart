import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jinsei/components/address.dart';
import 'package:jinsei/components/confirmpassword.dart';
import 'package:jinsei/components/name.dart';
import 'package:jinsei/components/password.dart';
import 'package:jinsei/components/phonenumber.dart';
import 'package:jinsei/components/price.dart';
import 'package:jinsei/controllers/editprofilecontroller.dart';
import 'package:jinsei/home.dart';
import 'package:jinsei/main.dart';
import 'package:jinsei/components/bloodgroup.dart';
import 'package:jinsei/components/dateofbirth.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

Color decideColor(dynamic field) {
  return field == null ? Colors.red : Colors.black;
}

class UserProfileContainer extends StatefulWidget {
  const UserProfileContainer({super.key});

  @override
  State<UserProfileContainer> createState() => UserProfileContainerState();
}

class UserProfileContainerState extends State<UserProfileContainer> {
  bool editProfile = false;
  String editOrDisplay = "Edit Details";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 150,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    gradient: LinearGradient(
                      colors: [Color(0xFF2633C5), Color(0xFF6A88E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (editProfile) {
                          editOrDisplay = "Edit Details";
                        } else {
                          editOrDisplay = "Display Details";
                        }
                        editProfile = !editProfile;
                      });
                    },
                    child: Text(
                      editOrDisplay,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: 150,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    gradient: LinearGradient(
                      colors: [Color(0xFF2633C5), Color(0xFF6A88E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: InkWell(
                    onTap: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      bool cookieDeleted = await prefs.remove("cookie");
                      if (cookieDeleted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Home(
                              initialPage: 1,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Log Out",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!editProfile) const UserProfile(),
            if (editProfile) const EditProfile(),
          ],
        ),
      ),
    );
  }
}

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, dynamic> cookie = {};

  @override
  void initState() {
    getCookie().then(
      (value) {
        setState(() {
          cookie = value;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (cookie.isEmpty) {
      return const CircularProgressIndicator();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: const IconTheme(
            data: IconThemeData(
              size: 180,
              // color: Colors.white,
            ),
            child: Icon(Icons.person),
          ),
        ),
        Container(
          height: 450,
          padding: const EdgeInsets.fromLTRB(60, 0, 40, 0),
          decoration: const BoxDecoration(),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name : ${cookie['userdata']['isdoctor'] ? "Dr." : ""} ${cookie["userdata"]["firstname"]} ${cookie["userdata"]["lastname"]}',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                "Contact: ${cookie['userdata']['phonenumber']}",
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                "Address: ${cookie['userdata']['address'] ?? "(blank)"}",
                style: TextStyle(
                  color: decideColor(cookie['userdata']['address']),
                  fontSize: 18,
                ),
              ),
              Text(
                "Age: ${cookie['userdata']['age'] ?? "(blank)"}",
                style: TextStyle(
                  color: decideColor(cookie['userdata']['age']),
                  fontSize: 18,
                ),
              ),
              Text(
                "Blood Group: ${cookie['userdata']['bloodgroup'] ?? "(blank)"}",
                style: TextStyle(
                  color: decideColor(cookie['userdata']['bloodgroup']),
                  fontSize: 18,
                ),
              ),
              Text(
                "Date of Birth: ${cookie['userdata']['date_of_birth'] ?? "(blank)"}",
                style: TextStyle(
                  color: decideColor(cookie['userdata']['date_of_birth']),
                  fontSize: 18,
                ),
              ),
              if (cookie['userdata']['isdoctor'])
                Text(
                  "Price: ${cookie['userdata']['price'] ?? "(blank)"}",
                  style: TextStyle(
                    color: decideColor(cookie['userdata']['price']),
                    fontSize: 18,
                  ),
                ),
              if (cookie['userdata']['isdoctor'])
                DoctorSchedule(
                  schedule: cookie['userdata']['schedule'],
                ),
              if (cookie['userdata']['mealschedule'].isNotEmpty)
                MealSchedule(schedule: cookie['userdata']['mealschedule'])
            ],
          ),
        ),
      ],
    );
  }
}

class MealSchedule extends StatelessWidget {
  final schedule;

  const MealSchedule({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 30,
          child: Text(
            "Mealschedule",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
        Table(
          children: [
            const TableRow(
              children: [
                SizedBox(
                  height: 30,
                  child: Text(
                    "Meals",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  "Time",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text(
                    "Breakfast",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  schedule['breakfast'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text(
                    "Lunch",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  schedule['lunch'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text(
                    "Dinner",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  schedule['dinner'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late EditProfileController controller;
  Map<String, dynamic> cookie = {};
  @override
  void initState() {
    getCookie().then((value) {
      setState(() {
        cookie = value;
      });
      controller = EditProfileController(initialdata: cookie['userdata']);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (cookie.isEmpty) {
      return const CircularProgressIndicator();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
      child: Column(
        children: [
          Name(
            controller: controller,
            hasError: false,
            initialfirstname: cookie['userdata']['firstname'],
            initiallastname: cookie['userdata']['lastname'],
          ),
          const SizedBox(height: 10),
          PhoneNumberForm(
            controller: controller,
            hasError: false,
            initialValue: cookie['userdata']['phonenumber'],
          ),
          const SizedBox(height: 10),
          PasswordForm(
            controller: controller,
            hasError: false,
            initialValue: cookie['userdata']['password'],
          ),
          const SizedBox(height: 10),
          ConfirmPasswordForm(
            controller: controller,
            hasError: false,
            initialValue: cookie['userdata']['password'],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DateOfBirth(
                controller: controller,
                initialValue: cookie['userdata']['date_of_birth'],
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: BloodGroup(
                  controller: controller,
                  initialValue: cookie['userdata']['bloodgroup'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Address(
            controller: controller,
            initialValue: cookie['userdata']['address'],
          ),
          const SizedBox(height: 10),
          MealScheduleEditor(
            controller: controller,
            schedule: cookie['userdata']['mealschedule'],
          ),
          const SizedBox(height: 10),
          if (cookie['userdata']['isdoctor'])
            Price(
              controller: controller,
              hasError: false,
              initialValue: cookie['userdata']['price'],
            ),
          const SizedBox(height: 10),
          if (cookie['userdata']['isdoctor'])
            ScheduleEditor(
              controller: controller,
              hasError: false,
              schedule: cookie['userdata']['schedule'],
            ),
          const SizedBox(height: 10),
          Container(
            height: 60,
            width: 200,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: Color.fromARGB(255, 37, 170, 42),
            ),
            padding: const EdgeInsets.all(5),
            child: Center(
              child: InkWell(
                onTap: () async {
                  if (controller.errors.isNotEmpty) {
                    return;
                  }
                  Dio dio = Dio();
                  var response = await dio.post(
                    "$url/updateuser/",
                    data: {
                      ...controller.getData(),
                      'id': cookie['userdata']['id'],
                      'isdoctor': cookie['userdata']['isdoctor'],
                    },
                  );
                  var responseData = response.data;
                  if (responseData['status']) {
                    Map<String, dynamic> userdata = cookie['userdata'];
                    userdata = {...userdata, ...controller.getData()};
                    print({...cookie, 'userdata': userdata});
                    setCookie({...cookie, 'userdata': userdata});
                    getCookie().then((value) {
                      setState(() {
                        cookie = value;
                      });
                    });
                  }
                },
                child: const Text(
                  'Update Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MealScheduleEditor extends StatefulWidget {
  Map<String, dynamic> schedule;
  final EditProfileController controller;
  MealScheduleEditor({
    super.key,
    required this.controller,
    required this.schedule,
  });

  @override
  State<MealScheduleEditor> createState() => _MealScheduleEditorState();
}

class _MealScheduleEditorState extends State<MealScheduleEditor> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 30,
          child: Text(
            "Mealschedule",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
        Table(
          children: [
            const TableRow(
              children: [
                SizedBox(
                  height: 30,
                  child: Text(
                    "Meals",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  "Time",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text(
                    "Breakfast",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setMealSchedule(
                        "breakfast",
                        formatMealScheduleTime(selectedTime!),
                      );
                    });
                  },
                  child: Text(
                    widget.controller.mealschedule.value!['breakfast'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text(
                    "Lunch",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setMealSchedule(
                        "lunch",
                        formatMealScheduleTime(selectedTime!),
                      );
                    });
                  },
                  child: Text(
                    widget.controller.mealschedule.value!['lunch'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text(
                    "Dinner",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setMealSchedule(
                        "dinner",
                        formatMealScheduleTime(selectedTime!),
                      );
                    });
                  },
                  child: Text(
                    widget.controller.mealschedule.value!['dinner'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class DoctorSchedule extends StatefulWidget {
  Map<String, dynamic>? schedule;
  Color? textcolor;
  DoctorSchedule({super.key, this.schedule, this.textcolor});

  @override
  State<DoctorSchedule> createState() => _DoctorScheduleState();
}

class _DoctorScheduleState extends State<DoctorSchedule> {
  Map<String, dynamic> cookie = {};

  @override
  void initState() {
    getCookie().then((value) {
      setState(() {
        cookie = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (cookie.isEmpty) {
      return const CircularProgressIndicator();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          height: 25,
          child: Text(
            "Schedule:",
            style: TextStyle(
              color: widget.textcolor ??
                  decideColor(cookie['userdata']['schedule']),
              fontSize: 18,
            ),
          ),
        ),
        Table(
          children: [
            TableRow(
              children: [
                Text(
                  "Days",
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.textcolor ?? Colors.black,
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Text(
                    "Start Time",
                    style: TextStyle(
                      fontSize: 18,
                      color: widget.textcolor ?? Colors.black,
                    ),
                  ),
                ),
                Text(
                  "End Time",
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.textcolor ?? Colors.black,
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                SizedBox(
                  height: 30,
                  child: Text(
                    "Sunday",
                    style: TextStyle(
                      fontSize: 18,
                      color: widget.textcolor ?? Colors.black,
                    ),
                  ),
                ),
                Text(
                  widget.schedule == null
                      ? "TBA"
                      : widget.schedule!['Sunday']['start_time'],
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.textcolor ?? Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  widget.schedule == null
                      ? "TBA"
                      : widget.schedule!['Sunday']['end_time'],
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.textcolor ?? Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            TableRow(
              children: [
                SizedBox(
                  height: 30,
                  child: Text(
                    "Monday",
                    style: TextStyle(
                      fontSize: 18,
                      color: widget.textcolor ?? Colors.black,
                    ),
                  ),
                ),
                Text(
                  widget.schedule == null
                      ? "TBA"
                      : widget.schedule!['Monday']['start_time'],
                  style: TextStyle(
                    color: widget.textcolor ?? Colors.black,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  widget.schedule == null
                      ? "TBA"
                      : widget.schedule!['Monday']['end_time'],
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.textcolor ?? Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            TableRow(
              children: [
                Text(
                  "Tuesday",
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.textcolor ?? Colors.black,
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.schedule!['Tuesday']['start_time'],
                    style: TextStyle(
                      color: widget.textcolor ?? Colors.black,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  widget.schedule == null
                      ? "TBA"
                      : widget.schedule!['Tuesday']['end_time'],
                  style: TextStyle(
                    color: widget.textcolor ?? Colors.black,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            TableRow(
              children: [
                Text(
                  "Wednesday",
                  style: TextStyle(
                    color: widget.textcolor ?? Colors.black,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.schedule!['Wednesday']['start_time'],
                    style: TextStyle(
                      fontSize: 18,
                      color: widget.textcolor ?? Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  widget.schedule == null
                      ? "TBA"
                      : widget.schedule!['Wednesday']['end_time'],
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.textcolor ?? Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            TableRow(
              children: [
                Text(
                  "Thursday",
                  style: TextStyle(
                    color: widget.textcolor ?? Colors.black,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.schedule!['Thursday']['start_time'],
                    style: TextStyle(
                      color: widget.textcolor ?? Colors.black,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  widget.schedule == null
                      ? "TBA"
                      : widget.schedule!['Thursday']['end_time'],
                  style: TextStyle(
                    color: widget.textcolor ?? Colors.black,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            TableRow(
              children: [
                Text(
                  "Friday",
                  style: TextStyle(
                    color: widget.textcolor ?? Colors.black,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.schedule!['Friday']['start_time'],
                    style: TextStyle(
                      fontSize: 18,
                      color: widget.textcolor ?? Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  widget.schedule == null
                      ? "TBA"
                      : widget.schedule!['Friday']['end_time'],
                  style: TextStyle(
                    color: widget.textcolor ?? Colors.black,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            TableRow(
              children: [
                Text(
                  "Saturday",
                  style: TextStyle(
                    color: widget.textcolor ?? Colors.black,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.schedule!['Saturday']['start_time'],
                    style: TextStyle(
                      color: widget.textcolor ?? Colors.black,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  widget.schedule == null
                      ? "TBA"
                      : widget.schedule!['Saturday']['end_time'],
                  style: TextStyle(
                    color: widget.textcolor ?? Colors.black,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ScheduleEditor extends StatefulWidget {
  bool hasError;
  Map<String, dynamic>? schedule;
  EditProfileController controller;
  ScheduleEditor({
    super.key,
    required this.controller,
    required this.hasError,
    this.schedule,
  });

  @override
  State<ScheduleEditor> createState() => _ScheduleEditorState();
}

class _ScheduleEditorState extends State<ScheduleEditor> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          height: 25,
          child: const Text(
            "Schedule:",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        Table(
          children: [
            const TableRow(
              children: [
                Text(
                  "Days",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Text(
                    "Start Time",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  "End Time",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text(
                    "Sunday",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setSchedule("Sunday", "start_time",
                          formatTimeOfDay(selectedTime!));
                    });
                  },
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.controller.schedule.value!['Sunday']
                            ['start_time'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setSchedule(
                          "Sunday", "end_time", formatTimeOfDay(selectedTime!));
                    });
                  },
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.controller.schedule.value!['Sunday']
                            ['end_time'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text(
                    "Monday",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setSchedule("Monday", "start_time",
                          formatTimeOfDay(selectedTime!));
                    });
                  },
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.controller.schedule.value!['Monday']
                            ['start_time'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setSchedule(
                          "Monday", "end_time", formatTimeOfDay(selectedTime!));
                    });
                  },
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.controller.schedule.value!['Monday']
                            ['end_time'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text(
                    "Tuesday",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setSchedule("Tuesday", "start_time",
                          formatTimeOfDay(selectedTime!));
                    });
                  },
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.controller.schedule.value!['Tuesday']
                            ['start_time'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setSchedule("Tuesday", "end_time",
                          formatTimeOfDay(selectedTime!));
                    });
                  },
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.controller.schedule.value!['Tuesday']
                            ['end_time'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text(
                    "Wednesday",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setSchedule("Wednesday", "start_time",
                          formatTimeOfDay(selectedTime!));
                    });
                  },
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.controller.schedule.value!['Wednesday']
                            ['start_time'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setSchedule("Wednesday", "end_time",
                          formatTimeOfDay(selectedTime!));
                    });
                  },
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.controller.schedule.value!['Wednesday']
                            ['end_time'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text(
                    "Thursday",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setSchedule("Thursday", "start_time",
                          formatTimeOfDay(selectedTime!));
                    });
                  },
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.controller.schedule.value!['Thursday']
                            ['start_time'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setSchedule("Thursday", "end_time",
                          formatTimeOfDay(selectedTime!));
                    });
                  },
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.controller.schedule.value!['Thursday']
                            ['end_time'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text(
                    "Friday",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setSchedule("Friday", "start_time",
                          formatTimeOfDay(selectedTime!));
                    });
                  },
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.controller.schedule.value!['Friday']
                            ['start_time'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setSchedule(
                          "Friday", "end_time", formatTimeOfDay(selectedTime!));
                    });
                  },
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.controller.schedule.value!['Friday']
                            ['end_time'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text(
                    "Saturday",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setSchedule("Saturday", "start_time",
                          formatTimeOfDay(selectedTime!));
                    });
                  },
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.controller.schedule.value!['Saturday']
                            ['start_time'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      widget.controller.setSchedule("Saturday", "end_time",
                          formatTimeOfDay(selectedTime!));
                    });
                  },
                  child: Text(
                    widget.schedule == null
                        ? "TBA"
                        : widget.controller.schedule.value!['Saturday']
                            ['end_time'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

String formatTimeOfDay(TimeOfDay time) {
  final now = DateTime.now();
  final dateTime =
      DateTime(now.year, now.month, now.day, time.hour, time.minute);
  final formatter = DateFormat.jm(); // 'jm' formats as 'hh:mm a'
  return formatter.format(dateTime);
}

String formatMealScheduleTime(TimeOfDay time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}
