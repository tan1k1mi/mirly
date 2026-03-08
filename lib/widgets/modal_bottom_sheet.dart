import 'package:flutter/material.dart';

class CreateEventSheet extends StatelessWidget {
  final double latitude;
  final double longitude;

  const CreateEventSheet({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Создать событие"),
          ),
        ],
      ),
    );
  }
}
