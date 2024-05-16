import 'package:connectivity/connectivity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:weatherapp_starter_project/controller/app_controller.dart';
import 'package:weatherapp_starter_project/model/weather_data_current.dart';
import 'package:weatherapp_starter_project/model/weather_data_daily.dart';
import 'package:weatherapp_starter_project/utils/custom_colors.dart';
import 'air_quality_widget.dart';

class DailyDataForecast extends StatefulWidget {
  final WeatherDataCurrent weatherDataCurrent;
  final WeatherDataDaily weatherDataDaily;
  final AppController appController = Get.put(AppController(), permanent: true);

  DailyDataForecast(
      {Key? key,
      required this.weatherDataDaily,
      required this.weatherDataCurrent})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DailyDataForecastState createState() => _DailyDataForecastState();
}

class _DailyDataForecastState extends State<DailyDataForecast> {
  late WeatherDataCurrent weatherDataCurrent;
  late WeatherDataDaily weatherDataDaily;
  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị cho weatherDataCurrent và weatherDataDaily khi State được tạo
    weatherDataCurrent = widget.weatherDataCurrent;
    weatherDataDaily = widget.weatherDataDaily;
  }

  bool showAvg = false;
  // string manipulation

  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Container(
        height: 400,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: CustomColors.firstGradientColor,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(bottom: 10),
              child: const Text(
                "Next Days",
                style:
                    TextStyle(color: Colors.white, fontSize: 17),
              ),
            ),
            // dailyList(),
            DailyListWidget(weatherDataDaily: weatherDataDaily),
          ],
        ),
      ),
      SizedBox(
        width: 100,
        height: 40,
        child: TextButton(
          onPressed: () {
            setState(() {
              showAvg = !showAvg;
            });
          },
          child: Text(
            'Average',
            style: TextStyle(
              fontSize: 16,
              color: showAvg ? Colors.blue : Colors.white,
            ),
          ),
        ),
      ),
      AspectRatio(
        aspectRatio: 1.70,
        child: Padding(
          padding: const EdgeInsets.only(
            right: 18,
            left: 12,
            top: 24,
            bottom: 12,
          ),
          child: LineChart(
            showAvg ? avgData() : mainData(),
          ),
        ),
      ),
      InkWell(
        onTap: () {
          // Thực hiện chuyển hướng khi người dùng chạm vào "Air Quality"
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AirQualityDetailsScreen(
                      weatherDataCurrent: weatherDataCurrent,
                    )), // Thay thế AirQualityDetailsScreen bằng tên trang bạn muốn hiển thị
          );
        },
        child: Container(
          height: 110,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: CustomColors.firstGradientColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Air Quality",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/air-quality1.png',
                        width: 30,
                        height: 30,
                        color: Colors.green,
                      ),
                      Text(
                        "${weatherDataCurrent.current.airQuality?.usepa}",
                        style: const TextStyle(fontSize: 17, color: Colors.white),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                    width: 100,
                    child: Text(
                      "More Details >",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                      textAlign: TextAlign.center,
                  
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      )
    ]);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 16,
      color: Colors.white,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Mon', style: style);
        break;
      case 2:
        text = const Text('Tue', style: style);
        break;
      case 4:
        text = const Text('Wed', style: style);
        break;
      case 6:
        text = const Text('Thus', style: style);
        break;
      case 8:
        text = const Text('Fri', style: style);
        break;
      case 10:
        text = const Text('Sat', style: style);
        break;
      case 12:
        text = const Text('Sun', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: Colors.white
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0';
        break;
      case 20:
        text = '20';
        break;
      case 40:
        text = '40';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  LineChartData mainData() {
    
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.blue,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.blue,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: Colors.red), // Cạnh bên trái màu đỏ
          right: BorderSide(color: Colors.red), // Cạnh bên phải màu đỏ
          bottom: BorderSide(color: Colors.black), // Cạnh dưới màu đen
          top: BorderSide.none, // Cạnh trên màu đen
        ),
      ),
      minX: 0,
      maxX: 12,
      minY: 0,
      maxY: 50,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, weatherDataDaily.daily[0].avgTemp!.toDouble()),
            FlSpot(2, weatherDataDaily.daily[1].avgTemp!.toDouble()),
            FlSpot(4, weatherDataDaily.daily[2].avgTemp!.toDouble()),
            FlSpot(6, weatherDataDaily.daily[3].avgTemp!.toDouble()),
            FlSpot(8, weatherDataDaily.daily[4].avgTemp!.toDouble()),
            FlSpot(10, weatherDataDaily.daily[5].avgTemp!.toDouble()),
            FlSpot(12, weatherDataDaily.daily[6].avgTemp!.toDouble()),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    double avg = (weatherDataDaily.daily[0].avgTemp!.toDouble() +
        weatherDataDaily.daily[1].avgTemp!.toDouble() +
        weatherDataDaily.daily[2].avgTemp!.toDouble() +
        weatherDataDaily.daily[3].avgTemp!.toDouble() +
        weatherDataDaily.daily[4].avgTemp!.toDouble() +
        weatherDataDaily.daily[5].avgTemp!.toDouble() +
        weatherDataDaily.daily[6].avgTemp!.toDouble())/7;
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: false,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: Colors.red), // Cạnh bên trái màu đỏ
          right: BorderSide(color: Colors.red), // Cạnh bên phải màu đỏ
          bottom: BorderSide(color: Colors.black), // Cạnh dưới màu đen
          top: BorderSide.none, // Cạnh trên màu đen
        ),
      ),
      minX: 0,
      maxX: 12,
      minY: 0,
      maxY: 50,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, avg),
            FlSpot(2, avg),
            FlSpot(4, avg),
            FlSpot(6, avg),
            FlSpot(8, avg),
            FlSpot(10, avg),
            FlSpot(12, avg),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: Colors.cyan, end: Colors.blue).lerp(0.2)!,
              ColorTween(begin: Colors.cyan, end: Colors.blue).lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: Colors.cyan, end: Colors.blue)
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: Colors.cyan, end: Colors.blue)
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DailyListWidget extends StatelessWidget {
  final WeatherDataDaily weatherDataDaily;
  String getDay(final day) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(day * 1000);
    final x = DateFormat('EEE').format(time);
    return x;
  }

  const DailyListWidget({super.key, required this.weatherDataDaily});

  @override
  Widget build(BuildContext context) {
    return dailyList();
    // return FutureBuilder(
    //   future: dailyList(),
    //   builder: (context, AsyncSnapshot<Widget> snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       return snapshot.data ?? Container();
    //     } else {
    //       return const CircularProgressIndicator();
    //     }
    //   },
    // );
  }

  Widget dailyList() {
    var connectivityResult = Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    bool hasNetwork = connectivityResult != ConnectivityResult.none;
    // print(hasNetwork);
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: weatherDataDaily.daily.length > 7
            ? 7
            : weatherDataDaily.daily.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                  height: 60,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          getDay(weatherDataDaily.daily[index].dt),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                      if (hasNetwork)
                        SizedBox(
                          height: 30,
                          width: 30,
                          child: Image.network(
                              "http:${weatherDataDaily.daily[index].weather?.icon}"),
                        ),
                      Text(
                          "${weatherDataDaily.daily[index].dayTempType!.max}°/${weatherDataDaily.daily[index].dayTempType!.min}°", 
                          style: const TextStyle(
                            color: Colors.white
                            ),
                      )
                    ],
                  )),
              Container(
                height: 1,
                color: Colors.white,
              )
            ],
          );
        },
      ),
    );
  }
}
