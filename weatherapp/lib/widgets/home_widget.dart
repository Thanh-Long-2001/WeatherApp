import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/utils/weather_type.dart';
import 'package:weatherapp_starter_project/model/weather.dart';
import 'package:weatherapp_starter_project/utils/custom_colors.dart';

class HomeWidget extends StatelessWidget {
  final Weather weather;

  const HomeWidget({
    Key? key,
    required this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Container(
      width: 170,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: WeatherUtil.getColor(weather.weatherType),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10))
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
            Image.network(weather.image),
            Text(weather.weather,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                // ignore: deprecated_member_use
                textScaleFactor: 1.7),
            ],
          ),        
          // Text(weather.cityName, style: const TextStyle(color: Colors.white60, fontSize: 30)),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: CustomColors.cardColor,
                        borderRadius: BorderRadius.circular(5)),
                    child: Image.asset("assets/icons/windspeed.png"),
                  ),
                  Container(
                    height: 30,
                    width: 30,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: CustomColors.cardColor,
                        borderRadius: BorderRadius.circular(5)),
                    child: Image.asset("assets/icons/clouds.png"),
                  ),
                  Container(
                    height: 30,
                    width: 30,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: CustomColors.cardColor,
                        borderRadius: BorderRadius.circular(5)),
                    child: Image.asset("assets/icons/humidity.png"),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 10,
                  width: 50,
                  child: Text(
                    "${weather.windspeed}km/h",
                    style: const TextStyle(fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 10,
                  width: 50,
                  child: Text(
                    "${weather.cloud}%",
                    style: const TextStyle(fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 10,
                  width: 50,
                  child: Text(
                    "${weather.humidity}%",
                    style: const TextStyle(fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            ],
          ) 
        ],
      ),
    );
  }
}

