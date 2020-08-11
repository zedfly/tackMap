import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:quiver/core.dart';
import 'package:tack_map/core/TileNum.dart';

class MapPoint {
  //Static helper methods
  static const double baseTileSize = 256.0;
  static const double sizeFormulaConstant = 0.693147180560;
  static Size calculateSize(double currentZoom, int tileZoom) {
    double size =
        baseTileSize * exp(sizeFormulaConstant * (currentZoom - tileZoom));

    return Size(size, size);
  }

  double x;
  double y;
  double z;

  MapPoint(this.x, this.y, this.z);

  LatLng toLatLng() {
    double lat = 360 / PI * (atan(exp(PI - (PI * y) / (pow(2, z) * 128)))) - 90;
    double long = 45 / 32 / pow(2, z) * x - 180;
    return LatLng(lat, long);
  }

  TileNum toTileNum({Size size}) {
    int zTile = z.truncate();
    size ??= calculateSize(z, zTile);
    int xTile = (x / size.width).truncate();
    int yTile = (y / size.height).truncate();
    return TileNum(xTile, yTile, zTile);
  }

  bool operator ==(Object obj) {
    if (obj is MapPoint) return obj.x == x && obj.y == y && obj.z == z;

    return false;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => hash3(x, y, z);

  @override
  String toString() {
    return "MapPoint : X:$x Y:$y Z:$z";
  }
}

extension MapPointSupport on LatLng {
  MapPoint toMapPoint(double z) {
    double x = 128 * pow(2, z) * (longitude / 180 + 1);
    double y =
        128 / PI * pow(2, z) * (PI - log(tan(PI / 4 + latitudeInRad / 2)));
    return MapPoint(x, y, z);
  }
}
