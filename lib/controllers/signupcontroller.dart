import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:jinsei/fitness_app/fitness_app_home_screen.dart';
import 'package:jinsei/main.dart';
import 'dart:convert';

class SignupController extends GetxController {
  Map<String, String> errors = {};

  var firstname = ''.obs;
  var lastname = ''.obs;
  var phoneNumber = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var accounttype = ''.obs;
  RegExp nameRegex = RegExp(r'^[a-zA-Z]{2,32}$');
  RegExp phoneRegex = RegExp(r'^\d{10}$');
  RegExp passwordRegex = RegExp(r'^.{8,32}$');

  void setFirstName(String value) {
    firstname.value = value;
  }

  void setLastName(String value) {
    lastname.value = value;
  }

  void setPhoneNumber(String value) {
    phoneNumber.value = value;
  }

  void setPassword(String value) {
    password.value = value;
  }

  void setConfirmPassword(String value) {
    confirmPassword.value = value;
  }

  void setAccountType(String value) {
    accounttype.value = value;
  }

  Map<String, String> getData() {
    return {
      "firstname": firstname.value,
      "lastname": lastname.value,
      "phonenumber": phoneNumber.value,
      "password": password.value,
      "accounttype": accounttype.value
    };
  }

  bool validateName() {
    if (!nameRegex.hasMatch(firstname.value) ||
        !nameRegex.hasMatch(lastname.value)) {
      errors['name'] =
          "Name should only contain letters and should be 2-32 characters";
      return false;
    } else {
      errors.remove("name");
      return true;
    }
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

  bool validateConfirmPassword() {
    if (password.value != confirmPassword.value) {
      errors['confirmpassword'] = "Passwords don't match";
      return false;
    } else {
      errors.remove("confirmpassword");
      return true;
    }
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

  Map<String, String> validate() {
    validateName();
    validatePhone();
    validatePassword();
    validateConfirmPassword();
    return errors;
  }

  /* 
  TODO: validate data
  */
  Future<void> signup(context) async {
    Dio dio = Dio();
    final response = await dio.post(
      '$url/signup/',
      data: getData(),
    );
    Map<String, dynamic> responseData = response.data;
    if (responseData['access']) {
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
