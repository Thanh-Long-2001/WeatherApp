class WeatherDataHourly {
  List<Hourly> hourly;

  WeatherDataHourly({required this.hourly});

  factory WeatherDataHourly.fromJson(Map<String, dynamic> json) {
    List<Hourly> forecastdayList = (json["forecast"]["forecastday"] as List)
        .map((forecastData) {
          List<Hourly> hourlyList = (forecastData["hour"] as List).map((hourly) {
            Map<Object?, Object?> hour = hourly;
            return Hourly.fromJson(hour.cast<String, dynamic>());
          }).toList();
          return hourlyList;
        })
        .expand((hourly) => hourly)
        .toList();

    return WeatherDataHourly(hourly: forecastdayList);
  }
}

class Hourly {
  int? dt;
  int? temp;
  Weather? weather;

  Hourly({this.dt, this.temp, this.weather});

  factory Hourly.fromJson(Map<String, dynamic> json) {
    return Hourly(
      dt: json['time_epoch'] as int?,
      temp: (json['temp_c'] as num?)?.round(),
      weather: (Weather.fromJson((json['condition']).cast<String, dynamic>())),
    );
  }
}

class Weather {
  int? id;
  String? main;
  String? description;
  String? icon;

  Weather({this.id, this.main, this.description, this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      id: json['id'] as int?,
      main: json['main'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
    );
  }
}
