


# Turkey Weather App - Project Introduction

  
### Project Introduction: Turkey Weather App  
  
This project is a **Turkey Weather App** developed using **Flutter**. The application allows users to easily access weather information for their selected city or current location. It also enhances the user experience with dynamic visuals and personalized city history features.  
  
---  
  
### Key Features:  
  
#### 1. **Real-Time Weather Information**  
- Users can access daily weather data for their selected city.  
- Data includes temperature, maximum and minimum temperatures, night temperature, humidity, and weather description.  
- Information is kept reliable and up-to-date via **CollectAPI**.  
  
#### 2. **Integrated with User Location**  
- The application detects the user’s current location using device location services and automatically fetches weather data for the detected city.  
  
#### 3. **Dynamic City Visuals**  
- Each city in Turkey is assigned a specific background image.  
- Users experience a personalized interface with aesthetic visuals for their selected city.  
  
#### 4. **Search and City Selection**  
- Users can search for cities from a comprehensive list of all cities.  
- While searching, cities are dynamically filtered based on user input.  
- Search results are displayed in a clear and user-friendly manner.  
  
#### 5. **City History Record**  
- Users can save previously searched cities using **SharedPreferences**.  
- City history is limited to a maximum of 8 cities, and old entries are automatically removed.  
- Users can easily access their city history without re-searching.  
  
#### 6. **User-Friendly Interface**  
- City and weather information is presented in a card structure for organized visual presentation.  
- Background images and dynamic clock display enrich the user experience.  
  
---  
  
### Technologies Used:  
  
#### **Flutter Framework**  
- The app is developed using Flutter technology for cross-platform compatibility.  
  
#### **API Integration**  
- Weather data is retrieved via **CollectAPI**.  
- Data accuracy and reliability are ensured.  
  
#### **Dio Library**  
- **Dio** is used to perform API requests efficiently and quickly.  
  
#### **Geolocator and Geocoding**  
- Used to obtain the user’s current location and determine the city name.  
  
#### **SharedPreferences**  
- Used to store user history and persist data on the device.  
  
---  
  
### Application Workflow:  
1. **Home Page:**  
- Displays weather data based on location or selected city.  
- Includes a dynamic clock and city background.  
  
2. **City Detail Page:**  
- Features city search and selection from a list of all cities.  
- Users can easily access previously searched cities.  
  
3. **Weather Service:**  
- Handles API integration to fetch and process weather data.  
- Detects user location and returns the corresponding city name.  
  
4. **City Images:**  
- Contains assigned images for all cities in Turkey.  
  
---  
  
### Conclusion:  
The Turkey Weather App aims to simplify users' daily lives by providing weather information in a visually pleasing and user-friendly interface. Its dynamic features and personalized details make it an ideal choice for weather updates.  
