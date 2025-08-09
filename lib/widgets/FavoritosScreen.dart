import 'package:flutter/material.dart';
import 'FavoritosManager.dart'; // Ajusta la ruta si hace falta

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({Key? key}) : super(key: key);

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}
const bgColor = Color(0xfffafafa);

class _FavoritosScreenState extends State<FavoritosScreen> {
  final FavoritosManager _favoritosManager = FavoritosManager();
  List<String> _favoritos = [];

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    final favoritos = await _favoritosManager.cargarFavoritos();
    setState(() {
      _favoritos = favoritos;
    });
  }

  Future<void> _eliminarFavorito(String favorito) async {
    await _favoritosManager.eliminarFavorito(favorito);
    await _cargarFavoritos();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Favorito eliminado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: _favoritos.isEmpty
          ? const Center(child: Text('No hay favoritos guardados'))
          : ListView.builder(
              itemCount: _favoritos.length,
              itemBuilder: (context, index) {
                final favorito = _favoritos[index];
                return ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.redAccent),
                  title: Text(favorito),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () => _eliminarFavorito(favorito),
                  ),
                );
              },
            ),
    );
  }
}
