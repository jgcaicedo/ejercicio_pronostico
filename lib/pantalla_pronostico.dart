
import 'dart:convert';

import 'package:ejercicio_prueba/api_key.dart';
import 'package:ejercicio_prueba/data.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PantallaPronostico extends StatefulWidget {
  const PantallaPronostico({super.key});

  @override
  State<PantallaPronostico> createState() => _PantallaPronosticoState();
}

class _PantallaPronosticoState extends State<PantallaPronostico> {

  Location location = Location();
  Data? data;
   List<Data> forecastData = [];

  @override
  void initState() {
    super.initState();
    getThreeDayForecast().then((data) {
      setState(() {
        forecastData = data;
      });
    });
  }
  



Future<List<Data>> getThreeDayForecast() async {
  final locationData = await location.getLocation();
  final apiKey = ApiKey.apiKey; 
  final lat = locationData.latitude;
  final lon = locationData.longitude;
  final url = 'http://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&lang=es';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);

    final now = DateTime.now();
    final threeDaysLater = now.add(Duration(days: 3));
    final forecastData = <Data>[];

    // Agrupar pronósticos por día
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

    // Seleccionar un pronóstico por día
    groupedByDay.forEach((date, dataList) {
      if (date != DateTime(now.year, now.month, now.day) && dataList.isNotEmpty) {
        forecastData.add(dataList[0]);
      }
    });

    return forecastData;
  } else {
    throw Exception('Error al cargar el pronóstico');
  }
}






  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Pronóstico'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: ListView.builder(
          itemCount: forecastData.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,children: [
                    Text(DateFormat('yyyy-MM-dd').format(forecastData[index].date)),
                  ],
                ),
                subtitle: Column(
                  children: [
                    Text('Temperatura: ${forecastData[index].temperature}°C'),
                    Text("Descripción: ${forecastData[index].description}"),
                      if (forecastData[index] != null && forecastData[index].icon != null)
                        Image.network('http://openweathermap.org/img/w/${forecastData[index].icon}.png'),
                  ],
                ),
                
              ),
            );
          },
        ),
      ),
    );
  }
}