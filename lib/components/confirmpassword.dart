import 'package:flutter/material.dart';
import 'package:jinsei/components/errormessage.dart';
import 'package:jinsei/controllers/signupcontroller.dart';

class ConfirmPasswordForm extends StatefulWidget {
  final dynamic controller;
  bool hasError;
  ConfirmPasswordForm({super.key, required this.controller, required this.hasError, this.initialValue});

  String? initialValue;
  @override
  State<ConfirmPasswordForm> createState() => _ConfirmPasswordForm();
}

class _ConfirmPasswordForm extends State<ConfirmPasswordForm> {
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
                widget.controller.setConfirmPassword(value);
                widget.controller.validateConfirmPassword();
                setState(() {
                  widget.hasError =
                      widget.controller.errors.containsKey("confirmpassword");
                });
              },
              style: const TextStyle(
                color: Colors.black,
              ),
              obscureText: _obscureText,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelStyle: const TextStyle(
                  color: Colors.black,
                ),
                filled: true,
                fillColor: const Color(0xFFF2F3F8),
                labelText: 'Confirm Password',
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
        if (widget.hasError)
          ErrorMessage(
            message: widget.controller.errors['confirmpassword']!,
          ),
      ],
    );
  }
}
