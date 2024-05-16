// Tạo một Global Controller
import 'package:get/get.dart';

class AppController extends GetxController {
  var isMenuVisible = false.obs;

  var currentIndex = 0;

  static bool arrowBack = true;

  // Hàm để toggle giá trị của isMenuVisible
  void toggleMenuVisibility() {
    isMenuVisible.value = !isMenuVisible.value;
    // print(isMenuVisible.value);
  }

  void pageIndexChanged(int pageIndex) {
    currentIndex = pageIndex;
  }

  void toggleArrowBack() {
    arrowBack = !arrowBack;
    // print(isMenuVisible.value);
  }

  bool getArrowState() {
    // print(arrowBack);
    return arrowBack;
  }
}
