import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'review_help.dart';

class HelpList extends StatefulWidget {
  const HelpList({super.key});

  @override
  State<HelpList> createState() => _HelpListState();
}

class _HelpListState extends State<HelpList> {
  final helpRequestsRef =
  FirebaseFirestore.instance.collection('help_requests');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: helpRequestsRef.orderBy('submit_date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("No help requests found"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final requestData = requests[index].data() as Map<String, dynamic>;
              final status = requestData['status'] ?? "Not Resolved";
              final userId = requestData['user_id'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('user').doc(userId).get(),
                builder: (context, userSnapshot) {
                  String studentName = "Unknown Student";
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    studentName = userData['name'] ?? studentName;
                  }

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    child: ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.indigo),
                      title: Text("From $studentName"),
                      trailing: Text(
                        status,
                        style: TextStyle(
                          color: status == "Resolved" ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewHelp(
                              helpRequestId: requests[index].id,
                              studentName: studentName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
