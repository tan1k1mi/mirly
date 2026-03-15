import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mirly/models/map_point.dart';

Future<void> addPointToFirestore({
  required String name,
  required double latitude,
  required double longitude,
  String? createdBy, // Снова сделали его параметром
  required List<String> categories,
}) async {
  // В идеале, здесь нужно использовать FirebaseAuth.instance.currentUser?.uid
  // для получения ID текущего пользователя.
  final String finalCreatedBy = createdBy ?? "anonymous_tester";

  try {
    CollectionReference points =
        FirebaseFirestore.instance.collection('points');

    await points.add({
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': finalCreatedBy,
      'timestamp': FieldValue.serverTimestamp(),
      'categories': categories,
    });
    print(
        "Точка '$name' успешно добавлена в Firestore пользователем $finalCreatedBy!");
  } catch (e) {
    print("Ошибка при добавлении точки в Firestore: $e");
    rethrow;
  }
}

/// Функция для получения потока всех точек из Firestore,
/// преобразованных в список MapPoint.
/// StreamBuilder<List<MapPoint>> будет использоваться для отслеживания изменений.
Stream<List<MapPoint>> getPointsStream() {
  return FirebaseFirestore.instance
      .collection('points')
      .snapshots()
      .map((snapshot) {
    // Преобразуем каждый DocumentSnapshot в MapPoint
    return snapshot.docs.map((doc) => MapPoint.fromFirestore(doc)).toList();
  });
}
