import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:weatherapp_starter_project/controller/app_controller.dart';
import 'package:weatherapp_starter_project/controller/global_controller.dart';
import 'package:weatherapp_starter_project/model/weather_data_hourly.dart';
import 'package:weatherapp_starter_project/utils/custom_colors.dart';

// ignore: must_be_immutable
class HourlyDataWidget extends StatelessWidget {
  final WeatherDataHourly weatherDataHourly;
  final AppController appController = Get.put(AppController(), permanent: true);
  HourlyDataWidget({Key? key, required this.weatherDataHourly})
      : super(key: key);

  // card index
  RxInt cardIndex = GlobalController().getIndex();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          alignment: Alignment.topCenter,
          child: const Text("Today", style: TextStyle(fontSize: 18, color: Colors.white,)),
        ),
        hourlyList(),
      ],
    );
  }

  Widget hourlyList() {
    return Container(
      height: 160,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weatherDataHourly.hourly.length,
        itemBuilder: (context, index) {
          return Obx((() => GestureDetector(
              onTap: () {
                cardIndex.value = index;
              },
              child: Container(
                width: 90,
                margin: const EdgeInsets.only(left: 20, right: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: CustomColors.firstGradientColor,
                    boxShadow: [
                      BoxShadow(
                          offset: const Offset(0.8, 0),
                          blurRadius: 30,
                          spreadRadius: 1,
                          color: const Color.fromARGB(255, 255, 255, 255).withAlpha(30))
                    ],
                    gradient: cardIndex.value == index
                        ? const LinearGradient(colors: [
                            Color.fromARGB(255, 222, 198, 64),
                            Color.fromARGB(255, 205, 197, 82)
                          ])
                        : null),
                child: HourlyDetails(
                  index: index,
                  cardIndex: cardIndex.toInt(),
                  temp: weatherDataHourly.hourly[index].temp?? 0,
                  timeStamp: weatherDataHourly.hourly[index].dt?? 0,
                  weatherIcon:
                      weatherDataHourly.hourly[index].weather!.icon!,
                ),
              ))));
        },
      ),
    );
  }
}

// hourly details class
// ignore: must_be_immutable
class HourlyDetails extends StatelessWidget {
  int temp;
  int index;
  int cardIndex;
  int timeStamp;
  String weatherIcon;

  HourlyDetails(
      {Key? key,
      required this.cardIndex,
      required this.index,
      required this.timeStamp,
      required this.temp,
      required this.weatherIcon})
      : super(key: key);
  String getTime(final timeStamp) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    String x = DateFormat('jm').format(time);
    return x;
  }

  @override
  Widget build(BuildContext context)  {
    var connectivityResult =  Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    bool hasNetwork = connectivityResult != ConnectivityResult.none;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: Text(getTime(timeStamp),
              style: const TextStyle(
                color: Colors.white
              )),
        ),
        if(hasNetwork)
        Container(
            margin: const EdgeInsets.all(5),
            child: Image.network(
              "http:$weatherIcon",
              height: 40,
              width: 40,
            )),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Text("$temp°",
              style: const TextStyle(
                color: Colors.white
              )),
        )
      ],
    );
  }

  // Widget build(BuildContext context) {
    
  //   return FutureBuilder<bool>(
  //     future: _checkConnectivity(),
  //     builder: (context, snapshot) {
  //       bool hasNetwork = snapshot.data ?? false;

  //       return Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           Container(
  //             margin: const EdgeInsets.only(top: 10),
  //             child: Text(
  //               getTime(timeStamp),
  //               style: TextStyle(
  //                 color: cardIndex == index
  //                     ? Colors.white
  //                     : CustomColors.textColorBlack,
  //               ),
  //             ),
  //           ),
  //           if(hasNetwork)
  //           Container(
  //             margin: const EdgeInsets.all(5),
  //             child: Image.network(
  //               "http:$weatherIcon", // Show image only if there is network
  //               height: 40,
  //               width: 40,
  //             ),
  //           ),
  //           Container(
  //             margin: const EdgeInsets.only(bottom: 10),
  //             child: Text(
  //               "$temp°",
  //               style: TextStyle(
  //                 color: cardIndex == index
  //                     ? Colors.white
  //                     : CustomColors.textColorBlack,
  //               ),
  //             ),
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }

  // bool _checkConnectivity()  {
    
  // }
}
