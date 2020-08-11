import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:latlong/latlong.dart';
import 'package:tack_map/Tile.dart';
import 'package:tack_map/core/MapPoint.dart';
import 'package:tack_map/core/TileNum.dart';

class MapModel with ChangeNotifier {
  static int maxZoom = 22;
  static const double sizeFormulaConstant = 0.693147180560;

  MapPoint center;
  MapPoint origin;
  TileNum originTileNum;
  TileNum oldOriginTileNum;

  int cacheLevel;

  List<Tile> currentTiles = [];
  Map<TileNum, Tile> oldTiles = Map();

  Size mapSize;

  int nTilesX;
  int nTilesY;

  Map<int, Size> tileSizes = Map();

  int nTilesLoaded = 0;

  Offset panOffset;
  double zoomOffset;

  MapModel(LatLng center, double zoom, {this.cacheLevel = 1}) {
    this.center = center.toMapPoint(zoom);

    for (int i = 0; i < MapModel.maxZoom; i++)
      tileSizes.putIfAbsent(i, () => Size(0, 0));

    updateSizes();
  }

  Size calculateSize(double currentZoom, int tileZoom) {
    double size = Tile.baseTileSize *
        exp(MapModel.sizeFormulaConstant * (currentZoom - tileZoom));

    return Size(size, size);
  }

  void grabTiles() {
    for (Tile tile in currentTiles) {
      if (!shouldBeCached(tile)) oldTiles.putIfAbsent(tile.tileNum, () => tile);
    }

    currentTiles.clear();

    for (int x = 0 - cacheLevel; x < nTilesX + cacheLevel; x++) {
      for (int y = 0 - cacheLevel; y < nTilesY + cacheLevel; y++) {
        currentTiles.add(
          Tile(
            tileNum: TileNum(
              originTileNum.x + x,
              originTileNum.y + y,
              originTileNum.z,
            ),
          ),
        );
      }
    }
  }

  bool shouldBeCached(Tile tile) {
    if (tile.tileNum.z != origin.z.truncate()) return false;

    bool validX = tile.tileNum.x >= originTileNum.x - cacheLevel &&
        tile.tileNum.x < originTileNum.x + nTilesX + cacheLevel;

    bool validY = tile.tileNum.y >= originTileNum.y - cacheLevel &&
        tile.tileNum.y < originTileNum.y + nTilesY + cacheLevel;

    return validX && validY;
  }

  void updateSizes() {
    int currentLayer = center.z.truncate();
    tileSizes[currentLayer] = calculateSize(center.z, currentLayer);

    for (int i = 0; i < currentLayer; i++) {
      double size = tileSizes[currentLayer].width * (1 << (currentLayer - i));
      tileSizes[i] = Size(size, size);
    }

    for (int i = currentLayer + 1; i < MapModel.maxZoom; i++) {
      double size = tileSizes[currentLayer].width / (1 << (i - currentLayer));
      tileSizes[i] = Size(size, size);
    }
  }

  void computeOrigin() {
    origin = MapPoint(
        center.x - mapSize.width / 2, center.y - mapSize.height / 2, center.z);

    originTileNum = origin.toTileNum();
  }

  void move(MapPoint center) {
    this.center = center;
    computeOrigin();
    updateSizes();
    grabTiles();
    notifyListeners();
  }

  void removeOld() {
    oldTiles.clear();
    notifyListeners();
  }
}
