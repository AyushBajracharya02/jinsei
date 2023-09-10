import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jinsei/controllers/appointmentslotcontroller.dart';
import 'package:jinsei/main.dart';
import 'fitness_app/user_profile.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

List<Widget> getSlots(
    List<dynamic> appointments, DateTime start, DateTime end, DateTime date) {
  List<Slot> slots = [];
  int index = 0;
  int slotindex = 0;
  Map<String, dynamic> appointmentdata;
  if (appointments.isEmpty) {
    for (DateTime startTime = start;
        startTime.isBefore(end);
        startTime = startTime.add(const Duration(minutes: 30))) {
      slots.add(
        Slot(
          appointmentinfo: const {},
          time: DateFormat("hh:mm a").format(startTime),
          index: slotindex++,
        ),
      );
    }
  } else {
    for (DateTime startTime = start;
        startTime.isBefore(end);
        startTime = startTime.add(const Duration(minutes: 30))) {
      if (DateTime.parse(
              '${DateFormat('yyyy-MM-dd').format(date)} ${militaryTime(appointments[index]['time'])}') ==
          startTime) {
        appointmentdata = appointments[index];
        if (index < appointments.length - 1) {
          index++;
        }
      } else {
        appointmentdata = {};
      }
      slots.add(
        Slot(
          appointmentinfo: appointmentdata,
          time: DateFormat("hh:mm a").format(startTime),
          index: slotindex++,
        ),
      );
    }
  }

  return slots;
}

String militaryTime(String timeString) {
  final RegExp militaryregExp =
      RegExp(r'^([0-1][0-9]|[2][0-3]):[0-5][0-9]:[0-5][0-9]$');
  if (militaryregExp.hasMatch(timeString)) {
    return timeString.substring(0, 5);
  }
  final RegExp regExp = RegExp(r'^(\d{1,2}):(\d{2})\s*(am|pm)$');
  final RegExpMatch? match = regExp.firstMatch(timeString);
  if (match == null) {
    throw FormatException('Invalid time format: $timeString');
  }
  final int hour = int.parse(match.group(1)!);
  final int minute = int.parse(match.group(2)!);
  final String period = match.group(3)!.toUpperCase();
  if (hour < 1 || hour > 12) {
    throw FormatException('Invalid hour: $hour');
  }
  if (minute < 0 || minute > 59) {
    throw FormatException('Invalid minute: $minute');
  }
  int militaryHour = hour;
  if (period == 'PM' && hour != 12) {
    militaryHour += 12;
  } else if (period == 'AM' && hour == 12) {
    militaryHour = 0;
  }
  final String militaryHourString = militaryHour.toString().padLeft(2, '0');
  final String minuteString = minute.toString().padLeft(2, '0');
  return '$militaryHourString:$minuteString';
}

class Slot extends StatefulWidget {
  final Map<String, dynamic> appointmentinfo;
  final String time;
  final int index;
  const Slot({
    super.key,
    required this.appointmentinfo,
    required this.time,
    required this.index,
  });

  @override
  State<Slot> createState() => _SlotState();
}

class _SlotState extends State<Slot> {
  AppointmentSlotController controller = Get.find<AppointmentSlotController>();
  Color decideSlotColor() {
    if (controller.selectedIndex.value == widget.index) {
      return Colors.lightBlue;
    }
    if (widget.appointmentinfo.isEmpty) {
      return Colors.green;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return GetX<AppointmentSlotController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: decideSlotColor(),
          ),
          child: InkWell(
            onTap: () {
              if (widget.appointmentinfo.isNotEmpty) {
                return;
              }
              controller.setSelectedTime(widget.time);
              controller.selectedIndex(widget.index);
            },
            child: Text(
              widget.time,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}

class AppointmentSlots extends StatefulWidget {
  final List<dynamic> allappointments;
  final int doctorId;
  final DateTime date;
  const AppointmentSlots({
    super.key,
    required this.allappointments,
    required this.doctorId,
    required this.date,
  });

  @override
  State<AppointmentSlots> createState() => _AppointmentSlotsState();
}

class _AppointmentSlotsState extends State<AppointmentSlots> {
  Future<Map<String, dynamic>> getTimeSchedule() async {
    Dio dio = Dio();
    final response =
        await dio.get("$url/doctortimescheduleforday", queryParameters: {
      "doctorid": widget.doctorId,
      "day": DateFormat('EEEE').format(widget.date),
    });
    return response.data;
  }

  Future<Map<String, DateTime>> getTimeScheduleDateTime() async {
    Map<String, dynamic> timeSchedule = await getTimeSchedule();
    return {
      "start_time": DateTime.parse(
          '${DateFormat('yyyy-MM-dd').format(widget.date)} ${militaryTime(timeSchedule['start_time'])}'),
      "end_time": DateTime.parse(
          '${DateFormat('yyyy-MM-dd').format(widget.date)} ${militaryTime(timeSchedule['end_time'])}'),
    };
  }

  AppointmentSlotController controller = Get.find<AppointmentSlotController>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getTimeScheduleDateTime(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Container(
            width: 200,
            height: 900,
            child: ListView(
              children: getSlots(
                widget.allappointments,
                snapshot.data['start_time'],
                snapshot.data['end_time'],
                widget.date,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class AppointmentDatePicker extends StatefulWidget {
  final int doctorId;
  const AppointmentDatePicker({super.key, required this.doctorId});

  @override
  State<AppointmentDatePicker> createState() => _AppointmentDatePickerState();
}

class _AppointmentDatePickerState extends State<AppointmentDatePicker> {
  AppointmentSlotController controller = Get.find<AppointmentSlotController>();

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void dispose() {
    super.dispose();
    controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GetX<AppointmentSlotController>(
      builder: (controller) {
        return Column(
          children: [
            TableCalendar(
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              focusedDay: controller.selectedDate.value ?? DateTime.now(),
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 7)),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
              ),
              onDaySelected: (selectedDay, focusedDay) async {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                controller.setSelectedDate(selectedDay);
                Dio dio = Dio();
                final response = await dio.get(
                  '$url/appointments',
                  queryParameters: {
                    "doctorId": widget.doctorId,
                    "date": DateFormat('yyyy-MM-dd').format(selectedDay)
                  },
                );
                final responseData = response.data;
                _showWidget(context, responseData);
              },
            ),
            Container(
              height: 55,
              width: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 42, 58, 226),
                    Color.fromARGB(255, 112, 145, 243)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: InkWell(
                onTap: () async {
                  Dio dio = Dio();
                  final response = await dio.post(
                    "$url/bookappointment/",
                    data: controller.getData(),
                  );
                  final responseData = response.data;
                  final snackBar = SnackBar(
                    content: Text(responseData['booking']
                        ? "Appointment Booked Successfully."
                        : "Failed To Book Appointment."),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.only(
                        top: 80.0, left: 16.0, right: 16.0),
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    textAlign: TextAlign.center,
                    controller.selectedtime.value == ""
                        ? "Select a date"
                        : "Book an appointment on\n${DateFormat.yMMMd().format(controller.selectedDate.value!)} at ${controller.selectedtime.value}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showWidget(BuildContext context, Map<String, dynamic> appointments) {
    if (controller.selectedDate.value != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Available Slots',
              textAlign: TextAlign.center,
            ),
            content: AppointmentSlots(
              allappointments: appointments['appointments'],
              doctorId: widget.doctorId,
              date: controller.selectedDate.value!,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Back',
                ),
              ),
            ],
          );
        },
      );
    }
  }
}

class DoctorTile extends StatefulWidget {
  const DoctorTile({super.key, required this.doctordescription});

  final dynamic doctordescription;

  @override
  State<DoctorTile> createState() => _DoctorTileState();
}

class _DoctorTileState extends State<DoctorTile> {
  String formatTime(String time) {
    String formattedTime = time.substring(0, 5);
    return formattedTime;
  }

  bool _expand = false;
  List<Icon> toggle = [
    const Icon(Icons.arrow_downward_rounded),
    const Icon(Icons.arrow_upward_rounded)
  ];

  AppointmentSlotController controller = Get.put(AppointmentSlotController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 15,
        bottom: _expand ? 15 : 0,
      ),
      margin: const EdgeInsets.fromLTRB(7, 7, 7, 0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 42, 58, 226),
            Color.fromARGB(255, 112, 145, 243),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: _expand ? 0 : 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const IconTheme(
                    data: IconThemeData(size: 50, color: Colors.white),
                    child: Icon(Icons.person),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${widget.doctordescription['firstname']} ${widget.doctordescription['lastname']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "General practitioner",
                        style: TextStyle(
                          color: Color.fromARGB(255, 237, 240, 91),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Price: ${widget.doctordescription['price']}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 14, 204, 20),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _expand = !_expand;
                    });
                  },
                  child: IconTheme(
                    data: const IconThemeData(size: 35, color: Colors.white),
                    child: _expand ? toggle[1] : toggle[0],
                  ),
                )
              ],
            ),
          ),
          if (_expand)
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 5, 0, 5),
              child: DoctorSchedule(
                schedule: widget.doctordescription['schedule'],
                textcolor: Colors.white,
              ),
            ),
          if (_expand)
            Container(
              height: 50,
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
                  onTap: () {
                    controller.setDoctorId(widget.doctordescription['id']);
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return AppointmentDatePicker(
                          doctorId: widget.doctordescription['id'],
                        );
                      },
                    );
                  },
                  child: const Text(
                    'Book Appointment',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Appointment extends StatefulWidget {
  const Appointment({super.key, required this.doctordescriptions});

  final List<dynamic> doctordescriptions;

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 90),
      child: ListView.builder(
        itemCount: widget.doctordescriptions.length,
        itemBuilder: (context, index) {
          return DoctorTile(
              doctordescription: widget.doctordescriptions[index]);
        },
      ),
    );
  }
}
