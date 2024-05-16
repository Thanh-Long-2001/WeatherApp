import 'package:weatherapp_starter_project/api/api_key.dart';

String apiURL(var lat, var lon) {
  String url;

  // url = "https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&appid=$apiKey&units=metric&exclude=minutely";
  url =
      "http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$lat,$lon&days=8&aqi=yes&alerts=yes";
  return url;
}
