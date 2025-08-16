import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/rendering.dart';

class GeneradorQRScreen extends StatefulWidget {
  const GeneradorQRScreen({super.key});

  @override
  _GeneradorQRScreenState createState() => _GeneradorQRScreenState();
}

const bgColor = Color(0xfffafafa);
enum TipoCodigo { qr, barras }

class _GeneradorQRScreenState extends State<GeneradorQRScreen> {
  final TextEditingController _controller = TextEditingController();
  String _data = '';
  TipoCodigo _tipoSeleccionado = TipoCodigo.qr;
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _guardarImagen() async {
    try {
      // Pedir permisos para Android 10 o inferior
      if (Platform.isAndroid) {
        if (!await Permission.storage.isGranted) {
          await Permission.storage.request();
        }
      }

      // Renderizar la imagen desde el widget
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Obtener carpeta de Descargas
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      // Crear carpeta FabriScan y subcarpeta según tipo
      String subCarpeta =
          _tipoSeleccionado == TipoCodigo.qr ? 'Códigos QR' : 'Códigos de Barras';
      Directory targetDir =
          Directory('${downloadsDir.path}/FabriScan/$subCarpeta');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      // Guardar archivo
      String filePath =
          '${targetDir.path}/codigo_${DateTime.now().millisecondsSinceEpoch}.png';
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Imagen guardada en:\n$filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error guardando imagen: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text(
        "Generador de Códigos", 
        style: TextStyle(
          fontFamily: 'Varela',
        ),
      )),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "¿Qué deseas generar?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Varela'),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 120),
                    backgroundColor: _tipoSeleccionado == TipoCodigo.qr
                        ? const Color.fromARGB(155, 112, 147, 245)
                        : const Color.fromARGB(255, 250, 250, 250),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _tipoSeleccionado = TipoCodigo.qr;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/qr.png', width: 50, height: 50),
                      const SizedBox(height: 8),
                      const Text(
                        "Código QR",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Varela',
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 120),
                    backgroundColor: _tipoSeleccionado == TipoCodigo.barras
                        ? const Color.fromARGB(155, 112, 147, 245)
                        : const Color.fromARGB(255, 250, 250, 250),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _tipoSeleccionado = TipoCodigo.barras;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/cbarra.png', width: 50, height: 50),
                      const SizedBox(height: 8),
                      const Text(
                        "Código de Barras",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Varela',
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Texto o número",
                labelStyle: TextStyle(
                  fontFamily: 'Varela',
                ),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 72, 98, 241),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() {
                  _data = _controller.text.trim();
                });
              },
              child: const Text("Generar Código",
                style: TextStyle(
                  fontFamily: 'Varela',
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (_data.isNotEmpty)
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: _tipoSeleccionado == TipoCodigo.qr
                      ? QrImageView(
                          data: _data,
                          version: QrVersions.auto,
                          size: 200,
                        )
                      : BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: _data,
                          width: 200,
                          height: 80,
                        ),
                ),
              ),
            if (_data.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 72, 98, 241), // fondo
                  foregroundColor: Colors.white, // texto e iconos
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.download_rounded),
                label: const Text("Descargar imagen",
                  style: TextStyle(
                    fontFamily: 'Varela',
                  ),
                ),
                onPressed: _guardarImagen,
              ),
            )
          ],
        ),
      ),
    );
  }
}
