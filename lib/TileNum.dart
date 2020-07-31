import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:quiver/core.dart';
import 'package:tack_map/Tile.dart';

import 'MapPoint.dart';

class TileNum {
  int x;
  int y;
  int zoom;

  TileNum(this.x, this.y, this.zoom);

  TileNum.fromMapPoint(MapPoint point) {
    Size tileSize = point.tileSize;
    x = (point.x / tileSize.width).truncate();
    y = (point.y / tileSize.height).truncate();
    zoom = point.z.truncate();
  }

  TileNum.fromLatLng(LatLng latLng, double zoom)
      : this.fromMapPoint(latLng.toMapPoint(zoom));

  TileNum getZoomOutTile(int zoomDiff) {
    if (zoomDiff < 0)
      throw Exception("Zoom difference must be positive");
    else if (zoomDiff == 0)
      return this;
    else {
      return TileNum(x >> zoomDiff, y >> zoomDiff, zoom - zoomDiff);
    }
  }

  List<TileNum> getZoomInTiles(int zoomDiff) {
    if (zoomDiff < 0)
      throw Exception("Zoom difference must be positive");
    else if (zoomDiff == 0) {
      return [this];
    } else {
      TileNum base = TileNum(x << zoomDiff, y << zoomDiff, zoom + zoomDiff);
      List<TileNum> tiles = [];
      int nTiles = 1 << zoomDiff;
      for (int x = 0; x < nTiles; x++) {
        for (int y = 0; y < nTiles; y++) {
          tiles.add(TileNum(base.x + x, base.y + y, zoom + zoomDiff));
        }
      }
    }
  }

  @override
  String toString() {
    return "TileNum : X:$x Y:$y Z:$zoom";
  }

  @override
  int get hashCode {
    return hash3(x, y, zoom);
  }

  bool operator ==(Object obj) {
    if (obj is TileNum) {
      return obj.x == x && obj.y == y && obj.zoom == zoom;
    }

    return false;
  }
}
