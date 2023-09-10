import 'package:flutter/material.dart';
import 'package:jinsei/components/accounttype.dart';
import 'components/password.dart';
import 'components/phonenumber.dart';
import 'controllers/logincontroller.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});
  final controller = Get.put(LoginController());
  Map<String, String> errors = {};

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 100,
              ),
              const Text(
                "Log in to\nJinsei",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF04408C),
                  fontSize: 35.0,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              PhoneNumberForm(
                controller: widget.controller,
                hasError: widget.controller.errors.containsKey('phone'),
              ),
              const SizedBox(
                height: 20,
              ),
              PasswordForm(
                controller: widget.controller,
                hasError: widget.controller.errors.containsKey('password'),
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
                        widget.controller.login(context);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Log-In",
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
                "Create an account?\nSwipe Left",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
