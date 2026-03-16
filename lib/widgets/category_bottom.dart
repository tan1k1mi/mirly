import 'package:flutter/material.dart';
import 'package:mirly/state/app_state.dart';

class CategoryBottom extends StatefulWidget {
  @override
  State<CategoryBottom> createState() => _CategoryBottomState();
}

class _CategoryBottomState extends State<CategoryBottom> {
  final user = AppState.currentUser;

  final List<String> allCategories = [
    "Developers",
    "Schools",
    "Anime",
    "Games",
    "Sports",
  ];

  late List<String> selectedCategories;
  late List<String> availableCategories;

  List<String> filteredCategories = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    selectedCategories =
        user.categories != null ? List.from(user.categories!) : [];

    availableCategories =
        allCategories.where((c) => !selectedCategories.contains(c)).toList();

    filteredCategories = List.from(availableCategories);

    searchController.addListener(_filterCategories);
  }

  void _filterCategories() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredCategories = availableCategories
          .where((c) => c.toLowerCase().contains(query))
          .toList();
    });
  }

  void addCategory(String category) {
    setState(() {
      selectedCategories.add(category);
      availableCategories.remove(category);
      filteredCategories.remove(category);
      _updateUserCategories();
    });
  }

  void removeCategory(String category) {
    setState(() {
      selectedCategories.remove(category);
      availableCategories.add(category);

      availableCategories.sort(
        (a, b) => allCategories.indexOf(a).compareTo(allCategories.indexOf(b)),
      );

      _filterCategories();
      _updateUserCategories();
    });
  }

  void _updateUserCategories() {
    user.categories?.clear();
    user.categories?.addAll(selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      height: 420,
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
            "Categories",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
          const SizedBox(height: 18),
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
                    const SizedBox(height: 18),
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
        ],
      ),
    );
  }
}
