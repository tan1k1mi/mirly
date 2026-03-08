// lib/widgets/modal_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:mirly/services/firestore_service.dart';

class CreateEventSheet extends StatefulWidget {
  final double latitude;
  final double longitude;

  const CreateEventSheet({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends State<CreateEventSheet> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Создать событие в этой точке?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Название события",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final String eventName = _nameController.text.trim();
              if (eventName.isNotEmpty) {
                try {
                  // Здесь вы можете получить ID пользователя из Firebase Authentication
                  // Например: FirebaseAuth.instance.currentUser?.uid ?? "guest_user"
                  await addPointToFirestore(
                    name: eventName,
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                    createdBy:
                        "guest_user", // <--- Лучше получать из Firebase Auth
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Событие "$eventName" создано!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Не удалось создать событие: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Пожалуйста, введите название события')),
                );
              }
            },
            child: const Text("Создать событие"),
          ),
        ],
      ),
    );
  }
}
