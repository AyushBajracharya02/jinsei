import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinsei/main.dart';

class EditProfileController extends GetxController {
  Map<String, dynamic> cookie = {};
  Map<String, dynamic> initialdata;
  var firstname;
  var lastname;
  var phoneNumber;
  var password;
  var confirmPassword;
  var address;
  var bloodgroup;
  var dateofbirth;
  var price;
  // var sex;
  Rxn<Map<String, dynamic>> schedule = Rxn({});
  Rxn<Map<String, dynamic>> mealschedule = Rxn({});

  EditProfileController({required this.initialdata}) {
    firstname = '${initialdata['firstname']}'.obs;
    lastname = '${initialdata['lastname']}'.obs;
    phoneNumber = '${initialdata['phonenumber']}'.obs;
    password = '${initialdata['password']}'.obs;
    confirmPassword = '${initialdata['password']}'.obs;
    address = '${initialdata['address']}'.obs;
    bloodgroup = '${initialdata['bloodgroup']}'.obs;
    dateofbirth = '${initialdata['date_of_birth']}'.obs;
    price = '${initialdata['price']}'.obs;
    schedule.value = initialdata['schedule'];
    mealschedule.value = initialdata['mealschedule'];
    // sex.value = "${initialdata['sex']}".obs;
    getCookie().then((value) {
      cookie = value;
    });
  }
  Map<String, String> errors = {};

  RegExp nameRegex = RegExp(r'^[a-zA-Z]{2,32}$');
  RegExp phoneRegex = RegExp(r'^\d{10}$');
  RegExp passwordRegex = RegExp(r'^.{8,32}$');
  RegExp priceRegex = RegExp(r'^\d+$');

  void setMealSchedule(String meal, String time) {
    mealschedule.value = {...?mealschedule.value, meal: time};
  }

  void setSchedule(String day, String startOrEnd, String value) {
    schedule.value![day][startOrEnd] = value;
  }

  void setPrice(String value) {
    price.value = value;
  }

  void setDateOfBirth(String value) {
    dateofbirth.value = value;
  }

  void setBloodGroup(String value) {
    bloodgroup.value = value;
  }

  void setSex(String value) {
    // sex.value = value;
  }

  void setAddress(String value) {
    address.value = value;
  }

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

  Map<String, dynamic> getData() {
    return {
      "firstname": firstname.value,
      "lastname": lastname.value,
      "phonenumber": phoneNumber.value,
      "password": password.value,
      "address": address.value,
      "date_of_birth": dateofbirth.value,
      "bloodgroup": bloodgroup.value,
      'mealschedule': mealschedule.value,
      // "sex": sex.value,
      if (cookie['userdata']['isdoctor']) "price": price.value,
      if (cookie['userdata']['isdoctor']) 'schedule': schedule.value,
    };
  }

  bool validatePrice() {
    if (!priceRegex.hasMatch(price.value)) {
      errors['price'] = "Price should only contain numbers";
      return false;
    } else {
      errors.remove("price");
      return true;
    }
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
}
