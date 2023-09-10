import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jinsei/fitness_app/fitness_app_home_screen.dart';
import 'package:jinsei/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  var phoneNumber = ''.obs;
  var password = ''.obs;
  var accounttype = ''.obs;
  RegExp passwordRegex = RegExp(r'^.{8,32}$');
  RegExp phoneRegex = RegExp(r'^\d{10}$');
  Map<String, String> errors = {};

  void setPhoneNumber(String value) {
    phoneNumber.value = value;
  }

  void setPassword(String value) {
    password.value = value;
  }

  void setAccountType(String value) {
    accounttype.value = value;
  }

  Map<String, String> getData() {
    return {
      'phonenumber': phoneNumber.value,
      'password': password.value,
      'accounttype': accounttype.value,
    };
  }

  bool validatePassword() {
    if (!passwordRegex.hasMatch(password.value)) {
      errors['password'] = "Password should be between 8 and 32 characters";
      return false;
    } else {
      errors.remove("password");
      return true;
    }
  }

  Map<String, String> validate() {
    validatePhone();
    validatePassword();
    return errors;
  }

  bool validatePhone() {
    if (!phoneRegex.hasMatch(phoneNumber.value)) {
      errors['phone'] =
          "Phone should only contain numbers and should be 10 characters";
      return false;
    } else {
      errors.remove("phone");
      return true;
    }
  }

  void login(context) async {
    Dio dio = Dio();
    final response = await dio.post(
      '$url/login/',
      data: getData(),
    );
    Map<String, dynamic> responseData = response.data;
    if (responseData['access']) {
      print(responseData);
      setCookie(responseData);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FitnessAppHomeScreen(),
        ),
      );
    }
  }
}
