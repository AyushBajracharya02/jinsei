import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:jinsei/main.dart';
import 'package:intl/intl.dart';
import "package:jinsei/controllers/prescriptioncontroller.dart";
import "package:get/get.dart";
import 'package:shared_preferences/shared_preferences.dart';

class Appointments extends StatefulWidget {
  const Appointments({super.key});

  @override
  State<Appointments> createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  Future<Map<String, dynamic>> getUserAppointments() async {
    Dio dio = Dio();
    final response = await dio.get(
      '$url/upcomingappointments',
      queryParameters: {
        'userId': cookie['userdata']['id'],
        'isdoctor': cookie['userdata']['isdoctor'],
      },
    );
    return response.data;
  }

  void sortAppointments(String? sortBy) {
    if (toggle) {
      if (sortBy == 'Date') {
        setState(() {
          appointmentsasdoctor.sort((a, b) => DateTime.parse(
                  "${a['appointmentdetails']['appointment']['date']} ${a['appointmentdetails']['appointment']['time']}")
              .compareTo(DateTime.parse(
                  "${b['appointmentdetails']['appointment']['date']} ${b['appointmentdetails']['appointment']['time']}")));
        });
      } else if (sortBy == 'Name') {
        setState(() {
          appointmentsasdoctor.sort((a, b) =>
              "${a['appointmentdetails']['patient']['firstname']} ${a['appointmentdetails']['patient']['lastname']}"
                  .compareTo(
                      "${b['appointmentdetails']['patient']['firstname']} ${b['appointmentdetails']['patient']['lastname']}"));
        });
      }
      return;
    }
    if (sortBy == 'Date') {
      setState(() {
        appointmentsaspatient.sort((a, b) => DateTime.parse(
                "${a['appointmentdetails']['appointment']['date']} ${a['appointmentdetails']['appointment']['time']}")
            .compareTo(DateTime.parse(
                "${b['appointmentdetails']['appointment']['date']} ${b['appointmentdetails']['appointment']['time']}")));
      });
    } else if (sortBy == 'Name') {
      setState(() {
        appointmentsaspatient.sort((a, b) =>
            "${a['appointmentdetails']['doctor']['firstname']} ${a['appointmentdetails']['doctor']['lastname']}"
                .compareTo(
                    "${b['appointmentdetails']['doctor']['firstname']} ${b['appointmentdetails']['doctor']['lastname']}"));
      });
    }
  }

  late List<dynamic> appointmentsaspatient;
  late List<dynamic> appointmentsasdoctor;
  bool toggle = false;
  String toggletext = "As Patient";
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
    return FutureBuilder(
      future: getUserAppointments(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          appointmentsaspatient = snapshot.data!['appointmentsaspatient'];
          if (cookie['userdata']['isdoctor']) {
            appointmentsasdoctor = snapshot.data!['appointmentsasdoctor'];
          }
          return Container(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 90),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SortWidget(sort: sortAppointments),
                      if (cookie['userdata']['isdoctor'])
                        Container(
                          // padding: EdgeInsets.all(5),
                          height: 45,
                          width: 125,
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
                            onTap: () {
                              setState(() {
                                toggle = !toggle;
                                if (toggle) {
                                  toggletext = "As Doctor";
                                } else {
                                  toggletext = "As Patient";
                                }
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  toggletext,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!toggle)
                  Expanded(
                    child: appointmentsaspatient.isEmpty
                        ? const Center(
                            child: Text("No Upcoming Appointments"),
                          )
                        : ListView.builder(
                            itemCount: appointmentsaspatient.length,
                            itemBuilder: (context, index) {
                              return AppointmentTile(
                                  details: appointmentsaspatient[index]
                                      ['appointmentdetails']);
                            },
                          ),
                  )
                else
                  Expanded(
                    child: appointmentsasdoctor.isEmpty
                        ? const Center(
                            child: Text("No Upcoming Appointments"),
                          )
                        : ListView.builder(
                            itemCount: appointmentsasdoctor.length,
                            itemBuilder: (context, index) {
                              return PatientAppointmentTile(
                                  details: appointmentsasdoctor[index]
                                      ['appointmentdetails']);
                            },
                          ),
                  )
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class AppointmentTile extends StatefulWidget {
  const AppointmentTile({super.key, required this.details});
  final Map<String, dynamic> details;

  @override
  State<AppointmentTile> createState() => _AppointmentTileState();
}

class _AppointmentTileState extends State<AppointmentTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const IconTheme(
              data: IconThemeData(
                size: 45,
              ),
              child: Icon(Icons.person),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dr. ${widget.details['doctor']['firstname']} ${widget.details['doctor']['lastname']}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Dental Specialist",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                "Contact: ${widget.details['doctor']['phonenumber']}",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 8.0,
                ),
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6, right: 14),
                      child: Text(
                        "${widget.details['appointment']['date']}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.timer,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      DateFormat("hh:mm a").format(DateTime.parse(
                          "${widget.details['appointment']['date']} ${widget.details['appointment']['time']}")),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class PatientAppointmentTile extends StatefulWidget {
  const PatientAppointmentTile({super.key, required this.details});
  final Map<String, dynamic> details;

  @override
  State<PatientAppointmentTile> createState() => _PatientAppointmentTile();
}

class _PatientAppointmentTile extends State<PatientAppointmentTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrescriptionForm(details: widget.details),
          ),
        );
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const IconTheme(
                data: IconThemeData(
                  size: 45,
                ),
                child: Icon(Icons.person),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.details['patient']['firstname']} ${widget.details['patient']['lastname']}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                // Text(
                //   "Dental Specialist",
                //   style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                //         color: Colors.white70,
                //       ),
                // ),
                // const SizedBox(height: 5),
                Text(
                  "Contact: ${widget.details['patient']['phonenumber']}",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8.0,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6, right: 14),
                        child: Text(
                          "${widget.details['appointment']['date']}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.timer,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat("hh:mm a").format(DateTime.parse(
                            "${widget.details['appointment']['date']} ${widget.details['appointment']['time']}")),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PrescriptionForm extends StatefulWidget {
  const PrescriptionForm({super.key, required this.details});
  final Map<String, dynamic> details;

  @override
  State<PrescriptionForm> createState() => _PrescriptionFormState();
}

class _PrescriptionFormState extends State<PrescriptionForm> {
  PrescriptionController controller = Get.put(PrescriptionController());
  Map<String, Color> errorState = {
    "Weight": Colors.black,
    "Temperature": Colors.black,
    "PR": Colors.black,
    "Blood Pressure": Colors.black,
    "SpO2": Colors.black,
  };

  @override
  void initState() {
    controller.appointment.value = widget.details['appointment']['id'];
    super.initState();
  }

  @override
  void dispose() {
    controller.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prescription Form"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Name: ${widget.details['patient']['firstname']} ${widget.details['patient']['lastname']}",
                          ),
                          Text(
                              "Sex: ${sexFullForm(widget.details['patient']['sex'])}"),
                        ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Age: ${widget.details['patient']['age']}"),
                        Row(
                          children: [
                            Text("Weight: "),
                            Container(
                              width: 50,
                              child: TextFormField(
                                style: TextStyle(color: errorState["Weight"]),
                                onChanged: (text) {
                                  double? value = double.tryParse(text);
                                  if (value == null) {
                                    setState(() {
                                      errorState['Weight'] = Colors.red;
                                    });
                                  } else {
                                    setState(() {
                                      errorState['Weight'] = Colors.black;
                                    });
                                  }
                                  controller.setWeight(
                                    double.tryParse(text),
                                  );
                                },
                              ),
                            ),
                            Text("KG"),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text("Temperature:"),
                            Container(
                              width: 50,
                              child: TextFormField(
                                style:
                                    TextStyle(color: errorState["Temperature"]),
                                onChanged: (text) {
                                  double? value = double.tryParse(text);
                                  if (value == null) {
                                    setState(() {
                                      errorState['Temperature'] = Colors.red;
                                    });
                                  } else {
                                    setState(() {
                                      errorState['Temperature'] = Colors.black;
                                    });
                                  }
                                  controller.setTemperature(
                                    double.tryParse(text),
                                  );
                                },
                              ),
                            ),
                            const Text("°F")
                          ],
                        ),
                        Row(
                          children: [
                            const Text("PR: "),
                            Container(
                              width: 50,
                              child: TextFormField(
                                style: TextStyle(color: errorState["PR"]),
                                onChanged: (text) {
                                  int? value = int.tryParse(text);
                                  if (value == null) {
                                    setState(() {
                                      errorState['PR'] = Colors.red;
                                    });
                                  } else {
                                    setState(() {
                                      errorState['PR'] = Colors.black;
                                    });
                                  }
                                  controller.setPulserate(value);
                                },
                              ),
                            ),
                            const Text("bpm"),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text("Blood Pressure: "),
                            Container(
                              width: 50,
                              child: TextFormField(
                                style: TextStyle(
                                    color: errorState["Blood Pressure"]),
                                onChanged: (text) {
                                  int? value = int.tryParse(text);
                                  if (value == null) {
                                    setState(() {
                                      errorState['Blood Pressure'] = Colors.red;
                                    });
                                  } else {
                                    setState(() {
                                      errorState['Blood Pressure'] =
                                          Colors.black;
                                    });
                                  }
                                  controller.setBloodPressure(
                                    value,
                                    controller.bloodpressure['lower'],
                                  );
                                },
                              ),
                            ),
                            Text("/"),
                            Container(
                              width: 50,
                              child: TextFormField(
                                style: TextStyle(
                                    color: errorState["Blood Pressure"]),
                                onChanged: (text) {
                                  int? value = int.tryParse(text);
                                  if (value == null) {
                                    setState(() {
                                      errorState['Blood Pressure'] = Colors.red;
                                    });
                                  } else {
                                    setState(() {
                                      errorState['Blood Pressure'] =
                                          Colors.black;
                                    });
                                  }
                                  controller.setBloodPressure(
                                    controller.bloodpressure['upper'],
                                    value,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Sp02:"),
                            Container(
                              width: 50,
                              child: TextFormField(
                                style: TextStyle(color: errorState["SpO2"]),
                                onChanged: (text) {
                                  int? value = int.tryParse(text);
                                  if (value == null) {
                                    setState(() {
                                      errorState['SpO2'] = Colors.red;
                                    });
                                  } else {
                                    setState(() {
                                      errorState['SpO2'] = Colors.black;
                                    });
                                  }
                                  controller.setOxgenlevel(value);
                                },
                              ),
                            ),
                            Text("%"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Medications:"),
                    MedicationInput(),
                  ],
                ),
                Container(
                  height: 50,
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
                        "$url/addprescription/",
                        data: controller.getData(),
                      );
                      final snackBar = SnackBar(
                        content: Text(response.statusCode! >= 200 &&
                                response.statusCode! < 300
                            ? "Prescription saved Successfully."
                            : "Failed To Save Prescription."),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.only(
                            top: 80.0, left: 16.0, right: 16.0),
                      );
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Write Prescription",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MedicationInput extends StatefulWidget {
  const MedicationInput({super.key});

  @override
  State<MedicationInput> createState() => _MedicationInputState();
}

class _MedicationInputState extends State<MedicationInput> {
  bool showList = false;

  Future<List<dynamic>> getMedicineList() async {
    Dio dio = Dio();
    final response = await dio.get("$url/medicinelist/");
    final responseData = response.data;
    return responseData['medicines'];
  }

  late List<dynamic> medicinelist;
  late Iterable<dynamic> sublist;
  List<String> selectedMedication = [];

  void fetchMedicineList() async {
    Dio dio = Dio();
    final response = await dio.get("$url/medicinelist");
    final responseData = response.data;
    medicinelist = responseData['medicines'];
    sublist = medicinelist;
  }

  @override
  void initState() {
    super.initState();
    fetchMedicineList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            fillColor: const Color(0xFFF2F3F8),
            labelText: 'Search Medicine',
            labelStyle: const TextStyle(
              color: Colors.black,
            ),
            suffixIcon: IconButton(
              icon: Icon(showList ? Icons.arrow_upward : Icons.arrow_downward),
              onPressed: () {
                setState(() {
                  showList = !showList;
                });
              },
            ),
          ),
          onChanged: (text) {
            if (!showList) {
              return;
            }
            setState(() {
              sublist = medicinelist.where(
                (element) {
                  return element['name']
                      .toString()
                      .toLowerCase()
                      .contains(text.toLowerCase());
                },
              );
            });
          },
        ),
        if (showList)
          Container(
            height: 150,
            child: ListView.builder(
              itemCount: sublist.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (selectedMedication
                        .contains("${sublist.toList()[index]['name']}")) {
                      return;
                    }
                    setState(() {
                      selectedMedication
                          .add("${sublist.toList()[index]['name']}");
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    alignment: Alignment.center,
                    height: 40,
                    child: Text(
                      "${sublist.toList()[index]['name']}",
                    ),
                  ),
                );
              },
            ),
          ),
        Container(
          width: double.infinity,
          // color: Colors.red,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < selectedMedication.length; i++)
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${i + 1}. ${selectedMedication[i]}"),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
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
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Set Schedule',
                                        textAlign: TextAlign.center,
                                      ),
                                      content: MedicineScheduleSetter(
                                        name: selectedMedication[i],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text(
                                            'Back',
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Set Schedule",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                selectedMedication = selectedMedication
                                    .where((element) =>
                                        element != selectedMedication[i])
                                    .toList();
                              });
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}

class MedicineScheduleSetter extends StatefulWidget {
  const MedicineScheduleSetter({super.key, required this.name});
  final String name;

  @override
  State<MedicineScheduleSetter> createState() => _MedicineScheduleSetterState();
}

class _MedicineScheduleSetterState extends State<MedicineScheduleSetter> {
  bool mealbased = true;
  List<String> selectedTimes = [];
  bool? breakfast = true;
  bool? lunch = true;
  bool? dinner = true;

  String booltoStringformeal(bool? value) {
    return value == null
        ? "Skip"
        : value
            ? "After"
            : "Before";
  }

  PrescriptionController controller = Get.find<PrescriptionController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (mealbased)
            Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Breakfast"),
                  DropdownButton(
                    value: booltoStringformeal(breakfast),
                    items: ["Skip", "After", "Before"]
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Row(
                              children: [
                                Text(e),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (String? newvalue) {
                      if (newvalue == "Skip") {
                        setState(() {
                          breakfast = null;
                        });
                      } else if (newvalue == "Before") {
                        setState(() {
                          breakfast = false;
                        });
                      } else {
                        setState(() {
                          breakfast = true;
                        });
                      }
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Lunch"),
                  DropdownButton(
                    value: booltoStringformeal(lunch),
                    items: ["Skip", "After", "Before"]
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Row(
                              children: [
                                Text(e),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (String? newvalue) {
                      if (newvalue == "Skip") {
                        setState(() {
                          lunch = null;
                        });
                      } else if (newvalue == "Before") {
                        setState(() {
                          lunch = false;
                        });
                      } else {
                        setState(() {
                          lunch = true;
                        });
                      }
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Dinner"),
                  DropdownButton(
                    value: booltoStringformeal(dinner),
                    items: ["Skip", "After", "Before"]
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Row(
                              children: [
                                Text(e),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (String? newvalue) {
                      if (newvalue == "Skip") {
                        setState(() {
                          dinner = null;
                        });
                      } else if (newvalue == "Before") {
                        setState(() {
                          dinner = false;
                        });
                      } else {
                        setState(() {
                          dinner = true;
                        });
                      }
                    },
                  ),
                ],
              ),
            ]),
          if (!mealbased)
            Column(
              children: [
                for (int i = 0; i < selectedTimes.length; i++)
                  Text("${selectedTimes[i]}"),
                InkWell(
                  child: Text("Add Time"),
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      selectedTimes.add(selectedTime!.format(context));
                    });
                  },
                ),
                InkWell(
                  child: Text("Remove Time"),
                  onTap: () {
                    setState(() {
                      selectedTimes.removeLast();
                    });
                  },
                ),
              ],
            ),
          Container(
            padding: EdgeInsets.all(10),
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
              onTap: () {
                setState(() {
                  mealbased = !mealbased;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    mealbased ? "Meal Based Schedule" : "Time Based Schedule",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            child: Text("OK"),
            onTap: () {
              if (controller.isScheduleExist(widget.name)) {
                controller.schedules = controller.schedules
                    .where((element) => element['name'] != widget.name)
                    .toList();
              }
              if (mealbased) {
                controller.schedules.add({
                  "name": widget.name,
                  "timebased": false,
                  "mealbased": {
                    "breakfast": breakfast,
                    "lunch": lunch,
                    "dinner": dinner,
                  }
                });
              } else {
                controller.schedules.add({
                  "name": widget.name,
                  "timebased": selectedTimes,
                  "mealbased": false
                });
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
