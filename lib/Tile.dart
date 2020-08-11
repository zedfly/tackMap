import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tack_map/MapModel.dart';
import 'package:tack_map/core/MapPoint.dart';
import 'package:tack_map/core/TileNum.dart';
import 'package:transparent_image/transparent_image.dart';

class Tile extends StatelessWidget {
  static double baseTileSize = 256.0;

  //MapBox url
  static String mapUrl =
      "https://api.mapbox.com/styles/v1/mapinapp/ckbyj7uew1ao11iqkwm229rpn/tiles/256";

  //Access Token for mapbox
  static String accessToken =
      "pk.eyJ1IjoibWFwaW5hcHAiLCJhIjoiY2tiNWY2Yzg0MTZhNzMxcGFsY3NrNDNsYiJ9.DC5omDLQS6EkgP5OZmmZKw";

  //The tileNum of the tile
  final TileNum tileNum;

  Tile({@required this.tileNum});

  @override
  Widget build(BuildContext context) {
    //Create the url of the tile
    String url =
        "${Tile.mapUrl}/${tileNum.z}/${tileNum.x}/${tileNum.y}@2x?access_token=${Tile.accessToken}";

    return Consumer<MapModel>(
      builder: (context, data, child) {
        Size size = data.tileSizes[tileNum.z];
        MapPoint origin = data.origin;

        //Compute the tile position on the stack
        Offset pos = Offset(tileNum.x * size.width - origin.x,
            tileNum.y * size.height - origin.y);

        NetworkImage networkImage = NetworkImage(url);

        return Positioned(
          top: pos.dy,
          left: pos.dx,
          height: size.height,
          width: size.width,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Image(
              image: networkImage,
            ),
          ),
        );
      },
    );
  }
}
