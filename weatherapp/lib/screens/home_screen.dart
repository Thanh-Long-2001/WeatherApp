import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/utils/weather_type.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherapp_starter_project/api/fetch_weather.dart';
import 'package:weatherapp_starter_project/controller/app_controller.dart';
import 'package:weatherapp_starter_project/controller/global_controller.dart';
import 'package:weatherapp_starter_project/home_widget_config.dart';
import 'package:weatherapp_starter_project/model/weather.dart' as wt;
import 'package:weatherapp_starter_project/model/weather_data.dart';
import 'package:weatherapp_starter_project/utils/custom_colors.dart';
import 'package:weatherapp_starter_project/utils/extensions.dart';
import 'package:weatherapp_starter_project/widgets/comfort_level.dart';
import 'package:weatherapp_starter_project/widgets/current_weather_widget.dart';
import 'package:weatherapp_starter_project/widgets/daily_data_forecast.dart';
import 'package:weatherapp_starter_project/widgets/header_widget.dart';
import 'package:weatherapp_starter_project/widgets/home_widget.dart';
import 'package:weatherapp_starter_project/widgets/hourly_data_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // call

  wt.Weather? currentWeather;
  final AppController appController = Get.put(AppController(), permanent: true);
  final GlobalController globalController =
      Get.put(GlobalController(), permanent: true);
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    fetchData(); // Gọi phương thức fetchData từ initState
  }
  
  // ignore: unused_element
  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> fetchData() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Không có kết nối mạng, lấy dữ liệu từ file data.json
      await readDataFromJsonFile();
      globalController.setLoadingFalse();
    } else {
      // Có kết nối mạng, lấy dữ liệu từ Firebase
      await fetchDataFromFirebase();
    }
  }

  Future<void> fetchDataFromFirebase() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    DatabaseEvent event = await databaseReference.child('weatherData').once();
    var snapshotValue = event.snapshot.value;
    if (snapshotValue != null && snapshotValue is Map<dynamic, dynamic>) {
      var jsonData = (snapshotValue['jsonData']);
      writeDataToJsonFile(snapshotValue);
      bool hasBeenCalledToday = _prefs.getBool('hasBeenCalledToday') ?? false;
        if (!hasBeenCalledToday) {
          // Nếu chưa gọi trong ngày, thực hiện hàm và cập nhật trạng thái
          await writeDataHistoryToJsonFile(snapshotValue);
          _prefs.setBool('hasBeenCalledToday', true);
        }
      setState(() {
        currentWeather = wt.Weather(
            weatherType: WeatherUtil()
                .fromCode(jsonData["current"]["condition"]["code"].toInt()),
            weather: "${jsonData["current"]["temp_c"]?.toInt() ?? "--"}°C",
            desc: jsonData["current"]["condition"]["description"] ?? "--",
            image: "http:${jsonData["current"]["condition"]["icon"]}",
            cityName: jsonData["location"]["name"],
            windspeed: jsonData["current"]["wind_kph"].toString(),
            cloud: jsonData["current"]["cloud"].toString(),
            humidity: jsonData["current"]["humidity"].toString());
      });

      // ignore: use_build_context_synchronously
      HomeWidgetConfig.update(context, HomeWidget(weather: currentWeather!));
      setState(() {});
    }
  }

  Future<void> readDataFromJsonFile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final counter = prefs.getString('weatherData');

      String jsonString = json.encode(counter);

      await FetchWeatherAPI()
          .processDataLocal(jsonString)
          .then((value) => {globalController.weatherData.value = value});
    } catch (e) {
      // print('Error reading data.json: $e');
    }
  }

  Future<void> writeDataHistoryToJsonFile(Map<dynamic, dynamic> newData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Đọc dữ liệu từ SharedPreferences
      final jsonString = prefs.getString('weatherDataHistory');
      List<Map<dynamic, dynamic>> datajsonlist = [];

      // Nếu có dữ liệu, giải mã và gán cho datajsonlist
      if (jsonString != null) {
        datajsonlist = List<Map<dynamic, dynamic>>.from(jsonDecode(jsonString));
      }

      // Thêm phần tử mới vào cuối danh sách

      // Kiểm tra xem danh sách có nhiều hơn 30 phần tử hay không
      if (datajsonlist.length == 30) {
        // Nếu có, xóa phần tử đầu tiên
        datajsonlist.removeAt(0);
      }
      datajsonlist.add(newData);

      // Ghi danh sách đã được cập nhật vào SharedPreferences
      prefs.setString('weatherDataHistory', jsonEncode(datajsonlist));
    } catch (e) {
      print('Error writing to data.json: $e');
    }
  }

  Future<void> writeDataToJsonFile(Map<dynamic, dynamic> data) async {
    try {
      // File file = File("data/data.json");
      final prefs = await SharedPreferences.getInstance();
      String jsonString = jsonEncode(data);
      await prefs.setString("weatherData", jsonString);
    } catch (e) {
      // print('Error writing to data.json: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = appController.currentIndex;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Chặn nút quay lại trang trước
        return false;
      },
      child: Scaffold(
          body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) async {
            // Kiểm tra hướng vuốt

            if (details.primaryVelocity! < 0) {
              final databaseReference = FirebaseDatabase.instance.ref();
              DatabaseEvent event = await databaseReference
                  .child('weatherDataListPosition')
                  .once();
              Map<String, dynamic>? currentData =
                  jsonDecode(jsonEncode(event.snapshot.value))
                      as Map<String, dynamic>?;
              List<dynamic>? yourArray =
                  currentData?["jsonDataList"] as List<dynamic>?;
              if (yourArray != null) {
                // Duyệt qua mảng sử dụng forEach
                if (currentIndex < yourArray.length - 1) {
                  currentIndex++;
                  appController.pageIndexChanged(currentIndex);
                  var element = yourArray[currentIndex];
                  globalController.getLattitude().value =
                      element["location"]["lat"];

                  globalController.getLongitude().value =
                      element["location"]["lon"];

                  WeatherData weatherData = await FetchWeatherAPI()
                      .processDataSearch(element["location"]["lat"],
                          element["location"]["lon"]);
                  // Cập nhật dữ liệu thời tiết cho globalController hoặc nơi khác
                  globalController.weatherData.value = weatherData;
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType
                          .rightToLeft, // Loại hiệu ứng chuyển động
                      child: const HomeScreen(),
                      duration: const Duration(milliseconds: 200),
                    ),
                  );
                }
              }
            } else if (details.primaryVelocity! > 0) {
              final databaseReference = FirebaseDatabase.instance.ref();
              DatabaseEvent event = await databaseReference
                  .child('weatherDataListPosition')
                  .once();
              Map<String, dynamic>? currentData =
                  jsonDecode(jsonEncode(event.snapshot.value))
                      as Map<String, dynamic>?;
              List<dynamic>? yourArray =
                  currentData?["jsonDataList"] as List<dynamic>?;
              if (currentIndex > 0) {
                currentIndex--;
                appController.pageIndexChanged(currentIndex);
                var element = yourArray?[currentIndex];
                globalController.getLattitude().value =
                    element["location"]["lat"];
                globalController.getLongitude().value =
                    element["location"]["lon"];
                WeatherData weatherData = await FetchWeatherAPI()
                    .processDataSearch(
                        element["location"]["lat"], element["location"]["lon"]);
                globalController.weatherData.value = weatherData;
                // ignore: use_build_context_synchronously
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType
                        .leftToRight, // Loại hiệu ứng chuyển động
                    child: const HomeScreen(),
                    duration: const Duration(milliseconds: 200),
                  ),
                );
              }
            }
          },
          child: Obx(
            () => globalController.checkLoading().isTrue
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/clouds.png",
                          height: 200,
                          width: 200,
                        ),
                        const CircularProgressIndicator()
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                "assets/weather/background.png"), // Thay đổi đường dẫn hình ảnh
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          children: [
                            const HeaderWidget(),
                            // for our current temp ('current')
                            CurrentWeatherWidget(
                              weatherDataCurrent: globalController
                                  .getData()
                                  .getCurrentWeather(),
                            ),

                            HourlyDataWidget(
                              weatherDataHourly:
                                  globalController.getData().getHourlyWeather(),
                            ),
                            DailyDataForecast(
                              weatherDataDaily:
                                  globalController.getData().getDailyWeather(),
                              weatherDataCurrent: globalController
                                  .getData()
                                  .getCurrentWeather(),
                            ),
                            Container(
                              height: 1,
                              color: CustomColors.dividerLine,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ComfortLevel(
                              weatherDataCurrent: globalController
                                  .getData()
                                  .getCurrentWeather(),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      )),
    );
  }
}
