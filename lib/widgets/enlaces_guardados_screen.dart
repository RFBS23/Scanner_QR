import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const bgColor = Color(0xfffafafa);

class EnlacesGuardadosScreen extends StatelessWidget {
  final List<String> enlaces;

  const EnlacesGuardadosScreen({super.key, required this.enlaces});

  bool _esUrlValida(String texto) {
    final uri = Uri.tryParse(texto);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  void _abrirEnlace(BuildContext context, String url) async {
    if (_esUrlValida(url)) {
      final uri = Uri.parse(url);
      final scaffoldMessenger = ScaffoldMessenger.of(context); // Guardar antes del await

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Enlaces guardados"),
      ),
      body: enlaces.isEmpty
        ? const Center(
            child: Text("No hay enlaces guardados"),
          )
        : ListView.builder(
            itemCount: enlaces.length,
            itemBuilder: (context, index) {
              final enlace = enlaces[index];
              final esUrl = _esUrlValida(enlace);
              return ListTile(
                leading: Icon(esUrl ? Icons.link : Icons.document_scanner),
                title: Text(enlace),
                onTap: esUrl
                  ? () => _abrirEnlace(context, enlace)
                  : null, // no hace nada si no es URL válida
              );
            },
          ),
    );
  }
}
