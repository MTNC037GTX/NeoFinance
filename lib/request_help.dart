import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'view_help.dart';

class RequestHelp extends StatefulWidget {
  const RequestHelp({super.key});

  @override
  State<RequestHelp> createState() => _RequestHelpState();
}

class _RequestHelpState extends State<RequestHelp> {
  final user = FirebaseAuth.instance.currentUser;

  void _openRequestDialog() {
    final TextEditingController problemController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Request Help"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Problem"),
            SizedBox(height: 8),
            TextField(
              controller: problemController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter your problem",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              minimumSize: Size(240, 45),
            ),
            onPressed: () async {
              if (problemController.text.isEmpty) return;

              await FirebaseFirestore.instance.collection('help_requests').add({
                'description': problemController.text,
                'submit_date': Timestamp.now(),
                'status': 'Not Resolved',
                'user_id': user!.uid,
              });

              Navigator.pop(context);
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('help_requests')
                    .where('user_id', isEqualTo: user!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading requests: ${snapshot.error}",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Center(child: Text("Loading help requests..."));
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(
                      child: Text("No help requests submitted."),
                    );
                  }

                  // Sort documents locally by submit_date (oldest first)
                  docs.sort((a, b) {
                    final tsA = a['submit_date'] as Timestamp;
                    final tsB = b['submit_date'] as Timestamp;
                    return tsA.compareTo(tsB);
                  });

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text("Request ${index + 1}"),
                          subtitle: Text(_formatDate(data['submit_date'])),
                          trailing: Text(
                            data['status'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: data['status'] == 'Resolved'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewHelp(
                                  requestId: docs[index].id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: Size(260, 50),
              ),
              onPressed: _openRequestDialog,
              child: Text("Submit New Request"),
            ),
          ],
        ),
      ),
    );
  }
}
