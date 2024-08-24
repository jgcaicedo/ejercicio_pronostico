import 'package:ejercicio_prueba/api_key.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import 'package:ejercicio_prueba/data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PantallaInicial extends StatefulWidget {
  const PantallaInicial({Key? key}) : super(key: key);

  @override
  State<PantallaInicial> createState() => _PantallaInicialState();
}

class _PantallaInicialState extends State<PantallaInicial> {
  Location location = Location();
  Data? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    permisosLocalizacion();
  }

  Future<void> permisosLocalizacion() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _obtenerDatos();
    }
  }

  Future<void> _obtenerDatos() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      final locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lon = locationData.longitude;
      final apiKey = ApiKey.apiKey;
      final url =
          'http://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&lang=es';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          data = Data.fromJson(jsonData);
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar el pronóstico');
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Pantalla Inicial")),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: FutureBuilder<Data?>(
                  future: Future.value(data),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Error: ${snapshot.error}",
                            style: TextStyle(color: Colors.red)),
                      );
                    } else {
                      final datosCargados = snapshot.data ?? data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  _obtenerDatos();
                                  setState(() {});
                                },
                                icon: Icon(Icons.loop, color: Colors.blue),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Text(
                              "${datosCargados?.temperature}°C",
                              style: TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                              "${datosCargados?.description}",
                              style: TextStyle(fontSize: 20, color: Colors.grey),
                            ),
                          ),
                          SizedBox(height: 20),
                          if (datosCargados != null && datosCargados.icon != null)
                            Center(
                              child: Transform.scale(
                                scale: 2,
                                child: Image.network(
                                    'http://openweathermap.org/img/w/${datosCargados.icon}.png'),
                              ),
                            ),
                          SizedBox(height: 100),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/paginaPronostico');
                              },
                              child: const Text(
                                "Ver Pronóstico",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
      ),
    );
  }
}
