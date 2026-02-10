import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreWriteScreen extends StatefulWidget {
  const FirestoreWriteScreen({super.key});

  @override
  State<FirestoreWriteScreen> createState() => _FirestoreWriteScreenState();
}

class _FirestoreWriteScreenState extends State<FirestoreWriteScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String? lastCreatedDocId;

  // ADD DATA
  Future<void> _addTask() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      final docRef =
          await FirebaseFirestore.instance.collection('tasks').add({
        'title': title,
        'description': desc,
        'isCompleted': false,
        'createdAt': Timestamp.now(),
      });

      setState(() {
        lastCreatedDocId = docRef.id;
      });

      _titleController.clear();
      _descController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding task: $e')),
      );
    }
  }

  // UPDATE DATA
  Future<void> _updateTask() async {
    if (lastCreatedDocId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No task available to update')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(lastCreatedDocId)
          .update({
        'title': 'Updated Task Title',
        'updatedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firestore Write Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text('Add Task'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _updateTask,
              child: const Text('Update Last Task'),
            ),
          ],
        ),
      ),
    );
  }
}
