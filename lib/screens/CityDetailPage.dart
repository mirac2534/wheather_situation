import 'dart:convert'; // to read JSON file
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // to access rootBundle
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences
import 'package:hava_durumu/models/city_images.dart';

class CityDetailPage extends StatefulWidget {
  final String city;

  const CityDetailPage({Key? key, required this.city}) : super(key: key);

  @override
  _CityDetailPageState createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage> {
  late List<String> allCities = [];
  List<String> cityHistory =
      []; // City history (to be uploaded from SharedPreferences)
  List<String> filteredCities = []; // Search results Dec
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Read the history from SharedPreferences
    _loadCityHistory();

    // Read the city list from JSON
    _loadCities();

    // Refresh Decryption as the search text changes
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
        allCities.remove(widget.city); // Remove the current city
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
        // Add a new city to the city history
        cityHistory.insert(0, cityName);
      } else {
        // If the current city existed in the past, first take it out, then move it to the top
        cityHistory.remove(cityName);
        cityHistory.insert(0, cityName);
      }

      // If there are more than 8 cities in the past, delete the oldest city (at the end)
      if (cityHistory.length > 8) {
        cityHistory.removeLast();
      }
    });

    // Save updated history to SharedPreferences
    await _saveCityHistory();

    // Return the selected city
    Navigator.pop(context, cityName);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? cityImage =
        cityImages[widget.city]; // City background picture

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
                ? AssetImage(cityImage) // If you have a city picture, show it
                : const AssetImage(
                    'assets/images/default.jpg'), // default picture
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
              // the search bar
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
              // City history title
              const Text(
                "Şehir geçmişi:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // List of city history
              Expanded(
                child: cityHistory
                        .isEmpty // If you have never searched for a city, this bar will be empty
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
              // If the search bar is not empty, the list of cities
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
