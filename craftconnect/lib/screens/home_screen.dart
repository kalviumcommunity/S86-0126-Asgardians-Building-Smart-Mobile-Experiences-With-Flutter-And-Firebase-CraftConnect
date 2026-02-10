import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CraftConnect Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 70,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(user?.email ?? "Unknown User"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Session Info
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Session Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow("User ID", user?.uid ?? "N/A"),
                    _buildInfoRow(
                      "Email Verified",
                      user?.emailVerified == true ? "Yes" : "No",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Navigation Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/realtime-tasks');
              },
              child: const Text("Open Real-Time Tasks"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/firestore-write');
              },
              child: const Text('Firestore Write Demo'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/push-notifications');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Push Notifications Demo'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/firestore-security');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Firestore Security Demo'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/maps');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('🗺️ Google Maps Demo'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/provider-demo');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('🎯 Provider State Management'),
            ),
          ],
        ),
      ),
    );
  }

  // -------- Helpers --------

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
