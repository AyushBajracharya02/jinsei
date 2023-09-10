import 'package:flutter/material.dart';
import 'package:jinsei/components/errormessage.dart';

class PasswordForm extends StatefulWidget {
  final dynamic controller;
  PasswordForm({super.key, required this.controller, this.hasError, this.initialValue});

  String? initialValue;
  bool? hasError = false;

  @override
  State<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
              initialValue: widget.initialValue??"",
              onChanged: (value) {
                widget.controller.setPassword(value);
                widget.controller.validatePassword();
                setState(() {
                  widget.hasError =
                      widget.controller.errors.containsKey("password");
                });
              },
              style: const TextStyle(
                color: Colors.black,
              ),
              obscureText: _obscureText,
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: const Color(0xFFF2F3F8),
                labelText: 'Password',
                labelStyle: const TextStyle(
                  color: Colors.black,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        if (widget.hasError!)
          ErrorMessage(
            message: widget.controller.errors['password'],
          )
      ],
    );
  }
}
