import 'package:get/get.dart';

class FilterController extends GetxController {
  RxInt select = 0.obs;
  RxInt subjectSelect = 0.obs;

  selectChange(int value) {
    select.value = value;
    update();
  }

  subjectChange(int value) {
    subjectSelect.value = value;
    update();
  }
}
