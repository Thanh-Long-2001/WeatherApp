import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherapp_starter_project/api/fetch_weather.dart';
import 'package:weatherapp_starter_project/controller/app_controller.dart';
import 'package:weatherapp_starter_project/controller/global_controller.dart';
import 'package:weatherapp_starter_project/controller/notifi_service.dart';
// ignore: unused_import
import 'package:weatherapp_starter_project/model/weather_data_current.dart';
import 'package:weatherapp_starter_project/widgets/history_weather_widget.dart';
import 'package:weatherapp_starter_project/widgets/search_widget.dart';

DateTime scheduleTime = DateTime.now();

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  String city = "";
  String date = DateFormat("yMMMMd").format(DateTime.now());
  // DateTime scheduleTime = DateTime.now();
  final GlobalController globalController =
      Get.put(GlobalController(), permanent: true);

  final AppController appController = Get.put(AppController(), permanent: true);
  ScreenshotController screenshotController = ScreenshotController();
  @override
  void initState() {
    getAddress(globalController.getLattitude().value,
        globalController.getLongitude().value);
    super.initState();
  }

  // late final WeatherDataCurrent weatherDataCurrent;
  getAddress(lat, lon) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Không có kết nối mạng, lấy dữ liệu từ file data.json
      final prefs = await SharedPreferences.getInstance();
      final counter = prefs.getString('weatherData');
      String jsonString = json.encode(counter);
      dynamic jsonStringDe = jsonDecode(jsonString);
      jsonStringDe = jsonDecode(jsonStringDe) as Map<String, dynamic>;
      Map<String, dynamic> jsonStringData =
          jsonStringDe["jsonData"]["location"];

      setState(() {
        city = jsonStringData["name"];
      });
    } else {
      // Có kết nối mạng, lấy dữ liệu từ Firebase
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lon);
      // Placemark place = placemark[0];
      var first = placemark.first;
      // print(first);
      setState(() {
        // city = place.locality!;
        if (first.administrativeArea != "") {
          city = "${first.administrativeArea}";
        } else if (first.locality != "") {
          city = "${first.locality}";
        } else if (first.subAdministrativeArea != "") {
          city = "${first.subAdministrativeArea}";
        } else {
          city = "${first.country}";
        }
      });
    }
  }

  bool isMenuVisible = false;

  // Phương thức setter để cập nhật isMenuVisible
  void _showPopupMenu(BuildContext context) {
    // Thiết lập biến trạng thái để hiển thị menu và thay đổi màu của HeaderWidget

    // setState(() {
    //   appController.toggleMenuVisibility();

    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const HomeScreen()),
    //   );
    // });

    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 60, 10, 0),
      color: const Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'save',
          child: Container(
            padding: const EdgeInsets.only(left: 18),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey, // Màu sắc của đường viền
                  width: 0.5, // Độ dày của đường viền
                ),
              ),
            ),
            child: const ListTile(
              title: Text(
                'Save Position',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'share',
          child: Container(
            padding: const EdgeInsets.only(left: 18),
            child: const ListTile(
              title: Text(
                'Share',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'historyPage',
          child: Container(
            padding: const EdgeInsets.only(left: 18),
            child: const ListTile(
              title: Text(
                'Weather History',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
      
      ],
      
    ).then((value) async {
      // Xử lý khi menu đóng lại và thay đổi màu của HeaderWidget trở lại bình thường
      if (value == 'save') {
        await FetchWeatherAPI().processDataSavedPosition(
            globalController.getLattitude().value,
            globalController.getLongitude().value);
      } else if (value == 'share') {
        screenshotController
            .captureFromWidget(Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 5.0),
                  color: const Color.fromARGB(255, 142, 193, 235),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            city,
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            date,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Hiển thị nhiệt độ
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${globalController.weatherData.value.current?.current.temp?.toInt()}°C',
                                style: const TextStyle(
                                    fontSize: 100, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          // Hiển thị AQI
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AQI',
                                style: TextStyle(fontSize: 25),
                              ),
                              Text(
                                '${globalController.weatherData.value.current!.current.airQuality?.usepa}',
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )))
            .then((capturedImage) async {
          final directory = await getApplicationDocumentsDirectory();
          final imagePath = await File('${directory.path}/image.png').create();
          await imagePath.writeAsBytes(capturedImage);
          // ignore: deprecated_member_use
          await Share.shareFiles([imagePath.path]);
        });
        // print('Share selected');
      } else if (value == "historyPage") {
        Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WeatherHistoryScreen()),
                    );
      }
      setState(() {
        // appController.toggleMenuVisibility();
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const HomeScreen()),
        // );

        setState(() {
          isMenuVisible = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Check if the tap is outside the menu area
        if (isMenuVisible) {
          setState(() {
            isMenuVisible = false;
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 0, right: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  padding: const EdgeInsets.only(bottom: 30),
                  onPressed: () {
                    // NotificationService().showNotificationsAfterSecond();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchWeatherCity()),
                    );
                    // Xử lý khi nhấn vào biểu tượng "+"
                  },
                  color: Colors.white,
                ),
                Column(children: [
                  Container(
                    width: 200,
                    margin: const EdgeInsets.only(top: 15),
                    alignment: Alignment.topCenter,
                    child: Text(
                      city,
                      style: const TextStyle(
                          fontSize: 21, height: 2, fontWeight: FontWeight.w600, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    alignment: Alignment.topCenter,
                    child: Text(
                      date,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.white, height: 1.5),
                    ),
                  ),
                ]),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  padding: const EdgeInsets.only(bottom: 30),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final counter = prefs.getString('weatherData');

                    dynamic jsonString = json.decode(counter!);
                    String maxtempC =
                        "${jsonString["jsonData"]["forecast"]["forecastday"][0]["day"]["maxtemp_c"].toInt()}°C";
                    String mintempC =
                        "${jsonString["jsonData"]["forecast"]["forecastday"][0]["day"]["mintemp_c"].toInt()}°C";
                    String humidity = jsonString["jsonData"]["current"]
                            ["humidity"]
                        .toString();
                    String image =
                        "http:${jsonString["jsonData"]["current"]["condition"]["icon"]}";
                    String iconDay = "http:${jsonString["jsonData"]["forecast"]["forecastday"][0]["hour"][12]["condition"]["icon"]}";
                    String iconNight = "http:${jsonString["jsonData"]["forecast"]["forecastday"][0]["hour"][0]["condition"]["icon"]}";
                    String tempDay = "${jsonString["jsonData"]["forecast"]["forecastday"][0]["hour"][12]["temp_c"].toInt()}°C";
                    String tempNight = "${jsonString["jsonData"]["forecast"]["forecastday"][0]["hour"][0]["temp_c"].toInt()}°C";
                    NotificationService().showLocalNotification(image, maxtempC, humidity, iconDay, iconNight, tempDay, tempNight, mintempC);
                    
                    // ignore: use_build_context_synchronously
                    _showPopupMenu(context);
                  },
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
