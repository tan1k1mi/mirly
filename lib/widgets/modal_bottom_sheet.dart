import 'package:flutter/material.dart';
import 'package:mirly/services/firestore_service.dart';
import 'package:mirly/state/app_state.dart';

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

  final user = AppState.currentUser;

  List<String> selectedCategories = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userCategories = user.categories ?? [];

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
          const SizedBox(height: 16),
          ExpansionTile(
            title: const Text("Категории"),
            children: userCategories.map((category) {
              final selected = selectedCategories.contains(category);

              return CheckboxListTile(
                title: Text(category),
                value: selected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedCategories.add(category);
                    } else {
                      selectedCategories.remove(category);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final String eventName = _nameController.text.trim();

              if (eventName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введите название события')),
                );
                return;
              }

              try {
                await addPointToFirestore(
                  name: eventName,
                  latitude: widget.latitude,
                  longitude: widget.longitude,
                  categories: selectedCategories,
                  createdBy: "guest_user",
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Событие "$eventName" создано!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка: $e')),
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
