import 'package:flutter/material.dart';

/// ----------------------------
/// Dev Tools Demonstration Screen
/// This screen demonstrates:
/// 1. Hot Reload - Change UI properties instantly
/// 2. Debug Console - View logs and debug messages
/// 3. Flutter DevTools - Inspect widgets and performance
/// ----------------------------

class DevToolsDemoScreen extends StatefulWidget {
  const DevToolsDemoScreen({super.key});

  @override
  State<DevToolsDemoScreen> createState() => _DevToolsDemoScreenState();
}

class _DevToolsDemoScreenState extends State<DevToolsDemoScreen> {
  int clickCount = 0;
  Color backgroundColor = Colors.blue.shade50;
  String displayText = 'Welcome to Hot Reload Demo!';
  double fontSize = 24.0;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 DevToolsDemoScreen initialized');
  }

  void incrementCounter() {
    setState(() {
      clickCount++;
      debugPrint('✅ Counter incremented to: $clickCount');
      debugPrint(
        '📊 Current state - Text: "$displayText", FontSize: $fontSize, BgColor: ${backgroundColor.toString()}',
      );
    });
  }

  void changeColor() {
    setState(() {
      backgroundColor = backgroundColor == Colors.blue.shade50
          ? Colors.green.shade50
          : Colors.blue.shade50;
      debugPrint(
        '🎨 Background color changed to: ${backgroundColor.toString()}',
      );
    });
  }

  void resetAll() {
    setState(() {
      clickCount = 0;
      backgroundColor = Colors.blue.shade50;
      displayText = 'Welcome to Hot Reload Demo!';
      fontSize = 24.0;
      debugPrint('🔄 All values reset to defaults');
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔨 Building DevToolsDemoScreen widget');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hot Reload & DevTools Demo'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              debugPrint('ℹ️ Info button pressed');
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Dev Tools Demo'),
                  content: const Text(
                    'Try these:\n\n'
                    '1. Modify text, colors, or fontSize\n'
                    '2. Save and see Hot Reload in action\n'
                    '3. Check Debug Console for logs\n'
                    '4. Open Flutter DevTools to inspect widgets',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        debugPrint('ℹ️ Info dialog closed');
                      },
                      child: const Text('Got it!'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.speed, size: 60, color: Colors.teal),
                      const SizedBox(height: 10),
                      Text(
                        displayText,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Try changing the text, color, or size above and save!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Counter Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Click Counter',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$clickCount',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: incrementCounter,
                        icon: const Icon(Icons.add),
                        label: const Text('Increment Counter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Demo Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: changeColor,
                        icon: const Icon(Icons.color_lens),
                        label: const Text('Toggle Background Color'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: resetAll,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset All'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Instructions Section
              Card(
                elevation: 4,
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.lightbulb, color: Colors.amber),
                          SizedBox(width: 10),
                          Text(
                            'Hot Reload Tips',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTip('1. Change displayText string above'),
                      _buildTip('2. Modify fontSize value'),
                      _buildTip('3. Update Colors (try Colors.purple.shade50)'),
                      _buildTip('4. Save file - see instant changes!'),
                      _buildTip('5. Check Debug Console for logs'),
                      _buildTip('6. Open DevTools to inspect widget tree'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Debug Console Examples
              Card(
                elevation: 4,
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.terminal, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            'Debug Console Activity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Every action triggers debugPrint() statements.\n'
                        'Watch the Debug Console to see:\n\n'
                        '🚀 Initialization logs\n'
                        '✅ Counter updates\n'
                        '🎨 Color changes\n'
                        '🔄 Reset events\n'
                        'ℹ️ User interactions',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          debugPrint('🎯 FAB pressed - Current state summary:');
          debugPrint('   Counter: $clickCount');
          debugPrint('   Background: ${backgroundColor.toString()}');
          debugPrint('   Text: "$displayText"');
          debugPrint('   Font Size: $fontSize');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'State logged to Debug Console! Count: $clickCount',
              ),
              backgroundColor: Colors.teal,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.bug_report),
        label: const Text('Log State'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('🛑 DevToolsDemoScreen disposed');
    super.dispose();
  }
}
