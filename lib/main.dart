import 'package:flutter/material.dart';
import 'screens/lista_compras_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Supermercado',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListaComprasScreen(),
    );
  }
}
