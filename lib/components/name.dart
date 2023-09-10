import 'package:flutter/material.dart';
import 'package:jinsei/components/errormessage.dart';
import 'package:jinsei/main.dart';

class Name extends StatefulWidget {
  Name(
      {super.key,
      required this.controller,
      required this.hasError,
      this.initialfirstname,
      this.initiallastname});
  final dynamic controller;
  String? initialfirstname;
  String? initiallastname;
  bool hasError;

  @override
  State<Name> createState() => _NameState();
}

class _NameState extends State<Name> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
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
                  child: TextFormField(
                    initialValue: widget.initialfirstname ?? "",
                    onChanged: (value) {
                      widget.controller.setFirstName(value.trim());
                      widget.controller.validateName();
                      setState(() {
                        widget.hasError =
                            widget.controller.errors.containsKey("name");
                      });
                    },
                    decoration: const InputDecoration(
                      labelStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                      labelText: "Firstname",
                      filled: true,
                      fillColor: Color(0xFFF2F3F8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
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
                  child: TextFormField(
                    initialValue: widget.initiallastname ?? "",
                    onChanged: (value) {
                      widget.controller.setLastName(value.trim());
                      widget.controller.validateName();
                      setState(() {
                        widget.hasError =
                            widget.controller.errors.containsKey("name");
                      });
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      labelText: "Lastname",
                      filled: true,
                      fillColor: Color(0xFFF2F3F8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (widget.hasError)
          ErrorMessage(
            message: widget.controller.errors['name'],
          )
      ],
    );
  }
}
