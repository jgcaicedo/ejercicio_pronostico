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
    //iniciamos apenas se lanze la app los permisos de localizacion
    permisosLocalizacion();
  }

  Future<void> permisosLocalizacion() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      //si los penmisos fueron aceptados entonces se lanza obtenerLocalizacion
      _obtenerDatos();
    } else {
      // Maneja el caso en el que el usuario no otorga permisos
    }
  }

 
   Future<void> _obtenerDatos() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      final locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lon = locationData.longitude;
      final apiKey = ApiKey.apiKey;
      final url = 'http://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&lang=es';

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
      // Maneja el caso en el que el usuario no otorga permisos
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
        body: isLoading?Center(child: CircularProgressIndicator()):
        Padding(
          padding: const EdgeInsets.all(15),
          child: FutureBuilder<Data?>(
            future:  Future.value(data) , // Llamamos a obtenerLocalizacionData() solo si data es nulo
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Muestra un indicador de carga mientras los datos se están recuperando
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Si no obtiene datos error
                return Text("Error: ${snapshot.error}");
              } else {
                // Los datos se han cargado correctamente, muestra la información
                final datosCargados = snapshot.data ?? data; // Usa los datos cargados o los existentes si aún son nulos
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        
                        IconButton(
                          onPressed: () async {
                              //recarga los datos de la pantalla 
                              _obtenerDatos();
                              setState(() {
                                
                              });
                          },
                          icon: Icon(Icons.loop),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),                    
                    Center(child: Text("${datosCargados?.temperature}°C",style: TextStyle(fontSize: 20))),
                    SizedBox(height: 5,),                    
                    Center(child: Text("${datosCargados?.description}",style: TextStyle(fontSize: 20))),
                    SizedBox(height: 5,),                    
                    if (datosCargados != null && datosCargados.icon != null)
                      Center(child: Transform.scale(scale: 1.5,child: Image.network('http://openweathermap.org/img/w/${datosCargados.icon}.png',))),
          
                    SizedBox(height: 100,),
                    Center(
                      child: TextButton(
                      style:  ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue), 
                        padding: MaterialStateProperty.all(EdgeInsets.all(10)), 
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), 
                        )),
                        foregroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 255, 255, 255)),
                        textStyle: MaterialStateProperty.all(const TextStyle(
                          fontSize: 16, 
                        )),
                      ),
                        onPressed: () {
                          //navega a la pantalla pronostico
                          Navigator.pushNamed(context, '/paginaPronostico');
                        },
                        child: const Text("Pronóstico"),
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
