import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Layout Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              height: 150,
              color: Colors.teal.shade200,
              child: const Center(
                child: Text(
                  'Header Section',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Responsive Content
            Expanded(
              child: isTablet
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildBox('Left Panel', Colors.orange),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildBox('Right Panel', Colors.green),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: _buildBox('Top Panel', Colors.orange),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: _buildBox('Bottom Panel', Colors.green),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(String text, Color color) {
    return Container(
      alignment: Alignment.center,
      color: color,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
