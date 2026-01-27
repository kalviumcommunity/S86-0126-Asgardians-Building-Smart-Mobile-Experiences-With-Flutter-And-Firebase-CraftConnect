import 'package:flutter/material.dart';

class WidgetTreeDemo extends StatefulWidget {
  const WidgetTreeDemo({super.key});

  @override
  State<WidgetTreeDemo> createState() => _WidgetTreeDemoState();
}

class _WidgetTreeDemoState extends State<WidgetTreeDemo> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Widget Tree Demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isActive ? "State Changed!" : "Initial State",
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              color: isActive ? Colors.green : Colors.blue,
              child: const Text(
                "This is a Container Widget",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isActive = !isActive;
                });
              },
              child: const Text("Change State"),
            ),
          ],
        ),
      ),
    );
  }
}
