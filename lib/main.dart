import 'package:flutter/material.dart';
import 'package:scanner_qr/qr_Scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),

      home: const QRScanner(),
      debugShowCheckedModeBanner: false,
      title: 'QR Scanner',
    );
  }
}
