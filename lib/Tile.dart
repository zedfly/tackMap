import 'package:flutter/cupertino.dart';
import 'TileNum.dart';

class Tile extends StatelessWidget {
  //MapBox url
  static String _url =
      "https://api.mapbox.com/styles/v1/mapinapp/ckbyj7uew1ao11iqkwm229rpn/tiles/256/";
  //Access Token for mapbox
  static String _accessToken =
      "pk.eyJ1IjoibWFwaW5hcHAiLCJhIjoiY2tiNWY2Yzg0MTZhNzMxcGFsY3NrNDNsYiJ9.DC5omDLQS6EkgP5OZmmZKw";

  static String buildTileUrl(TileNum tileNum) {
    return _url +
        "${tileNum.zoom}/${tileNum.x}/${tileNum.y}@2x?access_token=$_accessToken";
  }

  final TileNum tileNum;
  String tileUrl;
  Image tileImage;

  Tile({@required this.tileNum}) {
    tileUrl = buildTileUrl(tileNum);
    tileImage = Image.network(tileUrl);
  }

  @override
  Widget build(BuildContext context) {
    return tileImage;
  }
}
