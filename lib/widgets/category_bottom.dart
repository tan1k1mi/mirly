import 'package:flutter/material.dart';
import 'package:mirly/models/user_model.dart';
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
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();

    selectedCategories = user.categories != null
        ? List.from(user.categories!)
        : [];

    availableCategories = allCategories
        .where((c) => !selectedCategories.contains(c))
        .toList();
  }

  void addCategory(String category) {
    setState(() {
      selectedCategories.add(category);
      availableCategories.remove(category);
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
      _updateUserCategories();
    });
  }

  void _updateUserCategories() {
    user.categories?.clear();
    user.categories?.addAll(selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...selectedCategories.map(
                (category) => GestureDetector(
                  onTap: () => removeCategory(category),
                  child: Chip(
                    label: Text(category),
                    deleteIcon: Icon(Icons.close),
                    onDeleted: () => removeCategory(category),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isDropdownOpen = !isDropdownOpen;
                  });
                },
                child: Chip(
                  label: Icon(Icons.add, color: Colors.black),
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
          if (isDropdownOpen && availableCategories.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableCategories
                    .map(
                      (category) => GestureDetector(
                        onTap: () {
                          addCategory(category);
                        },
                        child: Chip(
                          label: Text(category),
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
