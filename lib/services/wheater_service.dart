import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hava_durumu/models/wheather_model.dart';

class WheaterService {
  Future<String> getLocation() async {
    // Kullanicinin konumu acik mi diye kontrol ettik
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Future.error("Konum kapali");
    }
    // Kullanici konum izmi vermis mi kontrol ettik
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      // Konum izni vermemisse tekrardan istedik
      if (permission == LocationPermission.denied) {
        // Yine vermemisse hata dondurduk
        Future.error('Konum izni vermelisiniz');
      }
    }
    // Kullanicinin pozisyonunu aldik
    final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy
            .high); // high ile kesin/net konum bilmek istedigimi belirtmis oluyorum
    // Kullanici pozisyonundan yerlesim noktasini bulduk
    final List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    // Sehrimizi yerlesim noktasindan kaydettik
    final String? city = placemark[0].administrativeArea;
    if (city == null) Future.error('Bir sorun oluştu');
    print(city!.toString());
    return city!;
  }

  Future<List<WheatherModel>> getWeatherData({String? cityName}) async {
    String city;
    if (cityName != null) {
      // Eğer cityName parametresi dolu gelmişse onu kullan
      city = cityName;
    } else {
      // cityName boşsa konum bilgisinden şehri al
      city = await getLocation();
    }

    final String url =
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
