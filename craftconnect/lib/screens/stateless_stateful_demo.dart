import 'package:flutter/material.dart';

/// ----------------------------
/// Stateless Widget
/// ----------------------------
class HeaderText extends StatelessWidget {
  const HeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to make text responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveFontSize = screenWidth < 600 ? 18.0 : 24.0;

    return Text(
      'Responsive Counter App',
      style: TextStyle(
        fontSize: responsiveFontSize,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// ----------------------------
/// Stateful Widget with Responsive Features
/// ----------------------------
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int count = 0;

  void increment() {
    setState(() {
      count++;
      debugPrint('Count updated to $count');
    });
  }

  void decrement() {
    setState(() {
      count--;
      debugPrint('Count updated to $count');
    });
  }

  void reset() {
    setState(() {
      count = 0;
      debugPrint('Count reset to $count');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.9, // 90% of screen width
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 400) {
            // Mobile layout - vertical arrangement
            return Column(
              children: [
                Text(
                  'Count: $count',
                  style: TextStyle(
                    fontSize: screenWidth < 600 ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                _buildMobileButtons(),
              ],
            );
          } else {
            // Tablet layout - horizontal arrangement
            return Column(
              children: [
                Text(
                  'Count: $count',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTabletButtons(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildMobileButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: increment,
            icon: const Icon(Icons.add),
            label: const Text('Increase'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: decrement,
                icon: const Icon(Icons.remove),
                label: const Text('Decrease'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: decrement,
          icon: const Icon(Icons.remove),
          label: const Text('Decrease'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
        ElevatedButton.icon(
          onPressed: reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
        ElevatedButton.icon(
          onPressed: increment,
          icon: const Icon(Icons.add),
          label: const Text('Increase'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ],
    );
  }
}

/// ----------------------------
/// Responsive Feature Demo Widget
/// ----------------------------
class ResponsiveFeatureDemo extends StatelessWidget {
  const ResponsiveFeatureDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Responsive Features Demo',
            style: TextStyle(
              fontSize: screenWidth < 600 ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                return Column(
                  children: [
                    _buildInfoCard(
                      'Screen Width',
                      '${screenWidth.toInt()}px',
                      Icons.width_full,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      'Screen Height',
                      '${screenHeight.toInt()}px',
                      Icons.height,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      'Layout',
                      'Mobile View',
                      Icons.phone_android,
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Width',
                        '${screenWidth.toInt()}px',
                        Icons.width_full,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoCard(
                        'Height',
                        '${screenHeight.toInt()}px',
                        Icons.height,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoCard('Layout', 'Tablet', Icons.tablet),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue.shade600, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}

/// ----------------------------
/// Main Demo Screen (Uses both)
/// ----------------------------
class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Stateless vs Stateful Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () => Navigator.pushNamed(context, '/responsive-demo'),
            tooltip: 'Full Responsive Demo',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const HeaderText(), // Responsive Stateless widget
                  const SizedBox(height: 20),
                  const CounterWidget(), // Responsive Stateful widget
                  const SizedBox(height: 20),
                  const ResponsiveFeatureDemo(), // Additional responsive demo
                  const SizedBox(height: 20),

                  // Navigation button to full responsive demo
                  SizedBox(
                    width: constraints.maxWidth < 600 ? double.infinity : 300,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/responsive-demo'),
                      icon: const Icon(Icons.devices),
                      label: const Text('View Full Responsive Demo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
