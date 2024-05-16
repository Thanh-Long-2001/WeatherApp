// import 'package:firebase_core/firebase_core.dart';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weatherapp_starter_project/controller/notifi_service.dart';
import 'package:weatherapp_starter_project/screens/home_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
DateTime scheduleTime = DateTime.now();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationService().initNotification();
  tz.initializeTimeZones();
  
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: const HomeScreen(),
      title: "Weather",
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(ConnectivityController());
      }),
    );
  }
}

class ConnectivityController extends GetxController {
  var isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();

    // Theo dõi trạng thái mạng
    Connectivity().onConnectivityChanged.listen((result) {
      isOnline.value = (result != ConnectivityResult.none);
      
      // Kiểm tra nếu có mạng sau khi mất mạng
      if (isOnline.value) {
        // Gọi hàm để khởi động lại ứng dụng
        restartApp();
      }
    });
  }

  // Hàm để khởi động lại ứng dụng
  void restartApp() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Gọi hàm để khởi động lại ứng dụng
      runApp(const MyApp());
    });
  }
}