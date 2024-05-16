import 'dart:async';
import 'dart:convert';
// import 'dart:js';
import 'package:firebase_database/firebase_database.dart';
// import 'package:get/get.dart';
// import 'package:weatherapp_starter_project/controller/global_controller.dart';
import 'package:weatherapp_starter_project/model/weather_data.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp_starter_project/model/weather_data_current.dart';
import 'package:weatherapp_starter_project/model/weather_data_daily.dart';
import 'package:weatherapp_starter_project/model/weather_data_hourly.dart';
import 'package:weatherapp_starter_project/utils/api_url.dart';
import 'package:weatherapp_starter_project/model/weather.dart' as wt;

class FetchWeatherAPI {
  WeatherData? weatherData;
  wt.Weather? currentWeather;
  final databaseReference = FirebaseDatabase.instance.ref();

  Future<WeatherData> processData(lat, lon) async {
    // Thử lấy dữ liệu từ Firebase Realtime Database trước
    DatabaseEvent event = await databaseReference.child('weatherData').once();

    if (event.snapshot.value != null) {
      var response = await http.get(Uri.parse(apiURL(lat, lon)));
      var jsonString = jsonDecode(response.body);
      saveDataToFirebase(jsonString);

      // Xử lý position đã lưu
      DatabaseEvent eventsaved =
          await databaseReference.child('weatherDataListPosition').once();
      Map<String, dynamic>? currentData =
          jsonDecode(jsonEncode(eventsaved.snapshot.value))
              as Map<String, dynamic>?;

      // Kiểm tra xem dữ liệu có tồn tại không
      List<dynamic>? yourArray = currentData?["jsonDataList"] as List<dynamic>?;

      // Kiểm tra xem mảng có giá trị không null
      if (yourArray != null) {
        // Duyệt qua mảng sử dụng forEach
        for (var element in yourArray) {
          // element là mỗi phần tử trong mảng, bạn có thể xử lý nó tại đây
          await FetchWeatherAPI().processUpdateDataSavedPosition(
              element["location"]["lat"], element["location"]["lon"]);
        }
      }

      DatabaseEvent eventnew =
          await databaseReference.child('weatherData').once();
      var snapshotValue = eventnew.snapshot.value;
      if (snapshotValue != null && snapshotValue is Map<dynamic, dynamic>) {
        var jsonData = (snapshotValue['jsonData']).cast<String, dynamic>();

        weatherData = WeatherData(
          WeatherDataCurrent.fromJson(jsonData),
          WeatherDataHourly.fromJson(jsonData),
          WeatherDataDaily.fromJson(jsonData),
        ); // Tiếp tục xử lý dữ liệu...
      }
    } else {
      var response = await http.get(Uri.parse(apiURL(lat, lon)));
      var jsonString = jsonDecode(response.body);
      saveDataToFirebase(jsonString);

      weatherData = WeatherData(
        WeatherDataCurrent.fromJson(jsonString),
        WeatherDataHourly.fromJson(jsonString),
        WeatherDataDaily.fromJson(jsonString),
      );
      // Xử lý trường hợp không có dữ liệu được trả về
    }

    return weatherData!;
  }

  Future<WeatherData> processDataSearch(lat, lon) async {
    // Thử lấy dữ liệu từ Firebase Realtime Database trước
    var response = await http.get(Uri.parse(apiURL(lat, lon)));
    var jsonString = jsonDecode(response.body);
    weatherData = WeatherData(
      WeatherDataCurrent.fromJson(jsonString),
      WeatherDataHourly.fromJson(jsonString),
      WeatherDataDaily.fromJson(jsonString),
    );
    // Xử lý trường hợp không có dữ liệu được trả v

    return weatherData!;
  }

  Future<WeatherData> processDataLocal(String data) async {
    // Thử lấy dữ liệu từ Firebase Realtime Database trước

    dynamic jsonString = jsonDecode(data);
    // print(jsonString);
    jsonString = jsonDecode(jsonString) as Map<String, dynamic>;
    Map<String, dynamic> jsonStringData = jsonString["jsonData"];
    
    weatherData = WeatherData(
      WeatherDataCurrent.fromJson(jsonStringData),
      WeatherDataHourly.fromJson(jsonStringData),
      WeatherDataDaily.fromJson(jsonStringData),
    );
    // Xử lý trường hợp không có dữ liệu được trả v

    return weatherData!;
  }

  Future<WeatherData> processDataSavedPosition(lat, lon) async {
    // Thử lấy dữ liệu từ Firebase Realtime Database trước
    var response = await http.get(Uri.parse(apiURL(lat, lon)));
    var jsonString = jsonDecode(response.body);
    // saveDataListToFirebase(jsonString);
    saveDataListToFirebase(jsonString);

    weatherData = WeatherData(
      WeatherDataCurrent.fromJson(jsonString),
      WeatherDataHourly.fromJson(jsonString),
      WeatherDataDaily.fromJson(jsonString),
    );
    // Xử lý trường hợp không có dữ liệu được trả v

    return weatherData!;
  }

  Future<void> processUpdateDataSavedPosition(lat, lon) async {
    var response = await http.get(Uri.parse(apiURL(lat, lon)));
    var jsonString = jsonDecode(response.body);

    // Lấy dữ liệu hiện tại từ Firebase Realtime Database
    DatabaseEvent event =
        await databaseReference.child('weatherDataListPosition').once();
    Map<String, dynamic>? currentData =
        jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>?;

    // Kiểm tra xem 'jsonDataList' đã tồn tại trong dữ liệu hiện tại hay chưa
    if (currentData != null && currentData['jsonDataList'] != null) {
      List<dynamic>? currentDataList =
          currentData["jsonDataList"] as List<dynamic>?;

      // Tìm vị trí của phần tử cần cập nhật trong danh sách

      for (int i = 0; i < currentDataList!.length; i++) {
        if (currentDataList[i]['location']['lat'] == lat &&
            currentDataList[i]['location']['lon'] == lon) {
          currentDataList[i] = jsonString;
          // Cập nhật dữ liệu trên Firebase Realtime Database
        }
      }
      databaseReference.child('weatherDataListPosition').update({
        'jsonDataList': currentDataList,
      });
    }
  }

  Future<void> saveDataListToFirebase(Map<String, dynamic> jsonString) async {
    // Lấy dữ liệu hiện tại từ Firebase Realtime Database
    DatabaseEvent event =
        await databaseReference.child('weatherDataListPosition').once();

    Map<String, dynamic>? currentData =
        jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>?;

    // Kiểm tra xem 'jsonDataList' đã tồn tại trong dữ liệu hiện tại hay chưa
    if (currentData != null && currentData['jsonDataList'] != null) {
      // Nếu đã tồn tại, thêm mới vào danh sách hiện tại
      List<dynamic> currentDataList = List.from(currentData['jsonDataList']);
      currentDataList.add(jsonString);
      databaseReference.child('weatherDataListPosition').update({
        'jsonDataList': currentDataList,
      });
      // Cập nhật dữ liệu trên Firebase Realtime Database
    } else {
      // Nếu 'jsonDataList' chưa tồn tại, tạo danh sách mới và thêm mới vào đó
      databaseReference.child('weatherDataListPosition').set({
        'jsonDataList': [jsonString],
      });
    }
  }

  void saveDataToFirebase(Map<String, dynamic> jsonString) {
    // Lưu toàn bộ jsonString vào Firebase Realtime Database
    databaseReference.child('weatherData').set({
      'jsonData': jsonString,
    });
  }

  Future<void> fetchDataAndUpdateDatabase(double lat, double lon) async {
    // Gọi API để lấy dữ liệu thời tiết
    var response = await http.get(Uri.parse(apiURL(lat, lon)));
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);

      // Lưu dữ liệu vào Firebase Realtime Database
      saveDataToFirebase(jsonString);

      // Cập nhật đối tượng weatherData
      weatherData = WeatherData(
        WeatherDataCurrent.fromJson(jsonString),
        WeatherDataHourly.fromJson(jsonString),
        WeatherDataDaily.fromJson(jsonString),
      );
    } else {
      // Xử lý trường hợp lỗi khi gọi API
      // print('Lỗi khi gọi API: ${response.statusCode}');
    }
  }

  void scheduleDataUpdate(lat, lon) {
    // Sử dụng Timer.periodic để lên lịch cập nhật mỗi 1 phút
    Timer.periodic(const Duration(minutes: 1), (Timer timer) async {
      await fetchDataAndUpdateDatabase(lat, lon);
    });
  }
}
