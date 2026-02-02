import 'package:flutter/material.dart';

/// Comprehensive Responsive Design Demo
/// Uses MediaQuery and LayoutBuilder for adaptive UI
class ResponsiveDemoScreen extends StatelessWidget {
  const ResponsiveDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions using MediaQuery
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Design Demo'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Info Section
            _buildScreenInfoCard(screenWidth, screenHeight, orientation),
            const SizedBox(height: 20),

            // MediaQuery Demo Section
            _buildMediaQueryDemo(context, screenWidth, screenHeight),
            const SizedBox(height: 20),

            // LayoutBuilder Demo Section
            _buildLayoutBuilderDemo(),
            const SizedBox(height: 20),

            // Combined Demo Section
            _buildCombinedDemo(context, screenWidth),
            const SizedBox(height: 20),

            // Responsive Grid Section
            _buildResponsiveGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenInfoCard(
    double width,
    double height,
    Orientation orientation,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Screen Width: ${width.toStringAsFixed(1)}px'),
            Text('Screen Height: ${height.toStringAsFixed(1)}px'),
            Text('Orientation: ${orientation.name}'),
            Text('Device Type: ${_getDeviceType(width)}'),
          ],
        ),
      ),
    );
  }

  String _getDeviceType(double width) {
    if (width < 600) return 'Mobile';
    if (width < 900) return 'Tablet Portrait';
    return 'Tablet Landscape / Desktop';
  }

  Widget _buildMediaQueryDemo(
    BuildContext context,
    double screenWidth,
    double screenHeight,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MediaQuery Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Container adapts to 80% of screen width and 15% of height:',
            ),
            const SizedBox(height: 12),
            Container(
              width: screenWidth * 0.8,
              height: screenHeight * 0.15,
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.phone_android,
                      size: 40,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Responsive Container',
                      style: TextStyle(
                        fontSize:
                            screenWidth *
                            0.04, // Font size based on screen width
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    Text(
                      '${(screenWidth * 0.8).toInt()}x${(screenHeight * 0.15).toInt()}px',
                      style: TextStyle(color: Colors.teal.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutBuilderDemo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LayoutBuilder Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Layout changes based on available space:'),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    // Mobile Layout - Vertical
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_android,
                            size: 60,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Mobile Layout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Vertical arrangement for narrow screens'),
                        ],
                      ),
                    );
                  } else {
                    // Tablet Layout - Horizontal
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.tablet, size: 80, color: Colors.blue),
                          SizedBox(width: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tablet Layout',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Horizontal arrangement for wide screens'),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedDemo(BuildContext context, double screenWidth) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Combined MediaQuery & LayoutBuilder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                if (screenWidth < 600) {
                  // Mobile layout - Stack vertically
                  return Column(
                    children: [
                      _buildDemoPanel(
                        'Panel 1',
                        Colors.teal,
                        screenWidth * 0.9,
                        120,
                      ),
                      const SizedBox(height: 12),
                      _buildDemoPanel(
                        'Panel 2',
                        Colors.orange,
                        screenWidth * 0.9,
                        120,
                      ),
                    ],
                  );
                } else {
                  // Tablet layout - Side by side
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDemoPanel('Left Panel', Colors.teal, 250, 150),
                      const SizedBox(width: 12),
                      _buildDemoPanel('Right Panel', Colors.orange, 250, 150),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoPanel(
    String title,
    MaterialColor color,
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              title.contains('Left') || title.contains('Panel 1')
                  ? Icons.dashboard
                  : Icons.analytics,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Responsive Grid',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate number of columns based on width
                int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    final colors = [
                      Colors.red.shade100,
                      Colors.blue.shade100,
                      Colors.green.shade100,
                      Colors.purple.shade100,
                      Colors.orange.shade100,
                      Colors.teal.shade100,
                      Colors.pink.shade100,
                      Colors.indigo.shade100,
                    ];

                    return Container(
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.widgets,
                              size: 30,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Item ${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Grid adapts: 2 columns on mobile, 4 columns on tablet',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
