import 'package:flutter/material.dart';
import 'package:jinsei/controllers/editprofilecontroller.dart';
import 'package:intl/intl.dart';

class DateOfBirth extends StatefulWidget {
  final EditProfileController controller;
  String? initialValue;
  DateOfBirth({super.key, required this.controller, this.initialValue});

  @override
  State<DateOfBirth> createState() => _DateOfBirthState();
}

class _DateOfBirthState extends State<DateOfBirth> {
  bool entereddateofbirth = false;

  late DateTime initialDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue == null) {
      initialDate = DateTime.now().subtract(const Duration(days: 365 * 18));
    } else {
      int year = int.parse(widget.initialValue!.substring(0, 4));
      int month = int.parse(widget.initialValue!.substring(5, 7));
      int day = int.parse(widget.initialValue!.substring(8));
      initialDate = DateTime(year, month, day);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 62,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2633C5), Color(0xFF6A88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            // borderRadius: BorderRadius.all(Radius.circular(12)),
            color: Color(0xFFF2F3F8),
          ),
          child: InkWell(
            onTap: () {
              showDatePicker(
                context: context,
                firstDate:
                    DateTime.now().subtract(const Duration(days: 365 * 80)),
                initialDate: initialDate,
                lastDate:
                    DateTime.now().subtract(const Duration(days: 365 * 18)),
              ).then((value) {
                setState(() {
                  entereddateofbirth = true;
                });
                widget.controller
                    .setDateOfBirth(DateFormat("yyyy-MM-dd").format(value!));
              });
            },
            child: Text(
              textAlign: TextAlign.center,
              entereddateofbirth
                  ? "You were born in ${widget.controller.dateofbirth}"
                  : widget.initialValue == null
                      ? "Enter Date of Birth"
                      : "You were born in ${DateFormat("yyyy-MM-dd").format(initialDate)}",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
