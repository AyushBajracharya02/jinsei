import 'package:get/get.dart';

class PrescriptionController extends GetxController {
  RxnDouble weight = RxnDouble();
  RxnDouble temperature = RxnDouble();
  RxnInt pulserate = RxnInt();
  RxnInt oxygenlevel = RxnInt();
  Map<String, int?> bloodpressure = {"upper": null, "lower": null};
  List<Map<String, dynamic>> schedules = [];
  RxnInt appointment = RxnInt();

  void reset() {
    weight.value = null;
    temperature.value = null;
    pulserate.value = null;
    oxygenlevel.value = null;
    bloodpressure = {"upper": null, "lower": null};
    schedules = [];
    appointment.value = null;
  }

  bool isScheduleExist(String name) {
    for (var schedule in schedules) {
      if (schedule['name'] == name) {
        return true;
      }
    }
    return false;
  }

  void setBloodPressure(int? upper, int? lower) {
    bloodpressure = {
      "upper": upper,
      "lower": lower,
    };
  }

  Map<String, dynamic> getData() {
    return {
      "appointment": appointment.value,
      "weight": weight.value,
      "temperature": temperature.value,
      "pulserate": pulserate.value,
      "oxygenlevel": oxygenlevel.value,
      "bloodpressure": bloodpressure,
      "schedules": schedules,
    };
  }

  void setWeight(double? value) {
    weight.value = value;
  }

  void setTemperature(double? value) {
    temperature.value = value;
  }

  void setPulserate(int? value) {
    pulserate.value = value;
  }

  void setOxgenlevel(int? value) {
    oxygenlevel.value = value;
  }
}
