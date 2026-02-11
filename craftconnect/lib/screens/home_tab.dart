import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CraftConnect"),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/push-notifications');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate refresh delay
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade400, Colors.teal.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome Back!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.displayName ??
                            user?.email?.split('@').first ??
                            "Crafting Friend",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Discover amazing handcrafted items and connect with skilled artisans.",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions Section
              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildQuickActionCard(
                    context,
                    icon: Icons.explore,
                    title: "Explore Products",
                    subtitle: "Browse crafts",
                    color: Colors.orange,
                    onTap: () {
                      // Navigate to products tab
                      DefaultTabController.of(context)?.animateTo(1);
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.favorite,
                    title: "Favorites",
                    subtitle: "Saved items",
                    color: Colors.pink,
                    onTap: () {
                      // Navigate to favorites
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.location_on,
                    title: "Find Stores",
                    subtitle: "Near me",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, '/maps');
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.support_agent,
                    title: "Support",
                    subtitle: "Get help",
                    color: Colors.purple,
                    onTap: () {
                      _showSupportDialog(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Featured Section
              const Text(
                "Developer Features",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFeatureListTile(
                    context,
                    icon: Icons.security,
                    title: "Firestore Security",
                    subtitle: "Test security rules",
                    route: '/firestore-security',
                  ),
                  _buildFeatureListTile(
                    context,
                    icon: Icons.task,
                    title: "Real-time Tasks",
                    subtitle: "Live data updates",
                    route: '/realtime-tasks',
                  ),
                  _buildFeatureListTile(
                    context,
                    icon: Icons.developer_mode,
                    title: "Dev Tools Demo",
                    subtitle: "Development utilities",
                    route: '/dev-tools',
                  ),
                  _buildFeatureListTile(
                    context,
                    icon: Icons.animation,
                    title: "Animations",
                    subtitle: "UI animations demo",
                    route: '/animations',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Support"),
        content: const Text(
          "Contact us at support@craftconnect.com or call +1-800-CRAFT",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
