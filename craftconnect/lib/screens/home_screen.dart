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
          // Logout button with confirmation
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome message
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 80, color: Colors.teal),
                  const SizedBox(height: 20),
                  Text(
                    "Welcome Back! 👋",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.email ?? "Unknown User",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.teal.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Session information card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Session Information",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildInfoRow("User ID", user?.uid ?? "N/A"),
                    _buildInfoRow(
                      "Email Verified",
                      user?.emailVerified == true ? "Yes" : "No",
                    ),
                    _buildInfoRow(
                      "Creation Time",
                      user?.metadata.creationTime?.toString().split('.')[0] ??
                          "N/A",
                    ),
                    _buildInfoRow(
                      "Last Sign In",
                      user?.metadata.lastSignInTime?.toString().split('.')[0] ??
                          "N/A",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Persistent session info
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.green.shade600),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Your session is persisted securely. You'll stay logged in even after restarting the app!",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

ElevatedButton.icon(
  onPressed: () {
    Navigator.pushNamed(context, '/firestore-write');
  },
  icon: const Icon(Icons.cloud_upload),
  label: const Text('Firestore Write Demo'),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  ),
),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseAuth.instance.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}
