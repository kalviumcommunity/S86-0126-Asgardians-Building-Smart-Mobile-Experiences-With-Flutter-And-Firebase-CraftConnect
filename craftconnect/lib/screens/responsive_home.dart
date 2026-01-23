import 'package:flutter/material.dart';

class ResponsiveHome extends StatelessWidget {
  const ResponsiveHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CraftConnect Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Welcome to CraftConnect!',
                    style: TextStyle(
                      fontSize: isTablet ? 28 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Main Cards Section
                Expanded(
                  child: isTablet
                      ? Row(
                          children: [
                            Expanded(child: _buildCard('Products', Icons.shopping_bag, Colors.orange)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildCard('Orders', Icons.receipt_long, Colors.purple)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildCard('Profile', Icons.person, Colors.blue)),
                          ],
                        )
                      : GridView.count(
                          crossAxisCount: 1,
                          mainAxisSpacing: 20,
                          childAspectRatio: 3,
                          children: [
                            _buildCard('Products', Icons.shopping_bag, Colors.orange),
                            _buildCard('Orders', Icons.receipt_long, Colors.purple),
                            _buildCard('Profile', Icons.person, Colors.blue),
                          ],
                        ),
                ),

                // Footer / Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text(
                      'Add New Product',
                      style: TextStyle(fontSize: isTablet ? 22 : 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: color.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
