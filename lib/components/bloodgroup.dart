import 'package:flutter/material.dart';

class BloodGroup extends StatefulWidget {
  BloodGroup({super.key, required this.controller, this.initialValue});
  final dynamic controller;
  String? initialValue;

  @override
  State<BloodGroup> createState() => _BloodGroupState();
}

class _BloodGroupState extends State<BloodGroup> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2633C5), Color(0xFF6A88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color(0xFFF2F3F8),
        ),
        child: Center(
          child: DropdownButtonFormField(
            decoration: const InputDecoration.collapsed(hintText: ''),
            value: widget.initialValue ?? "A+",
            onChanged: (value) {
              widget.controller.setBloodGroup(value);
            },
            items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                .map(
                  (bloodgroup) => DropdownMenuItem(
                    value: bloodgroup,
                    child: Text(bloodgroup),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
