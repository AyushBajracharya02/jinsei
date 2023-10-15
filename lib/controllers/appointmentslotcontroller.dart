import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jinsei/main.dart';

class AppointmentSlotController extends GetxController {
  Map<String, dynamic> cookie = {};

  AppointmentSlotController() {
    getCookie().then((value) {
      cookie = value;
    });
  }

  RxString selectedtime = "".obs;
  RxInt selectedIndex = (-1).obs;
  Rxn<DateTime> selectedDate = Rxn<DateTime>();
  RxInt doctorId = (-1).obs;

  Map<String, dynamic> getData() {
    print(cookie);
    return {
      "time": selectedtime.value,
      "index": selectedIndex.value,
      "date": DateFormat("yyyy-MM-dd").format(selectedDate.value!),
      "doctorId": doctorId.value,
      "userId": cookie['userdata']['id'],
      'isdoctor': cookie['userdata']['isdoctor'],
    };
  }

  void reset() {
    selectedtime.value = "";
    selectedIndex.value = -1;
    selectedDate.value = null;
    doctorId.value = -1;
  }

  void setDoctorId(int value) {
    doctorId.value = value;
  }

  void setSelectedTime(String value) {
    selectedtime.value = value;
  }

  void setSelectedIndex(int value) {
    selectedIndex.value = value;
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }
}
