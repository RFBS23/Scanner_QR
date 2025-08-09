import 'package:shared_preferences/shared_preferences.dart';

class FavoritosManager {
  static const String keyFavoritos = 'favoritos';

  Future<List<String>> cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(keyFavoritos) ?? [];
  }

  Future<void> agregarFavorito(String favorito) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritos = await cargarFavoritos();
    if (!favoritos.contains(favorito)) {
      favoritos.add(favorito);
      await prefs.setStringList(keyFavoritos, favoritos);
    }
  }

  Future<void> eliminarFavorito(String favorito) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritos = await cargarFavoritos();
    favoritos.remove(favorito);
    await prefs.setStringList(keyFavoritos, favoritos);
  }
}
