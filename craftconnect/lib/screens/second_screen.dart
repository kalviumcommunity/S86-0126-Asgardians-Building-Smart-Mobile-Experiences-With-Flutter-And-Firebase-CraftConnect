import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';


class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final message =
        ModalRoute.of(context)!.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message ?? 'No data received'),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Go Back',
              onPressed: () {
                Navigator.pop(context);
              },
            ),

          ],
        ),
      ),
    );
  }
}
