import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> agregarAFavoritos(String code) async {
  final prefs = await SharedPreferences.getInstance();

  // Obtener lista actual
  List<String> favoritos = prefs.getStringList('favoritos') ?? [];

  // Evitar duplicados
  if (!favoritos.contains(code)) {
    favoritos.add(code);
    await prefs.setStringList('favoritos', favoritos);
  }
}

class ResultScreen extends StatelessWidget {
  final String code;
  final Function() closeScreen;
  final bool isDarkMode;

  const ResultScreen({
    super.key,
    required this.closeScreen,
    required this.code,
    this.isDarkMode = false,
  });

  void abrirEnlace(String url) async {
    if (!url.startsWith("http")) {
      url = "https://$url"; // corregí para usar la URL real
    }
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (kDebugMode) {
        developer.log("❌ No se pudo abrir el enlace: $url");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDarkMode ? Colors.black : const Color(0xfffafafa);
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color subTextColor = isDarkMode ? Colors.white54 : Colors.black54;
    final Color buttonColor = Colors.blue;
    final Color copyButtonColor = Colors.green;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            closeScreen();
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
          ),
        ),
        centerTitle: true,
        title: Text(
          "Escáner QR",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Varela',
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Color.fromARGB(255, 255, 0, 0)),
            onPressed: () async {
              await agregarAFavoritos(code);
              Fluttertoast.showToast(
                msg: "Agregado a favoritos ❤️",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black87,
                textColor: Colors.white,
              );
            },
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12.0),
        color: backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Código QR
            QrImageView(data: code, size: 150, version: QrVersions.auto),

            const SizedBox(height: 20),

            Text(
              "Resultado del escaneo",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Varela',
                color: subTextColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              code,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Varela',
                color: textColor,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: MediaQuery.of(context).size.width - 100,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  Fluttertoast.showToast(
                    msg: "Enlace copiado correctamente",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                    fontSize: 16,
                  );
                },
                child: const Text(
                  "Copiar",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Varela',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: MediaQuery.of(context).size.width - 100,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: copyButtonColor),
                onPressed: () {
                  abrirEnlace(code);
                },
                child: const Text(
                  "Abrir Enlace",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Varela',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
