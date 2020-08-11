import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tack_map/MapModel.dart';
import 'package:tack_map/core/MapPoint.dart';

class TackerMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<MapModel>(
          builder: (context, data, child) {
            //Initialize the map
            data.mapSize ??= constraints.biggest;
            data.nTilesX ??= (data.mapSize.width / 256.0).ceil() + 1;
            data.nTilesY ??= (data.mapSize.height / 256.0).ceil() + 1;
            data.origin ?? data.computeOrigin();
            if (data.currentTiles.isEmpty) data.grabTiles();

            return GestureDetector(
              child: Stack(
                alignment: Alignment.topLeft,
                fit: StackFit.expand,
                children: [
                  Stack(
                    alignment: Alignment.topLeft,
                    fit: StackFit.expand,
                    children: data.oldTiles.values.toList(),
                  ),
                  Stack(
                    alignment: Alignment.topLeft,
                    fit: StackFit.expand,
                    children: data.currentTiles,
                  )
                ],
              ),
              onScaleStart: (details) {
                data.panOffset = details.focalPoint;
                data.zoomOffset = 1.0;
              },
              onScaleUpdate: (details) {
                MapPoint center = data.center;
                Offset pan = data.panOffset - details.focalPoint;
                center.x += pan.dx;
                center.y += pan.dy;
                double newZoom = center.z - (data.zoomOffset - details.scale);
                data.move(center.toLatLng().toMapPoint(newZoom));

                data.panOffset = details.focalPoint;
                data.zoomOffset = details.scale;
              },
            );
          },
        );
      },
    );
  }
}
