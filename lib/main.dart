import 'package:ejercicio_prueba/pantalla_inicial.dart';
import 'package:ejercicio_prueba/pantalla_pronostico.dart';
import 'package:flutter/material.dart';


void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  
   MyApp({super.key});

  // This widget is the root of your application.

  
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
      ),
      home: const PantallaInicial(),
      debugShowCheckedModeBanner: false,
      routes: { 
              '/paginaPronostico': (context) => const PantallaPronostico(),
              '/paginaInicial':(context) => const PantallaInicial()
              }

    );
  }
}

