import 'package:flutter/material.dart';
import 'package:scanner/qr_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        useMaterial3: true,
      ),
      home: const QRScanner(),
      debugShowCheckedModeBanner: false,
      title: 'QR Scanner',
    );
  }
}

// Pantalla de historial
class EnlacesGuardadosScreen extends StatefulWidget {
  const EnlacesGuardadosScreen({super.key});

  @override
  State<EnlacesGuardadosScreen> createState() => _EnlacesGuardadosScreenState();
}

class _EnlacesGuardadosScreenState extends State<EnlacesGuardadosScreen> {
  List<String> enlaces = [];

  @override
  void initState() {
    super.initState();
    cargarEnlaces();
  }

  Future<void> cargarEnlaces() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      enlaces = prefs.getStringList('enlaces') ?? [];
    });
  }

  Future<void> eliminarEnlace(int index) async {
    final prefs = await SharedPreferences.getInstance();
    enlaces.removeAt(index);
    await prefs.setStringList('enlaces', enlaces);
    setState(() {});
  }

  void abrirEnlace(String url) async {
    if (!url.startsWith("http")) {
      url = "https://$url";
    }
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial de enlaces")),
      body: enlaces.isEmpty
          ? const Center(child: Text("No hay enlaces guardados"))
          : ListView.builder(
              itemCount: enlaces.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.link, color: Colors.indigo),
                    title: Text(enlaces[index]),
                    onTap: () => abrirEnlace(enlaces[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => eliminarEnlace(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
