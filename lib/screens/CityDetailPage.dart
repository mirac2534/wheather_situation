import 'dart:convert'; // JSON dosyasını okumak için
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // rootBundle erişimi için
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences
import 'package:hava_durumu/models/city_images.dart'; // Şehir resimlerini içeren harita

class CityDetailPage extends StatefulWidget {
  final String city;

  const CityDetailPage({Key? key, required this.city}) : super(key: key);

  @override
  _CityDetailPageState createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage> {
  late List<String> allCities = [];
  List<String> cityHistory =
      []; // Şehir geçmişi (SharedPreferences'tan yüklenecek)
  List<String> filteredCities = []; // Arama sonuçları
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // SharedPreferences'tan geçmişi oku
    _loadCityHistory();

    // JSON'dan şehir listesini oku
    _loadCities();

    // Arama metni değiştikçe filtrelemeyi yenile
    searchController.addListener(() {
      setState(() {
        if (searchController.text.isNotEmpty) {
          filteredCities = allCities
              .where((city) => city
                  .toLowerCase()
                  .startsWith(searchController.text.toLowerCase()))
              .toList();
        } else {
          filteredCities = [];
        }
      });
    });
  }

  Future<void> _loadCities() async {
    try {
      final String response =
          await rootBundle.loadString('lib/models/cities.json');
      final List<dynamic> cities = json.decode(response);

      setState(() {
        allCities = List<String>.from(cities);
        allCities.remove(widget.city); // Mevcut şehri çıkar
        filteredCities = [];
      });
    } catch (e) {
      print("Şehirler yüklenirken hata oluştu: $e");
    }
  }

  Future<void> _loadCityHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cityHistory = prefs.getStringList('cityHistory') ?? [];
    });
  }

  Future<void> _saveCityHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cityHistory', cityHistory);
  }

  void _onCitySelected(String cityName) async {
    setState(() {
      if (!cityHistory.contains(cityName)) {
        // Şehir geçmişine yeni şehir ekle
        cityHistory.insert(0, cityName);
      } else {
        // Mevcut şehir geçmişte varsa, önce çıkar, sonra en üste taşı
        cityHistory.remove(cityName);
        cityHistory.insert(0, cityName);
      }

      // Eğer geçmişte 10'dan fazla şehir varsa, en eski şehri (sondaki) sil
      if (cityHistory.length > 8) {
        cityHistory.removeLast();
      }
    });

    // Güncellenen geçmişi SharedPreferences'a kaydet
    await _saveCityHistory();

    // Seçilen şehri geri döndür
    Navigator.pop(context, cityName);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? cityImage = cityImages[widget.city]; // Şehir arka plan resmi

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Arama Menüsü',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: cityImage != null
                ? AssetImage(cityImage) // Şehir resmi varsa göster
                : const AssetImage(
                    'assets/images/default.jpg'), // Varsayılan resim
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mevcut şehir başlığı
              Text(
                'Mevcut Şehir: ${widget.city}',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              // Arama çubuğu
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Şehir ara',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.lightBlueAccent,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.lightBlueAccent,
                      width: 2.0,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.lightBlueAccent,
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),
              // Şehir geçmişi başlığı
              const Text(
                "Şehir geçmişi:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Şehir geçmişi listesi
              Expanded(
                child: cityHistory.isEmpty
                    ? const Text("Henüz bir şehir aratmadın.")
                    : ListView.builder(
                        itemCount: cityHistory.length,
                        itemBuilder: (context, index) {
                          final cityName = cityHistory[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.5),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, cityName);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: Text(
                                cityName,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              // Eğer arama çubuğu boş değilse şehirler listesi
              if (searchController.text.isNotEmpty)
                const Text(
                  "Şehirler:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              if (searchController.text.isNotEmpty) const SizedBox(height: 10),
              if (searchController.text.isNotEmpty)
                Expanded(
                  child: filteredCities.isEmpty
                      ? const Center(child: Text("Şehir bulunamadı"))
                      : ListView.builder(
                          itemCount: filteredCities.length,
                          itemBuilder: (context, index) {
                            final cityName = filteredCities[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: ElevatedButton(
                                onPressed: () => _onCitySelected(cityName),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade100,
                                ),
                                child: Text(
                                  cityName,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            );
                          },
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
