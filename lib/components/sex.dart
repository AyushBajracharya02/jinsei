import 'package:flutter/material.dart';

class Sex extends StatefulWidget {
  Sex({super.key, required this.controller, this.initialValue});
  final dynamic controller;
  String? initialValue;

  @override
  State<Sex> createState() => _SexState();
}

class _SexState extends State<Sex> {
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
            value: widget.initialValue ?? "Male",
            onChanged: (value) {
              widget.controller.setSex(value);
            },
            items: ['Male', 'Female', 'Other']
                .map(
                  (sex) => DropdownMenuItem(
                    value: sex,
                    child: Text(sex),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
