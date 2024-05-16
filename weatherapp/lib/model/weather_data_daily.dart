class WeatherDataDaily {
  List<Daily> daily;
  

  WeatherDataDaily({required this.daily});

  factory WeatherDataDaily.fromJson(Map<String, dynamic> json) {
    List<Daily> forecastday = (json["forecast"]["forecastday"] as List).map((forecastData) {
      int dt1 = forecastData["date_epoch"];
      Daily dailyData = Daily.fromJson((forecastData["day"]).cast<String, dynamic>(), dt1);
      return dailyData;
    }).toList();

    // String dt = (json["forecast"]["forecastday"] as List).map((forecastData) {
    //   String dt1 = forecastData["date_epoch"];
    //   return dt1;
    // }).toString();
    
    return WeatherDataDaily(daily: forecastday);
  }
}

class Daily {
  int? dt;
  int? avgTemp;
  Temp? dayTempType;

  Weather? weather;

  Daily({
    this.dt,
    this.avgTemp,
    this.weather,
    this.dayTempType,
  });

  factory Daily.fromJson(Map<String, dynamic> json, int dt) => Daily(
        dt: dt,
        avgTemp: (json['avgtemp_c']).toInt(),
        // ignore: unnecessary_null_comparison
        dayTempType: json == null
            ? null
            // ignore: unnecessary_cast
            : Temp.fromJson(json as Map<String, dynamic>),
        weather: (Weather.fromJson((json['condition'].cast<String, dynamic>()) )),
      );

  Map<String, dynamic> toJson() => {
        'dt': dt,
        'temp': avgTemp,
        'condition': weather,
      };
}

class Temp {
  double? day;
  int? min;
  int? max;
  double? night;
  double? eve;
  double? morn;

  Temp({this.day, this.min, this.max, this.night, this.eve, this.morn});

  factory Temp.fromJson(Map<String, dynamic> json) => Temp(
        day: (json['avgtemp_c'] as num?)?.toDouble(),
        min: (json['mintemp_c'] as num?)?.round(),
        max: (json['maxtemp_c'] as num?)?.round(),
        // night: (json['night'] as num?)?.toDouble(),
        // eve: (json['eve'] as num?)?.toDouble(),
        // morn: (json['morn'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'min': min,
        'max': max,
        // 'night': night,
        // 'eve': eve,
        // 'morn': morn,
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
