import 'package:latlong/latlong.dart';
import 'package:quiver/core.dart';
import 'package:tack_map/core/MapPoint.dart';

class TileNum {
  int x;
  int y;
  int z;

  TileNum(this.x, this.y, this.z);

  bool operator ==(Object obj) {
    if (obj is TileNum) return obj.x == x && obj.y == y && obj.z == z;

    return false;
  }

  @override
  int get hashCode => hash3(x, y, z);

  @override
  String toString() {
    return "TileNum X:$x Y:$y Z:$z";
  }
}

extension TileNumSupport on LatLng {
  TileNum toTileNum(double z) {
    return toMapPoint(z).toTileNum();
  }
}
