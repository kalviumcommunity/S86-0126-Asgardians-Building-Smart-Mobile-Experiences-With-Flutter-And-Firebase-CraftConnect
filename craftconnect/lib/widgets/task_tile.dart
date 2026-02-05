import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  final String title;
  final String description;

  const TaskTile({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}
