// lib/widgets/yandex_map_view.dart

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../models/map_point.dart';

class YandexMapView extends StatefulWidget {
  final List<MapObject> mapObjects;
  final MapPoint? selectedPoint;
  final Function(Point) onMapTap;
  final Function(YandexMapController) onMapCreated;
  final Function(List<MapObject>) onMapObjectsReady;

  const YandexMapView({
    Key? key,
    required this.mapObjects,
    this.selectedPoint,
    required this.onMapTap,
    required this.onMapCreated,
    required this.onMapObjectsReady,
  }) : super(key: key);

  @override
  State<YandexMapView> createState() => _YandexMapViewState();
}

class _YandexMapViewState extends State<YandexMapView> {
  late YandexMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return YandexMap(
      onMapCreated: (controller) async {
        _mapController = controller;
        widget.onMapCreated(controller);
      },
      mapObjects: widget.mapObjects,
      onMapTap: widget.onMapTap,
      onUserLocationAdded: (view) async {
        return view.copyWith(pin: view.pin.copyWith(opacity: 1));
      },
    );
  }
}
