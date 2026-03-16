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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final user = AppState.currentUser;

  List<String> selectedCategories = [];
  List<String> filteredCategories = [];

  @override
  void initState() {
    super.initState();

    filteredCategories = List.from(user.categories ?? []);

    searchController.addListener(_filterCategories);
  }

  void _filterCategories() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredCategories = (user.categories ?? [])
          .where((c) =>
              !selectedCategories.contains(c) &&
              c.toLowerCase().contains(query))
          .toList();
    });
  }

  void addCategory(String category) {
    setState(() {
      selectedCategories.add(category);
      _filterCategories();
    });
  }

  void removeCategory(String category) {
    setState(() {
      selectedCategories.remove(category);
      _filterCategories();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> createEvent() async {
    final eventName = nameController.text.trim();

    if (eventName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Введите название события")),
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
        SnackBar(content: Text("Ошибка: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Text(
            "Create Event",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Event name",
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color.fromARGB(255, 25, 25, 25),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search categories...",
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: const Color.fromARGB(255, 25, 25, 25),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedCategories.isNotEmpty) ...[
                    const Text(
                      "Selected",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedCategories
                          .map(
                            (c) => Chip(
                              label: Text(c),
                              labelStyle: const TextStyle(color: Colors.white),
                              deleteIcon:
                                  const Icon(Icons.close, color: Colors.white),
                              backgroundColor:
                                  const Color.fromARGB(255, 30, 30, 30),
                              onDeleted: () => removeCategory(c),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    "Available",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filteredCategories
                        .map(
                          (c) => GestureDetector(
                            onTap: () => addCategory(c),
                            child: Chip(
                              label: Text(c),
                              labelStyle: const TextStyle(color: Colors.white),
                              backgroundColor:
                                  const Color.fromARGB(255, 18, 18, 18),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: createEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Create Event",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
