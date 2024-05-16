// air_quality_details_screen.dart

import 'package:flutter/material.dart';
import 'package:weatherapp_starter_project/model/weather_data_current.dart';
import 'package:weatherapp_starter_project/utils/custom_colors.dart';
// import 'package:weatherapp_starter_project/widgets/header_widget.dart';

class AirQualityDetailsScreen extends StatelessWidget {
  final WeatherDataCurrent weatherDataCurrent;

  const AirQualityDetailsScreen({super.key, required this.weatherDataCurrent});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 700,
            margin: const EdgeInsets.only(left: 10, right: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: CustomColors.dividerLine.withAlpha(150),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: const Text(
                    "Air Quality Information",
                    style: TextStyle(
                      color: CustomColors.textColorBlack,
                      fontSize: 25,
                    ),
                  ),
                ),

                Container(
                  alignment: Alignment.topCenter,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    "${weatherDataCurrent.current.date}",
                    style: const TextStyle(
                      color: CustomColors.textColorBlack,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            height: 30,
                            width: 60,
                            child: Text(
                              "${weatherDataCurrent.current.airQuality?.pm25}",
                              style: const TextStyle(
                                  fontSize: 22, color: Colors.green),
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                            height: 30,
                            width: 60,
                            child: Text(
                              "${weatherDataCurrent.current.airQuality?.pm10}",
                              style: const TextStyle(
                                  fontSize: 22, color: Colors.green),
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                            height: 30,
                            width: 60,
                            child: Text(
                              "${weatherDataCurrent.current.airQuality?.so2}",
                              style: const TextStyle(
                                  fontSize: 22, color: Colors.green),
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                            height: 30,
                            width: 50,
                            child: Text(
                              "${weatherDataCurrent.current.airQuality?.no2}",
                              style: const TextStyle(
                                  fontSize: 22, color: Colors.green),
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                            height: 30,
                            width: 40,
                            child: Text(
                              "${weatherDataCurrent.current.airQuality?.o3}",
                              style: const TextStyle(
                                  fontSize: 22, color: Colors.green),
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                            height: 30,
                            width: 70,
                            child: Text(
                              "${weatherDataCurrent.current.airQuality?.co}",
                              style: const TextStyle(
                                  fontSize: 22, color: Colors.green),
                              textAlign: TextAlign.center,
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                            height: 20,
                            width: 40,
                            child: Text(
                              "PM2.5",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.green),
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                            height: 20,
                            width: 40,
                            child: Text(
                              "PM10",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.green),
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                            height: 20,
                            width: 40,
                            child: Text(
                              "SO2",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.green),
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                            height: 20,
                            width: 40,
                            child: Text(
                              "NO2",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.green),
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                            height: 20,
                            width: 40,
                            child: Text(
                              "O3",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.green),
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                            height: 20,
                            width: 40,
                            child: Text(
                              "CO",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.green),
                              textAlign: TextAlign.center,
                            )),
                      ],
                    )
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),
                // Thêm các phần khác của nội dung trong Container ở đây nếu cần
                NumberContainer(weatherDataCurrent: weatherDataCurrent),

                const SizedBox(
                  height: 10,
                ),

                const SizedBox(
                  child: Text(
                    "NOTIFICATION",
                    style: TextStyle(fontSize: 25, color: Color.fromARGB(255, 255, 137, 59)),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Số bạn muốn hiển thị),
                WarningContainer(weatherDataCurrent: weatherDataCurrent,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WarningContainer extends StatelessWidget {
  final WeatherDataCurrent weatherDataCurrent;
  const WarningContainer({super.key, required this.weatherDataCurrent});

  @override
  Widget build(BuildContext context) {
    int airQualityIndex = weatherDataCurrent.current.airQuality?.usepa ?? 0;
    String airQualityText = getAirQualityText(airQualityIndex);
    return SizedBox(
      width: 300,
      height: 300,
      child: Text(
      airQualityText,
      style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 172, 155, 4)),
        textAlign: TextAlign.center,
      ), 
    );
  }

  String getAirQualityText(int airQualityIndex) {
  if (airQualityIndex >= 1 && airQualityIndex <= 3) {
    return "Enjoy your usual outdoor activities.";
  } else if (airQualityIndex >= 4 && airQualityIndex <= 6) {
    return "Adults and children with lung problems, and adults with heart problems, who experience symptoms, should consider reducing strenuous physical activity, particularly outdoors.";
  } else if (airQualityIndex >= 7 && airQualityIndex <= 9) {
    return "Adults and children with lung problems, and adults with heart problems, should reduce strenuous physical exertion, particularly outdoors, and particularly if they experience symptoms. People with asthma may find they need to use their reliever inhaler more often. Older people should also reduce physical exertion.";
  } else if (airQualityIndex == 10) {
    return "Adults and children with lung problems, adults with heart problems, and older people, should avoid strenuous physical activity. People with asthma may find they need to use their reliever inhaler more often.";
  } else {
    return "Air quality information not available.";
  }
}
}

class NumberContainer extends StatelessWidget {
  final WeatherDataCurrent weatherDataCurrent;

  const NumberContainer({Key? key, required this.weatherDataCurrent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int usepa = weatherDataCurrent.current.airQuality?.usepa ?? 0;
    // Các bước khác tương tự
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: Colors.green,
          width: 3.0,
        ), // Độ rộng của vành
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          usepa.toString(),
          style: const TextStyle(
            color: Color.fromARGB(255, 9, 124, 13),
            fontSize: 34.0,
          ),
        ),
        const Text("Air Quality",
            style: TextStyle(
              color: Color.fromARGB(255, 104, 95, 17),
              fontSize: 14.0,
            )),
        const Text("UK",
            style: TextStyle(
              color: Color.fromARGB(255, 104, 95, 17),
              fontSize: 14.0,
            ))
      ]),
    );
  }
}
