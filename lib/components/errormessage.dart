import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({super.key,required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2,2,2,0),
      child: Text(
        message,
        style: const TextStyle(fontSize: 12.0, color: Colors.red),
      ),
    );
  }
}