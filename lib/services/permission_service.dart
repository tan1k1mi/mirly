// lib/services/permission_service.dart
import 'package:flutter/material.dart'; // Для ScaffoldMessenger и SnackBar
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Запрашивает разрешение на доступ к геолокации.
  /// Возвращает true, если разрешение получено, иначе false.
  Future<bool> requestLocationPermission(BuildContext context) async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // Пользователь отклонил запрос, но его можно запросить снова
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Разрешение на доступ к геолокации отклонено.')),
      );
      return false;
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Разрешение на доступ к геолокации отклонено навсегда. Откройте настройки приложения.'),
          action: SnackBarAction(
            label: 'Настройки',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
      return false;
    }
    return false;
  }
}
