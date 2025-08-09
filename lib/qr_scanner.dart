import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scanner/result_screen.dart';
import 'package:scanner/widgets/enlaces_guardados_screen.dart';
import 'package:scanner/widgets/GeneradorQRScreen.dart';
import 'package:scanner/widgets/FavoritosScreen.dart';
import 'dart:io';

const bgColor = Color(0xfffafafa);

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool isScanCompleted = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  MobileScannerController controller = MobileScannerController();
  List<String> enlacesGuardados = [];

  @override
  void initState() {
    super.initState();
    _cargarEnlaces();
  }

  /// Cargar enlaces guardados
  Future<void> _cargarEnlaces() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      enlacesGuardados = prefs.getStringList('enlaces') ?? [];
    });
  }

  /// Guardar enlace
  Future<void> _guardarEnlace(String enlace) async {
    final prefs = await SharedPreferences.getInstance();
    enlacesGuardados.add(enlace);
    await prefs.setStringList('enlaces', enlacesGuardados);
  }

  /// Limpiar historial
  Future<void> _limpiarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('enlaces');
    setState(() {
      enlacesGuardados.clear();
    });
  }

  // Acerca De
  Future<void> guardarLicencia(BuildContext context) async {
    try {
      const licenciaTexto = """
        📜 Licencia de uso – FabriScan
        © 2025 FabriDev Software Solutions E.I.R.L.

        Está estrictamente prohibido:
        • Copiar, distribuir o reproducir total o parcialmente la aplicación.
        • Modificar, descompilar o realizar ingeniería inversa.
        • Vender, sublicenciar o usar con fines comerciales.
        • Usar el contenido, diseño o código en otros proyectos.

        El uso está limitado a fines personales y no comerciales.
        La aplicación se proporciona 'TAL CUAL', sin garantías.
      """;

      // 📂 Carpeta Descargas (Android)
      final Directory downloadsDir = Directory("/storage/emulated/0/Download");

      if (downloadsDir.existsSync()) {
        final File file = File("${downloadsDir.path}/Licencia_FabriScan.txt");
        await file.writeAsString(licenciaTexto);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("📁 Licencia guardada en Descargas")),
          );
        }
      } else {
        throw Exception("No se encontró la carpeta de Descargas");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error al guardar la licencia: $e")),
        );
      }
    }
  }

  void closeScreen() {
    setState(() {
      isScanCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: Drawer(
        backgroundColor: bgColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(179, 167, 182, 248),
              ),
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: 250,
                  height: 250,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Menú',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Colors.blue),
              title: const Text('Escanear nuevo código'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link, color: Colors.blueAccent),
              title: const Text('Ver enlaces guardados'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnlacesGuardadosScreen(
                      enlaces: enlacesGuardados,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.green),
              title: const Text('Generador QR'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => GeneradorQRScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.redAccent),
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritosScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Borrar historial'),
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: bgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 24,
                      title: const Text("Eliminar historial"),
                      content: const Text(
                          "¿Estás seguro de que deseas eliminar todo el historial de escaneos?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () {
                            _limpiarHistorial();
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: "Historial eliminado",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.black87,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text("Eliminar"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.info, color: Colors.teal),
              title: const Text('Acerca de la app'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: bgColor,
                      title: const Text("Acerca de FabriScan"),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "📜 Licencia de uso – FabriScan\n"
                              "© 2025 FabriDev Software Solutions E.I.R.L.\n\n"
                              "Está estrictamente prohibido:\n"
                              "• Copiar, distribuir o reproducir total o parcialmente la aplicación.\n"
                              "• Modificar, descompilar o realizar ingeniería inversa.\n"
                              "• Vender, sublicenciar o usar con fines comerciales.\n"
                              "• Usar el contenido, diseño o código en otros proyectos.\n\n"
                              "El uso está limitado a fines personales y no comerciales.\n"
                              "La aplicación se proporciona 'TAL CUAL', sin garantías.",
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Color.fromARGB(255, 72, 98, 241),
                          ),
                          child: const Text("Descargar licencia"),
                          onPressed: () => guardarLicencia(context),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Color.fromARGB(255, 72, 98, 241),
                          ),
                          child: const Text("Cerrar"),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color.fromARGB(221, 0, 0, 0)),
        centerTitle: true,
        title: const Text(
          "Escáner QR",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
              });
              controller.toggleTorch();
            },
            icon: Icon(
              Icons.flashlight_on_rounded,
              color: isFlashOn ? Colors.green : Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isFrontCamera = !isFrontCamera;
              });
              controller.switchCamera();
            },
            icon: Icon(
              Icons.camera_front_rounded,
              color: isFrontCamera ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Por favor coloque el código QR en el área",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "El escaneo se iniciará automáticamente",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: MobileScanner(
                      controller: controller,
                      onDetect: (barcodeCapture) {
                        final List<Barcode> barcodes = barcodeCapture.barcodes;
                        if (barcodes.isNotEmpty && !isScanCompleted) {
                          String code = barcodes.first.rawValue ?? '---';
                          _guardarEnlace(code);
                          setState(() {
                            isScanCompleted = true;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultScreen(
                                closeScreen: closeScreen,
                                code: code,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 44, 87, 230),
                            width: 4,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  textAlign: TextAlign.center,
                  "Developed by Fabrizio B.S. \nVersion: 2.1.0",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
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
