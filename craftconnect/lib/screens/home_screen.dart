import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_queries_screen.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Welcome Card
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
                ),
                const SizedBox(height: 10),
                Text(
                  user?.email ?? "Unknown User",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.teal.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Session Info
          _buildSectionTitle("Session Information"),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoRow("User ID", user?.uid ?? "N/A"),
                  _buildInfoRow(
                    "Email Verified",
                    user?.emailVerified == true ? "Yes" : "No",
                  ),
                  _buildInfoRow(
                    "Created",
                    user?.metadata.creationTime
                            ?.toString()
                            .split('.')[0] ??
                        "N/A",
                  ),
                  _buildInfoRow(
                    "Last Login",
                    user?.metadata.lastSignInTime
                            ?.toString()
                            .split('.')[0] ??
                        "N/A",
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Firestore Queries Demo
          _buildSectionTitle("Firestore Demo Features"),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const FirestoreQueriesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text("Explore Firestore Queries"),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "where • orderBy • limit • real-time filters",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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

          const SizedBox(height: 30),

          // Live Profile
          _buildSectionTitle("Live Profile (Document Listener)"),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: user == null
                ? null
                : FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator());
              }

              if (!snapshot.hasData ||
                  !snapshot.data!.exists) {
                return _buildEmptyState(
                  "No profile data found",
                );
              }

              final data = snapshot.data!.data()!;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                          "Email", data['email'] ?? "N/A"),
                      _buildInfoRow(
                          "Name", data['name'] ?? "Not set"),
                      _buildInfoRow(
                          "Status", data['status'] ?? "Active"),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // Live Tasks
          _buildSectionTitle("Live Tasks (Collection Listener)"),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('tasks')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return _buildEmptyState("No tasks found");
              }

              return ListView.separated(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final data =
                      snapshot.data!.docs[i].data();
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.task_alt),
                      title:
                          Text(data['title'] ?? "Untitled"),
                      subtitle: Text(
                          "Status: ${data['status'] ?? 'Pending'}"),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // helpers + logout dialog (unchanged)
}
