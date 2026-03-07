import 'package:flutter/material.dart';
import 'package:mirly/widgets/bottom_navigation_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../models/map_point.dart';
import 'friends_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final YandexMapController _mapController;
  var _mapZoom = 0.0;
  CameraPosition? _userLocation;
  int _selectedIndex = 0; // Для панели навигации

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (controller) async {
              _mapController = controller;
              await _initLocationLayer();
            },
            onCameraPositionChanged: (cameraPosition, _, __) {
              setState(() {
                _mapZoom = cameraPosition.zoom;
              });
            },
            mapObjects: _getPlacemarkObjects(context),
            onUserLocationAdded: (view) async {
              _userLocation = await _mapController.getUserCameraPosition();
              if (_userLocation != null) {
                await _mapController.moveCamera(
                  CameraUpdate.newCameraPosition(
                    _userLocation!.copyWith(zoom: 10),
                  ),
                  animation: const MapAnimation(
                    type: MapAnimationType.linear,
                    duration: 0.3,
                  ),
                );
              }
              return view.copyWith(pin: view.pin.copyWith(opacity: 1));
            },
          ),

          // Нижняя панель навигации
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
                    // Уже на карте
                    break;
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FriendsScreen()),
                    );
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initLocationLayer() async {
    final locationPermissionIsGranted = await Permission.location
        .request()
        .isGranted;

    if (locationPermissionIsGranted) {
      await _mapController.toggleUserLayer(visible: true);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Нет доступа к местоположению пользователя'),
          ),
        );
      });
    }
  }

  List<PlacemarkMapObject> _getPlacemarkObjects(BuildContext context) {
    return _getMapPoints()
        .map(
          (point) => PlacemarkMapObject(
            mapId: MapObjectId('MapObject ${point.name}'),
            point: Point(latitude: point.latitude, longitude: point.longitude),
            opacity: 1,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage(
                  'assets/icons/map_point.png',
                ),
                scale: 2,
              ),
            ),
            onTap: (_, __) => showModalBottomSheet(
              context: context,
              builder: (context) => _ModalBodyView(point: point),
            ),
          ),
        )
        .toList();
  }

  List<MapPoint> _getMapPoints() {
    return [
      MapPoint(name: 'Москва', latitude: 55.755864, longitude: 37.617698),
      MapPoint(name: 'Лондон', latitude: 51.507351, longitude: -0.127696),
      MapPoint(name: 'Рим', latitude: 41.887064, longitude: 12.504809),
      MapPoint(name: 'Париж', latitude: 48.856663, longitude: 2.351556),
      MapPoint(name: 'Стокгольм', latitude: 59.347360, longitude: 18.341573),
    ];
  }
}

class _ModalBodyView extends StatelessWidget {
  const _ModalBodyView({required this.point});

  final MapPoint point;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(point.name, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          Text(
            '${point.latitude}, ${point.longitude}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
