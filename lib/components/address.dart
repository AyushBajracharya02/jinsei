import 'package:flutter/material.dart';
import 'package:jinsei/controllers/editprofilecontroller.dart';

class Address extends StatefulWidget {
  final EditProfileController controller;
  Address({super.key,required this.controller, this.initialValue});
  String? initialValue;
  @override
  State<Address> createState() => _AddressState();
}

class _AddressState extends State<Address> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          style: const TextStyle(
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            filled: true,
            fillColor: Color(0xFFF2F3F8),
            labelText: 'Address',
            labelStyle: TextStyle(
              color: Colors.black,
            ),
          ),
          onChanged: (value) {
            widget.controller.setAddress(value.trim());
          },
        ),
      ),
    );
  }
}
