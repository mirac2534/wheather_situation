import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hava_durumu/models/wheather_model.dart';

class WheaterService {
  Future<String> getLocation() async {
    // We check to see if the user's location is clear
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Future.error("Konum kapali");
    }
    // We will check whether the user has given the location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      // If the location has not given permission, we will ask again
      if (permission == LocationPermission.denied) {
        // If he doesn't give it again, we'll return the error
        Future.error('Konum izni vermelisiniz');
      }
    }
    // We have taken the user's position
    final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy
            .high); // with high, we are indicating that I want to know the exact/clear location
    // We found the location point from the user position
    final List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    // We recorded our city from the location point
    final String? city = placemark[0].administrativeArea;
    if (city == null) Future.error('Bir sorun oluştu');
    print(city!.toString());
    return city!;
  }

  Future<List<WheatherModel>> getWeatherData({String? cityName}) async {
    String city;
    if (cityName != null) {
      // If the cityName parameter is full, use it
      city = cityName;
    } else {
      // If cityName is empty, get the city from the location information
      city = await getLocation();
    }

    final String url = // API that we use
        'https://api.collectapi.com/weather/getWeather?data.lang=tr&data.city=$city';

    const Map<String, dynamic> headers = {
      "authorization": "apikey 4I8DBYg8ETDeJrEZwwa0Pl:3Ht4IwjahVH2H75O2ecEDa",
      "content-type": "application/json"
    };

    final dio = Dio();
    final response = await dio.get(url, options: Options(headers: headers));
    if (response.statusCode != 200) {
      return Future.error("Bir sorun oluştu");
    }

    final List list = response.data['result'];
    final List<WheatherModel> weatherList =
        list.map((e) => WheatherModel.fromJson(e)).toList();

    return weatherList;
  }
}
