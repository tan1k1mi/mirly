// lib/models/map_point.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPoint {
  final String id; // ID документа в Firestore
  final String name;
  final double latitude;
  final double longitude;
  final String createdBy;
  final Timestamp timestamp;

  MapPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
  });

  // Фабричный конструктор для создания MapPoint из DocumentSnapshot Firestore
  factory MapPoint.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MapPoint(
      id: doc.id,
      name: data['name'] as String,
      latitude: (data['latitude'] as num).toDouble(), // Приводим к double
      longitude: (data['longitude'] as num).toDouble(), // Приводим к double
      createdBy: data['createdBy'] as String,
      timestamp: data['timestamp'] as Timestamp,
    );
  }

  // Метод для преобразования MapPoint в Map для сохранения в Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'timestamp': timestamp,
    };
  }
}
