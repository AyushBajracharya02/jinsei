import 'package:flutter/material.dart';
import 'package:jinsei/components/accounttype.dart';
import 'components/password.dart';
import 'components/confirmpassword.dart';
import 'components/phonenumber.dart';
import 'components/name.dart';
import 'package:get/get.dart';
import 'package:jinsei/controllers/signupcontroller.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  final controller = Get.put(SignupController());

  Map<String, String> errors = {};

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F8),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 100,
            ),
            const Text(
              "Sign up for\nJinsei",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Name(
              controller: widget.controller,
              hasError: widget.errors.containsKey("name"),
            ),
            const SizedBox(
              height: 20,
            ),
            PhoneNumberForm(
              controller: widget.controller,
              hasError: widget.errors.containsKey("phone"),
            ),
            const SizedBox(
              height: 20,
            ),
            PasswordForm(
              controller: widget.controller,
              hasError: widget.errors.containsKey("password"),
            ),
            const SizedBox(
              height: 20,
            ),
            ConfirmPasswordForm(
              controller: widget.controller,
              hasError: widget.errors.containsKey("confirmpassword"),
            ),
            const SizedBox(
              height: 20,
            ),
            AccountType(
              controller: widget.controller,
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 50,
              width: 200,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 42, 58, 226),
                      Color.fromARGB(255, 112, 145, 243)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      widget.errors = widget.controller.validate();
                    });
                    if (widget.errors.isEmpty) {
                      widget.controller.signup(context);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              "Already have an account?\nSwipe Right",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
