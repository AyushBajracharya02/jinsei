import 'package:flutter/material.dart';
import 'package:jinsei/components/errormessage.dart';

class Price extends StatefulWidget {
  Price(
      {super.key,
      required this.controller,
      required this.hasError,
      this.initialValue});
  final dynamic controller;
  bool hasError = false;
  String? initialValue;

  @override
  State<Price> createState() => _Price();
}

class _Price extends State<Price> {
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
              initialValue: widget.initialValue ?? "",
              style: const TextStyle(
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: Color(0xFFF2F3F8),
                labelText: 'Price',
                labelStyle: TextStyle(
                  color: Colors.black,
                ),
              ),
              onChanged: (value) {
                widget.controller.setPrice(value.trim());
                widget.controller.validatePrice();
                setState(() {
                  widget.hasError =
                      widget.controller.errors.containsKey("price");
                });
              },
            ),
          ),
        ),
        if (widget.hasError)
          ErrorMessage(
            message: widget.controller.errors['price'],
          )
      ],
    );
  }
}
