import 'dart:async';
import 'dart:math'; // Rastgele şehir seçmek için
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:hava_durumu/models/wheather_model.dart';
import 'package:hava_durumu/services/wheater_service.dart';
import 'package:hava_durumu/models/city_images.dart';
import 'CityDetailPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentTime = '';
  Timer? _timer;
  List<WheatherModel> _weathers = [];
  String? _city;
  String? _randomCityImage;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky); // Bildirim çubuğunu gizle
    _setRandomCityImage(); // Rastgele şehir fotoğrafını ayarla
    _startClock();
    _initialWheatherData();
  }

  void _setRandomCityImage() {
    final random = Random();
    final cityKeys = cityImages.keys.toList(); // Şehirlerin anahtarlarını al
    final randomCity = cityKeys[random.nextInt(cityKeys.length)];
    setState(() {
      _randomCityImage = cityImages[randomCity];
    });
  }

  void _startClock() {
    _currentTime = DateFormat('HH:mm').format(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateFormat('HH:mm').format(DateTime.now());
      });
    });
  }

  void _initialWheatherData() async {
    try {
      String? cityFromLocation = await WheaterService().getLocation();
      _city = cityFromLocation ?? "İstanbul";
      _weathers = await WheaterService().getWeatherData(cityName: _city);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Konum bilgisi alınamadı: $e")),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? cityImage = cityImages[_city]; // Şehirle eşleşen resim

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _city == null
                    ? (_randomCityImage != null
                        ? AssetImage(_randomCityImage!)
                        : const AssetImage('assets/images/default.jpg'))
                    : (cityImage != null
                        ? AssetImage(cityImage)
                        : const AssetImage('assets/images/default.jpg')),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Şehir adı başlığı (sadece veri geldikten sonra gösterilir)
                if (_city != null)
                  GestureDetector(
                    onTap: () async {
                      final selectedCity = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CityDetailPage(city: _city!),
                        ),
                      );
                      if (selectedCity != null && selectedCity.isNotEmpty) {
                        setState(() {
                          _city = selectedCity; // Yeni seçilen şehri ayarla
                        });
                      }
                    },
                    child: Text(
                      _city!,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (_city == null) const SizedBox(height: 28), // Boş yer tutucu
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: _weathers.length,
                    itemBuilder: (context, index) {
                      final weather = _weathers[index];

                      double newDerece = double.parse(weather.derece);
                      int newDerece2 = newDerece.round();
                      double newMax = double.parse(weather.max);
                      int newMax2 = newMax.round();
                      double newMin = double.parse(weather.min);
                      int newMin2 = newMin.round();
                      double newGece = double.parse(weather.gece);
                      int newGece2 = newGece.round();
                      double newNem = double.parse(weather.nem);
                      int newNem2 = newNem.round();

                      String capitalize(String text) {
                        if (text.isEmpty) return text;
                        return text[0].toUpperCase() +
                            text.substring(1).toLowerCase();
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white.withOpacity(0.8),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weather.gun,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Image.network(
                                    weather.ikon,
                                    width: 40,
                                    height: 40,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                size: 40),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      capitalize(weather.durum),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${newDerece2}°C',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Max: ${newMax2}°C',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Min: ${newMin2}°C',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Gece: ${newGece2}°C',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Nem: ${newNem2}%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              _currentTime,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
