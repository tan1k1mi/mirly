// Ваш существующий файл с MapScreen (например, lib/screens/map_screen.dart)

import 'package:flutter/material.dart';
import 'package:mirly/widgets/bottom_navigation_bar.dart';
import 'package:mirly/widgets/category_bottom.dart';
import 'package:mirly/widgets/modal_bottom_sheet.dart'; // Предполагаем, что CreateEventSheet здесь
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../models/map_point.dart';
import 'package:mirly/services/firestore_service.dart';
import 'dart:math';

import 'package:mirly/widgets/yandex_map_view.dart';
import 'package:mirly/services/permission_service.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Друзья')),
      body: const Center(child: Text('Это экран друзей')),
    );
  }
}

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Список событий')),
      body: const Center(child: Text('Это экран списка событий')),
    );
  }
}

class _ModalBodyView extends StatelessWidget {
  final MapPoint point;

  const _ModalBodyView({Key? key, required this.point}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            point.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('Создано: ${point.createdBy}'),
          Text('Широта: ${point.latitude.toStringAsFixed(4)}'),
          Text('Долгота: ${point.longitude.toStringAsFixed(4)}'),
          Text(
              'Время создания: ${point.timestamp.toDate().toLocal().toString().split('.')[0]}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}

// --- КОНЕЦ: ОПРЕДЕЛЕНИЯ ВСПОМОГАТЕЛЬНЫХ ВИДЖЕТОВ ---

class MapScreen extends StatefulWidget {
  final MapPoint? selectedPoint;

  const MapScreen({super.key, this.selectedPoint});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late YandexMapController _mapController;
  int _selectedIndex = 0;
  List<MapObject> _currentMapObjects = [];

  final PermissionService _permissionService = PermissionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Карта событий"),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () async {
              if (_currentMapObjects.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Нет событий')),
                );
                return;
              }
              _moveToAllPoints(_currentMapObjects);
            },
          )
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<MapPoint>>(
            stream: getPointsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Ошибка загрузки точек: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final firestorePoints = snapshot.data!;
              _currentMapObjects = _getCircleObjects(context, firestorePoints);

              return YandexMapView(
                mapObjects: _currentMapObjects,
                selectedPoint: widget.selectedPoint,
                onMapCreated: (controller) async {
                  _mapController = controller;
                  final granted = await _permissionService
                      .requestLocationPermission(context);

                  if (granted) {
                    await _mapController.toggleUserLayer(visible: true);
                  }

                  if (widget.selectedPoint != null) {
                    await _mapController.moveCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: Point(
                            latitude: widget.selectedPoint!.latitude,
                            longitude: widget.selectedPoint!.longitude,
                          ),
                          zoom: 15,
                        ),
                      ),
                    );
                  } else if (_currentMapObjects.isNotEmpty) {
                    _moveToAllPoints(_currentMapObjects);
                  }
                },
                onMapTap: (point) {
                  final latitude = point.latitude;
                  final longitude = point.longitude;

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: CreateEventSheet(
                          latitude: latitude,
                          longitude: longitude,
                        ),
                      );
                    },
                  );
                },
                onMapObjectsReady: (objects) {},
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AppBottomNavigation(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });

                switch (index) {
                  case 0:
                    break;

                  case 1:
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => CategoryBottom(),
                    );
                    break;

                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FriendsScreen()),
                    );
                    break;

                  case 3:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EventsListScreen()),
                    );
                    break;
                }
              },
            ),
          )
        ],
      ),
    );
  }

  List<MapObject> _getCircleObjects(
      BuildContext context, List<MapPoint> points) {
    return points.map((point) {
      return CircleMapObject(
        mapId: MapObjectId(point.id),
        circle: Circle(
          center: Point(latitude: point.latitude, longitude: point.longitude),
          radius: 30,
        ),
        strokeColor: Colors.blue,
        strokeWidth: 3,
        fillColor: Colors.blue.withAlpha(128),
        onTap: (mapPoint, _) {
          showModalBottomSheet(
            context: context,
            builder: (_) => _ModalBodyView(point: point),
          );
        },
      );
    }).toList();
  }

  Future<void> _moveToAllPoints(List<MapObject> objects) async {
    if (objects.isEmpty) return;

    if (objects.length == 1) {
      final circle = objects.first as CircleMapObject;
      await _mapController.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: circle.circle.center, zoom: 15),
        ),
        animation: const MapAnimation(
          type: MapAnimationType.linear,
          duration: 0.3,
        ),
      );
      return;
    }

    final bounds = _calculateBoundingBox(objects);
    await _mapController.moveCamera(
      CameraUpdate.newBounds(bounds),
      animation: const MapAnimation(
        type: MapAnimationType.linear,
        duration: 0.3,
      ),
    );
  }

  BoundingBox _calculateBoundingBox(List<MapObject> objects) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLon = double.infinity;
    double maxLon = -double.infinity;

    for (var obj in objects) {
      if (obj is CircleMapObject) {
        final point = obj.circle.center;
        minLat = min(minLat, point.latitude);
        maxLat = max(maxLat, point.latitude);
        minLon = min(minLon, point.longitude);
        maxLon = max(maxLon, point.longitude);
      }
    }

    return BoundingBox(
      northEast: Point(latitude: maxLat, longitude: maxLon),
      southWest: Point(latitude: minLat, longitude: minLon),
    );
  }
}
