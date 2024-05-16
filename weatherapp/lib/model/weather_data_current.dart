

import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';

class WeatherDataCurrent {
  final Current current;
  final WeatherType? weatherType;
  WeatherDataCurrent( {required this.current, this.weatherType});

  factory WeatherDataCurrent.fromJson(Map<String, dynamic> json) {
    final currentData = (json['current']).cast<String, dynamic>();
    return WeatherDataCurrent(current: Current.fromJson(currentData));
  }

  get temp => null;
}

class Current {
  
  int? temp;
  int? humidity;
  int? airquality;
  int? clouds;
  double? uvIndex;
  double? feelsLike;
  double? windSpeed;
  Weather? weather;
  WeatherAir? airQuality;
  String? date;

  Current({
    this.temp,
    this.humidity,
    this.feelsLike,
    this.clouds,
    this.uvIndex,
    this.windSpeed,
    this.weather,
    this.airQuality,
    this.date,
  });

  factory Current.fromJson(Map<String, dynamic> json) => Current(
      temp: (json['temp_c'] as num?)?.round(),
      feelsLike: (json['feelslike_c'] as num?)?.toDouble(),
      humidity: json['humidity'] as int?,
      uvIndex: (json['uv'] as num?)?.toDouble(),
      clouds: json['cloud'] as int?,
      windSpeed: (json['wind_mph'] as num?)?.toDouble(),
      weather: (Weather.fromJson((json['condition']).cast<String, dynamic>())),
      airQuality:
          (WeatherAir.fromJson((json['air_quality']).cast<String, dynamic>())),
      date: json['last_updated'] as String?);

  Map<String, dynamic> toJson() => {
        'temp_c': temp,
        'feelslike_c': feelsLike,
        'uv': uvIndex,
        'humidity': humidity,
        'cloud': clouds,
        'wind_mph': windSpeed,
        'condition': weather,
        'last_updated': date,
      };
}

class WeatherAir {
  double? co;
  double? no2;
  double? o3;
  double? so2;
  double? pm25;
  double? pm10;
  int? usepa;

  WeatherAir(
      {this.co, this.no2, this.o3, this.pm10, this.pm25, this.so2, this.usepa});

  factory WeatherAir.fromJson(Map<String, dynamic> json) => WeatherAir(
        co: json['co'] .toDouble(),
        no2: json['no2'].toDouble(),
        o3: json['o3'].toDouble(),
        so2: json['so2'].toDouble(),
        pm10: json['pm10'].toDouble(),
        pm25: json['pm2_5'] .toDouble(),
        usepa: json['gb-defra-index'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'co': co,
        'no2': no2,
        'o3': o3,
        'so2': so2,
        'pm10': pm10,
        'pm2_5': pm25,
        'gb-defra-index': usepa,
      };
}

class Weather {
  int? id;
  // String? main;
  String? description;
  String? icon;

  Weather({this.id, this.description, this.icon});

  // from json
  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        id: json['code'] as int?,
        // main: json['main'] as String?,
        description: json['text'] as String?,
        icon: json['icon'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'code': id,
        // 'main': main,
        'text': description,
        'icon': icon,
      };
}
