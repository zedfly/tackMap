import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:tack_map/MapModel.dart';
import 'package:tack_map/TackerMap.dart';

void main() {
  runApp(MaterialApp(
    home: ChangeNotifierProvider(
      create: (context) => MapModel(LatLng(45.508888, -73.561668), 10.0),
      child: TackerMap(),
    ),
  ));
}
