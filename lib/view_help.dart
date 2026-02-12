import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewHelp extends StatefulWidget {
  final String requestId;

  const ViewHelp({super.key, required this.requestId});

  @override
  State<ViewHelp> createState() => _ViewHelpState();
}

class _ViewHelpState extends State<ViewHelp> {
  final TextEditingController _saveController = TextEditingController();

  void _showAddSavingDialog(double currentSaved, double goal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Saving"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Amount"),
            const SizedBox(height: 8),
            TextField(
              controller: _saveController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
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
            ),
            onPressed: () async {
              final input = double.tryParse(_saveController.text);
              if (input == null || input <= 0) return;

              final newTotal = currentSaved + input;

              await FirebaseFirestore.instance
                  .collection('help_requests')
                  .doc(widget.requestId)
                  .update({
                'total_saved': newTotal,
              });

              _saveController.clear();
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Request Details"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('help_requests')
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text("Loading..."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final description = data['description'] ?? '';
          final reply = data['admin_reply'] ?? '';
          final goal = (data['milestone_goal'] ?? 0).toDouble();
          final saved = (data['total_saved'] ?? 0).toDouble();

          final reached = goal > 0 && saved >= goal;
          final progress = goal == 0 ? 0 : saved / goal;

          return Padding(
            padding: const EdgeInsets.all(30),
            child: ListView(
              children: [
                const Text(
                  "Your Request",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(description),

                const SizedBox(height: 30),

                const Text(
                  "Admin Reply",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(reply),

                if (goal > 0) ...[
                  const SizedBox(height: 30),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.track_changes, color: Colors.indigo),
                              SizedBox(width: 8),
                              Text(
                                "Goal",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Saved RM ${saved.toStringAsFixed(2)} | Left RM ${(goal - saved).clamp(0, goal).toStringAsFixed(2)}",
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "RM ${goal.toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (reached)
                    const Text(
                      "Congratulations! You have reached your goal.",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () =>
                          _showAddSavingDialog(saved, goal),
                      child: const Text("Add Saving"),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
