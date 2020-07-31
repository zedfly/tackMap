import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:tack_map/MapPoint.dart';
import 'package:tack_map/Tile.dart';
import 'package:tack_map/TileNum.dart';

void main() {
  runApp(MaterialApp(
    home: TackerMap(
      initialCenter: LatLng(45.516880, -73.573563),
      initialZoom: 10.0,
    ),
  ));
}

class TackerMap extends StatefulWidget {
  static const int baseTileSize = 256;

  final LatLng initialCenter;
  final double initialZoom;
  TackerMap({@required this.initialCenter, @required this.initialZoom});

  @override
  _TackerMapState createState() => _TackerMapState();
}

class _TackerMapState extends State<TackerMap> {
  //On screen tile and old tiles
  HashMap<TileNum, Tile> onScreenTiles = HashMap();
  HashMap<TileNum, Tile> tilesToPurge = HashMap();

  final List<String> markersImageUrl = [
    "https://images.unsplash.com/photo-1555445091-5a8b655e8a4a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=675&q=80",
    "https://images.unsplash.com/photo-1559628129-67cf63b72248?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80",
    "https://images.unsplash.com/photo-1549492423-400259a2e574?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=554&q=80",
    "https://images.unsplash.com/photo-1571023479098-1ed95127545e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80",
    "https://images.unsplash.com/photo-1527068589345-b736a7de9cc2?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80",
    "https://images.unsplash.com/photo-1445264718234-a623be589d37?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1552483777-6d0e5cc7e09f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1536084577616-ea0e7911a977?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1569173218827-23c563d874b1?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1525806047694-f14aa78cf38c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1574264787766-0e0018170009?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1557487218-4574772f0b8c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1450858930767-64b21437d41f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1592160884144-921e26cb84e2?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1561573047-989ab420948f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1571023478477-60e0a902b282?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1531944252668-83d381a30b26?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1449237386841-d30ba36cd1bf?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1529122316052-65f6954b9c83?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1592853008860-f09329eed4fb?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60"
  ];

  List<LatLng> markersPos = [];

  List<Positioned> positionedTiles = [];
  List<Positioned> markers = [];

  //Info relative to map
  MapPoint center;
  double zoom;

  //Origin is the top left corner of the map
  MapPoint origin;
  Offset originStackOffset;
  Size originTileSize;

  TileNum _nextOriginTileNum;
  TileNum originTileNum;

  //Size of the map display
  Size size;

  //Number of tiles to display horizontally and vertically
  int nTilesVertical;
  int nTilesHorizontal;

  //Offset for smooth panning of the map
  Offset panOffset;

  //Offset for smoot zooming of the map
  double scaleOffset;

  void createMarkerPos() {
    for (int i = 0; i < markersImageUrl.length; i++) {
      markersPos.add(
        LatLng(widget.initialCenter.latitude + Random().nextDouble() / 10,
            widget.initialCenter.longitude + Random().nextDouble() / 10),
      );
    }
  }

  void buildMarkers() {
    markers.clear();
    for (int i = 0; i < markersImageUrl.length; i++) {
      MapPoint markerPos = markersPos[i].toMapPoint(zoom);
      double top = markerPos.y - origin.y - 30;
      double left = markerPos.x - origin.x - 30;
      markers.add(
        Positioned(
          top: top,
          left: left,
          height: 60,
          width: 60,
          child: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(markersImageUrl[i]),
          ),
        ),
      );
    }
  }

  void computeOrigin() {
    //Get the top left MapPoint
    origin = MapPoint(
        center.x - size.width / 2, center.y - size.height / 2, center.z);

    //Get TileNum containing origin point
    _nextOriginTileNum = origin.toTileNum();

    //Get the tileSize for current zoom
    originTileSize = origin.tileSize;

    //Get the position Offset for the starting tile
    originStackOffset = Offset(
        _nextOriginTileNum.x * originTileSize.width - origin.x,
        _nextOriginTileNum.y * originTileSize.height - origin.y);

    //New tiles have to be added to the map
    if (originTileNum != _nextOriginTileNum) {
      getNewTiles();
      purgeOldTiles();
    }
  }

  void getNewTiles() {
    originTileNum = _nextOriginTileNum;

    for (TileNum tileNum in onScreenTiles.keys.toList()) {
      if (!isTileOnScreen(tileNum))
        tilesToPurge.putIfAbsent(tileNum, () => onScreenTiles.remove(tileNum));
    }

    //Add the new images to display and caches adjacent ones
    for (int x = 0; x < nTilesHorizontal; x++) {
      for (int y = 0; y < nTilesVertical; y++) {
        TileNum tileNum = TileNum(
            originTileNum.x + x, originTileNum.y + y, originTileNum.zoom);

        onScreenTiles.putIfAbsent(
          tileNum,
          () => Tile(tileNum: tileNum),
        );
      }
    }
  }

  void buildPositionedTiles() {
    positionedTiles.clear();
    onScreenTiles.forEach((key, value) {
      double left = originStackOffset.dx +
          (key.x - originTileNum.x) * originTileSize.width;
      double top = originStackOffset.dy +
          (key.y - originTileNum.y) * originTileSize.height;
      positionedTiles.add(Positioned(
        top: top,
        left: left,
        height: originTileSize.height,
        width: originTileSize.width,
        child: FittedBox(
          fit: BoxFit.fill,
          child: value,
        ),
      ));
    });
  }

  void purgeOldTiles() {
    tilesToPurge.forEach((key, value) {
      NetworkImage(value.tileUrl).evict();
    });
    tilesToPurge.clear();
  }

  bool isTileOnScreen(TileNum tileNum, {int colsAround = 0}) {
    if (tileNum.zoom == originTileNum.zoom) {
      bool validX = tileNum.x >= originTileNum.x - colsAround &&
          tileNum.x < originTileNum.x + nTilesHorizontal + colsAround;

      bool validY = tileNum.y >= originTileNum.y - colsAround &&
          tileNum.y < originTileNum.y + nTilesVertical + colsAround;

      return validX && validY;
    }
    return false;
  }

  //Initialize values for pan
  void handleScaleStart(ScaleStartDetails details) {
    panOffset = details.focalPoint;
    scaleOffset = 1.0;
  }

  //Handle pan
  void handleScaleUpdate(ScaleUpdateDetails details) {
    //Scale is equal diferrent then 1 so we have zoom
    if (details.scale != 1.0) {
      double zoomChange = details.scale - scaleOffset;
      double nextZoom = center.z + zoomChange;

      setState(() {
        center = center.toLatLng().toMapPoint(nextZoom);
        zoom = center.z;
      });
    }
    //Scale is equal to 1 so we have a pan gesture
    else {
      Offset offset = panOffset - details.focalPoint;
      panOffset = details.focalPoint;
      setState(() {
        center.x += offset.dx;
        center.y += offset.dy;
      });
    }

    //Update the offset for movement and zoom
    panOffset = details.focalPoint;
    scaleOffset = details.scale;
  }

  @override
  void initState() {
    super.initState();
    zoom = widget.initialZoom;
    center = widget.initialCenter.toMapPoint(zoom);

    createMarkerPos();
  }

  @override
  Widget build(BuildContext context) {
    print(imageCache.currentSizeBytes);
    print(imageCache.maximumSizeBytes);

    return LayoutBuilder(
      builder: (context, constraints) {
        //Get the size of the map
        size ??= constraints.biggest;

        //Number of tile horizontally and vertically to display on screen
        nTilesHorizontal ??= (size.width / TackerMap.baseTileSize).ceil() + 1;
        nTilesVertical ??= (size.height / TackerMap.baseTileSize).ceil() + 1;

        //Compute the origin MapPoint and TileNumber
        computeOrigin();

        //Builds the tiles to be rendered on screen
        buildPositionedTiles();

        //Build markers
        buildMarkers();

        return GestureDetector(
          child: Stack(
            alignment: Alignment.topLeft,
            fit: StackFit.expand,
            children: <Widget>[
              Stack(
                alignment: Alignment.topLeft,
                fit: StackFit.expand,
                children: positionedTiles,
              ),
              Stack(
                alignment: Alignment.topLeft,
                fit: StackFit.expand,
                children: markers,
              )
            ],
          ),
          onScaleStart: handleScaleStart,
          onScaleUpdate: handleScaleUpdate,
        );
      },
    );
  }
}
