import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:tack_map/TileNum.dart';

class MapPoint {
  //Constant for _x -> lng
  static const double degToRad = PI / 180;
  static const double radToDeg = 180 / PI;

  //Not flored coordinates
  double x;
  double y;
  double z;

  MapPoint(this.x, this.y, this.z);

  Size get tileSize {
    double size = 256 * pow(2, z) / pow(2, z.floor());
    return Size(size, size);
  }

  LatLng toLatLng() {
    LatLng coord = LatLng(0, 0);
    coord.longitude = 180 * x / (128 * pow(2, z)) - 180;
    coord.latitude =
        radToDeg * (2 * atan(exp(PI * (1 - y / (128 * pow(2, z))))) - PI / 2);
    return coord;
  }

  TileNum toTileNum() {
    return TileNum.fromMapPoint(this);
  }

  @override
  String toString() {
    return "MapPoint : X:$x Y:$y Z:$z";
  }
}

extension MapPointSupport on LatLng {
  //Minimum zoom is 0
  MapPoint toMapPoint(double zoom) {
    double x = 128 * pow(2, zoom) * (this.longitude / 180 + 1);
    double y = 128 *
        pow(2, zoom) /
        PI *
        (PI - log(tan(PI / 4 + this.latitudeInRad / 2)));

    return MapPoint(x, y, zoom);
  }

  TileNum toTileNum(double zoom) {
    return TileNum.fromLatLng(this, zoom);
  }
}
