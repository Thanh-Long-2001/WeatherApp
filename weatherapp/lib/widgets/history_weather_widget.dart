import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class WeatherHistoryScreen extends StatefulWidget {
  const WeatherHistoryScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WeatherHistoryScreenState createState() => _WeatherHistoryScreenState();
}

class _WeatherHistoryScreenState extends State<WeatherHistoryScreen> {
  late DateTime _selectedDate;
  int selectedIndex = -1;
  Future<void> readDataFromJsonFile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('weatherDataHistory');

      if (jsonString != null) {
        List<Map<String, dynamic>> datajsonlist =
            List<Map<String, dynamic>>.from(jsonDecode(jsonString));

        // Tìm phần tử có ngày giống với ngày được chọn
        for (int i = 0; i < datajsonlist.length; i++) {
          DateTime dataDate = DateTime.parse(datajsonlist[i]['jsonData']
              ['location']['localtime']); // Thay 'date' bằng key thích hợp
          
          if (compareDates(dataDate, _selectedDate)) {
            selectedIndex = i;
         
            break; // Nếu tìm thấy index thích hợp, thoát khỏi vòng lặp
          } else {
            selectedIndex = -1;
          }
        }
        _showWeatherDetail(datajsonlist[selectedIndex]);
      }
    } catch (e) {
      print('Error reading data.json: $e');
    }
  }

  void _showWeatherDetail(Map<String, dynamic> weatherData) {
    String temperature =
        weatherData['jsonData']['current']['temp_c'].toString();
    String humidity = weatherData['jsonData']['current']['humidity'].toString();
    String windSpeed =
        weatherData['jsonData']['current']['wind_kph'].toString();
    String airQuality = weatherData['jsonData']['current']['air_quality']
            ['gb-defra-index']
        .toString();
    // Hiển thị thông tin thời tiết bằng AlertDialog hoặc làm gì đó khác với dữ liệu đã chọn
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Thông tin thời tiết',
            textAlign: TextAlign.center,
          ),

          // ignore: sized_box_for_whitespace
          content: Container(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatDate(DateTime.parse(
                      weatherData['jsonData']['location']['localtime'])),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                // Cột trái: Hiển thị nhiệt độ, độ ẩm, tốc độ gió, chất lượng không khí
                Column(
                  children: [
                    _buildInfoRow('Nhiệt độ', '$temperature °C'),
                    _buildInfoRow('Độ ẩm', '$humidity %'),
                    _buildInfoRow('Tốc độ gió', '$windSpeed kph'),
                    _buildInfoRow('Chất lượng không khí (UK)', airQuality),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool compareDates(DateTime date1, DateTime date2) {
    return _formatDate(date1) == _formatDate(date2);
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().subtract(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    readDataFromJsonFile();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử thời tiết'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (date) {
              return isSameDay(date, _selectedDate);
            },
            onDaySelected: (selectedDay, focusedDay) {
              // Kiểm tra nếu ngày được chọn không trong khoảng cho phép
              if (selectedDay.isAfter(DateTime.now()) ||
                  selectedDay.isBefore(
                      DateTime.now().subtract(const Duration(days: 30)))) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Thông báo'),
                      content: Text(
                          'Vui lòng chọn ngày từ ngày ${_formatDate(DateTime.now().subtract(const Duration(days: 30)))} đến ${_formatDate(DateTime.now())}'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Đóng'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                // Xử lý khi một ngày được chọn
                setState(() {
                  _selectedDate = selectedDay;
                });
                // Thêm bất kỳ xử lý khác bạn muốn thực hiện khi chọn một ngày
              }
            },
          ),
        ],
      ),
    );
  }
}
