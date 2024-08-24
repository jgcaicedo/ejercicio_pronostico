import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ejercicio_prueba/api_key.dart';
import 'package:ejercicio_prueba/data.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class PantallaPronostico extends StatefulWidget {
  const PantallaPronostico({super.key});

  @override
  State<PantallaPronostico> createState() => _PantallaPronosticoState();
}

class _PantallaPronosticoState extends State<PantallaPronostico> {
  Location location = Location();
  List<Data> forecastData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _checkInternetAndPermissions();
  }

  Future<void> _checkInternetAndPermissions() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      await _checkInternetConnection();
    } else {
      setState(() {
        errorMessage = "Permiso de ubicación denegado.";
        isLoading = false;
      });
    }
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        errorMessage = "No hay conexión a Internet.";
        isLoading = false;
      });
    } else {
      await getThreeDayForecast();
    }
  }

  Future<void> getThreeDayForecast() async {
  try {
    final locationData = await location.getLocation();
    final apiKey = ApiKey.apiKey;
    final lat = locationData.latitude;
    final lon = locationData.longitude;
    final url =
        'http://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&lang=es&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final now = DateTime.now();
      final threeDaysLater = now.add(Duration(days: 3));
      final forecastData = <Data>[];

      final groupedByDay = <DateTime, List<Data>>{};

      (jsonData['list'] as List).forEach((data) {
        final dataObject = Data.fromJson(data);
        final date = dataObject.date;

        if (date.isAfter(now) && date.isBefore(threeDaysLater)) {
          final dateWithoutTime = DateTime(date.year, date.month, date.day);

          if (!groupedByDay.containsKey(dateWithoutTime)) {
            groupedByDay[dateWithoutTime] = <Data>[];
          }

          groupedByDay[dateWithoutTime]!.add(dataObject);
        }
      });

      groupedByDay.forEach((date, dataList) {
        if (date != DateTime(now.year, now.month, now.day) &&
            dataList.isNotEmpty) {
          // Calcular la temperatura mínima y máxima del día
          double minTemp = dataList.first.temp_min;
          double maxTemp = dataList.first.temp_max;

          for (var data in dataList) {
            if (data.temp_min < minTemp) minTemp = data.temp_min;
            if (data.temp_max > maxTemp) maxTemp = data.temp_max;
          }

          // Crear un nuevo Data con la temp_min y temp_max correctas
          final dayData = Data(
            description: dataList.first.description,
            temperature: dataList.first.temperature,
            icon: dataList.first.icon,
            date: date,
            temp_min: minTemp,
            temp_max: maxTemp,
          );

          forecastData.add(dayData);
        }
      });

      setState(() {
        this.forecastData = forecastData;
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = "Error al cargar los datos del pronóstico.";
        isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      errorMessage = "Error: $e";
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pronóstico'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: forecastData.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('EEEE, dd MMMM')
                                      .format(forecastData[index].date),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                SizedBox(height: 10),
                                if (forecastData[index].icon != null)
                                  Image.network(
                                    'http://openweathermap.org/img/w/${forecastData[index].icon}.png',
                                    scale: 0.7,
                                  ),
                                SizedBox(height: 10),
                                Text(
                                  'Máx: ${forecastData[index].temp_max}°C',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                Text(
                                  'Mín: ${forecastData[index].temp_min}°C',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  forecastData[index].description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
