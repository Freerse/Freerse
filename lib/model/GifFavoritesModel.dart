import 'dart:io';

import 'package:freerse/services/SpUtils.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class GifFavoritesModel {
  static final GifFavoritesModel _instance = GifFavoritesModel._internal();
  factory GifFavoritesModel() => _instance;

  final Set<String> _favorites = {}; //

  GifFavoritesModel._internal();

  Future<void> saveImageToDirectory(
      String imagePath, String newFileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final newPath = path.join(directory.path, newFileName);

    final originalFile = File(imagePath);
    final newFile = await originalFile.copy(newPath);

    print('pic saved to: ${newFile.path}');
  }

  Future<void> loadFavorites() async {
    final favorites = SpUtil.getStringList("favorites");
    if (favorites!.isNotEmpty) {
      _favorites.addAll(favorites);
    }
  }

  Future<void> saveFavorites() async {
    await SpUtil.putStringList('favorites', _favorites.toList());
  }

  bool isFavorite(String gifUrl) {
    return _favorites.contains(gifUrl);
  }

  void toggleFavorite(String gifUrl) {
    if (_favorites.contains(gifUrl)) {
      _favorites.remove(gifUrl);
    } else {
      _favorites.add(gifUrl);
    }
    saveFavorites();
  }

  void removeFavorite(String gifUrl) {
    _favorites.remove(gifUrl);

    saveFavorites();
  }

  void addFavorite(String gifUrl) {
    _favorites.add(gifUrl);

    saveFavorites();
  }

  List getFavorite() {
    List favorites = _favorites.toList();

    return favorites;
  }

  int getFavoristeSize() {
    List favorites = _favorites.toList();

    return favorites.length;
  }
}
