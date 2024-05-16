import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';

class Weather {
  final WeatherType weatherType;
  final String weather;
  final String cityName;
  final String desc;
  final String image;
  final String windspeed;
  final String cloud;
  final String humidity;

  Weather(
      {required this.weatherType,
      required this.weather,
      required this.desc,
      required this.image,
      required this.cityName,
      required this.windspeed,
      required this.cloud,
      required this.humidity
      });
}
