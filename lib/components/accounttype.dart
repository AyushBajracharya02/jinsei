import 'package:flutter/material.dart';

class AccountType extends StatefulWidget {
  const AccountType({super.key, required this.controller});
  final dynamic controller;

  @override
  State<AccountType> createState() => _AccountTypeState();
}

class _AccountTypeState extends State<AccountType> {
  @override
  void initState() {
    super.initState();
    widget.controller.setAccountType("Patient");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.all(2),
          width: double.infinity,
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
                value: "Patient",
                onChanged: (value) {
                  widget.controller.setAccountType(value);
                },
                items: ['Patient', 'Doctor']
                    .map(
                      (accountType) => DropdownMenuItem(
                        value: accountType,
                        child: Text(accountType),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        
      ],
    );
  }
}
