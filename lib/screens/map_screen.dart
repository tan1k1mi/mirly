// lib/screens/map_screen.dart

import 'package:flutter/material.dart';
import 'package:mirly/widgets/bottom_navigation_bar.dart';
import 'package:mirly/widgets/category_bottom.dart';
import 'package:mirly/widgets/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../models/map_point.dart'; // Импорт вашей модели MapPoint
import 'package:mirly/services/firestore_service.dart'; // Импорт нашего сервиса Firestore
import 'dart:math'; // <--- Добавил импорт для min и max

// --- Заглушки для других экранов, если они еще не реализованы ---
// Убедитесь, что у вас есть реальные файлы для FriendsScreen и EventsListScreen.
// Если они есть, то эти заглушки можно удалить.
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
// --- Конец заглушек ---

// --- Виджет для отображения деталей точки на карте при нажатии ---
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
            onPressed: () {
              Navigator.pop(context); // Закрыть модальное окно
              // Дополнительные действия, например, навигация к деталям события
            },
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
// --- Конец виджета _ModalBodyView ---

class MapScreen extends StatefulWidget {
  final MapPoint? selectedPoint;
  const MapScreen({super.key, this.selectedPoint});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late YandexMapController _mapController;
  CameraPosition? _userLocation;
  int _selectedIndex = 0;

  List<PlacemarkMapObject> _mapObjects = [];

  // Контроллер карты теперь инициализируется в onMapCreated
  // и не требует вызова dispose в initState, так как onMapCreated
  // может вызываться несколько раз при горячей перезагрузке,
  // а YandexMapController должен быть один на виджет.
  // Dispose будет вызван, когда виджет будет удален из дерева.
  @override
  void dispose() {
    // В случае с late YandexMapController, создаваемым в onMapCreated,
    // явный dispose здесь может быть излишним или даже приводить к ошибкам,
    // если контроллер не был полностью инициализирован или уже утилизирован самой картой.
    // Однако, для надежности, если вы уверены, что контроллер всегда инициализируется,
    // его можно вызывать. Но чаще всего, если контроллер управляется самим виджетом карты,
    // явный dispose не требуется. Я закомментировал его для безопасности.
    // _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Карта событий"),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () {
              if (_mapObjects.isNotEmpty) {
                _moveToAllPoints(_mapObjects);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Нет событий для отображения')),
                );
              }
            },
            tooltip: "Показать все события",
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<MapPoint>>(
            stream: getPointsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text('Ошибка загрузки точек: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<MapPoint> firestorePoints = snapshot.data ?? [];

              // Обновляем список объектов карты только если данные изменились
              if (_mapObjects.length != firestorePoints.length ||
                  !_areMapObjectsSame(firestorePoints)) {
                _mapObjects = _getPlacemarkObjects(context, firestorePoints);
              }

              return YandexMap(
                onMapCreated: (controller) async {
                  _mapController = controller; // Инициализация контроллера
                  await _initLocationLayer();

                  // Логика центрирования карты после ее создания
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
                      animation: const MapAnimation(
                        type: MapAnimationType.linear,
                        duration: 0.3,
                      ),
                    );
                  } else if (firestorePoints.isNotEmpty) {
                    _moveToAllPoints(_mapObjects);
                  } else {
                    _userLocation =
                        await _mapController.getUserCameraPosition();
                    if (_userLocation != null) {
                      await _mapController.moveCamera(
                        CameraUpdate.newCameraPosition(
                          _userLocation!.copyWith(zoom: 15),
                        ),
                        animation: const MapAnimation(
                          type: MapAnimationType.linear,
                          duration: 0.3,
                        ),
                      );
                    }
                  }
                },
                onMapTap: (Point point) {
                  final latitude = point.latitude;
                  final longitude = point.longitude;

                  print(
                      'Нажатие на карту: Latitude: $latitude, Longitude: $longitude');

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
                mapObjects: _mapObjects,
                onUserLocationAdded: (view) async {
                  // Эта функция вызывается, когда местоположение пользователя становится доступным.
                  // Мы уже обработали начальное центрирование в onMapCreated,
                  // поэтому здесь просто возвращаем представление.
                  return view.copyWith(pin: view.pin.copyWith(opacity: 1));
                },
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
                    // Если уже на главном экране карты, то ничего не делаем.
                    break;
                  case 1:
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        return CategoryBottom();
                      },
                    );
                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FriendsScreen()),
                    );
                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EventsListScreen()),
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
    final locationPermissionIsGranted =
        await Permission.location.request().isGranted;

    if (locationPermissionIsGranted) {
      await _mapController.toggleUserLayer(visible: true);
    } else {
      // Использование WidgetsBinding.instance.addPostFrameCallback
      // гарантирует, что SnackBar будет показан после завершения построения виджетов.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Нет доступа к местоположению пользователя'),
          ),
        );
      });
    }
  }

  List<PlacemarkMapObject> _getPlacemarkObjects(
      BuildContext context, List<MapPoint> points) {
    return points
        .map(
          (point) => PlacemarkMapObject(
            mapId: MapObjectId(
                point.id), // Используем ID документа Firestore как mapId
            point: Point(latitude: point.latitude, longitude: point.longitude),
            opacity: 1,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage(
                  'assets/icons/map_point.png', // Убедитесь, что у вас есть этот ресурс
                ),
                scale: 2,
              ),
            ),
            onTap: (_, __) => showModalBottomSheet(
              context: context,
              builder: (context) =>
                  _ModalBodyView(point: point), // Использование нового виджета
            ),
          ),
        )
        .toList();
  }

  // Новая вспомогательная функция для центрирования карты на всех точках
  Future<void> _moveToAllPoints(List<PlacemarkMapObject> objects) async {
    if (objects.isEmpty) {
      // Если точек нет, возможно, стоит центрировать на текущем местоположении пользователя
      // или на каком-то стандартном месте.
      _userLocation = await _mapController.getUserCameraPosition();
      if (_userLocation != null) {
        await _mapController.moveCamera(
          CameraUpdate.newCameraPosition(
            _userLocation!.copyWith(zoom: 15),
          ),
          animation: const MapAnimation(
            type: MapAnimationType.linear,
            duration: 0.3,
          ),
        );
      }
      return;
    }

    if (objects.length == 1) {
      await _mapController.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: objects.first.point,
            zoom: 15,
          ),
        ),
        animation:
            const MapAnimation(type: MapAnimationType.linear, duration: 0.3),
      );
      return;
    }

    final BoundingBox boundingBox = _calculateBoundingBox(objects);
    await _mapController.moveCamera(
      CameraUpdate.newBounds(
        boundingBox,
      ),
      animation: const MapAnimation(
        type: MapAnimationType.linear,
        duration: 0.3,
      ),
    );
  }

  BoundingBox _calculateBoundingBox(List<PlacemarkMapObject> objects) {
    double minLat = objects.first.point.latitude;
    double maxLat = objects.first.point.latitude;
    double minLon = objects.first.point.longitude;
    double maxLon = objects.first.point.longitude;

    for (var obj in objects) {
      minLat = min(minLat, obj.point.latitude);
      maxLat = max(maxLat, obj.point.latitude);
      minLon = min(minLon, obj.point.longitude);
      maxLon = max(maxLon, obj.point.longitude);
    }
    return BoundingBox(
        northEast: Point(latitude: maxLat, longitude: maxLon),
        southWest: Point(latitude: minLat, longitude: minLon));
  }

  bool _areMapObjectsSame(List<MapPoint> currentPoints) {
    if (_mapObjects.length != currentPoints.length) {
      return false;
    }
    for (int i = 0; i < _mapObjects.length; i++) {
      if (_mapObjects[i].mapId.value != currentPoints[i].id) {
        return false;
      }
    }
    return true;
  }
}
