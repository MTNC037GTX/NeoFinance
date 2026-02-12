import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewHelp extends StatefulWidget {
  final String helpRequestId;
  final String studentName;

  const ReviewHelp({
    super.key,
    required this.helpRequestId,
    required this.studentName,
  });

  @override
  State<ReviewHelp> createState() => _ReviewHelpState();
}

class _ReviewHelpState extends State<ReviewHelp> {
  final TextEditingController replyController = TextEditingController();
  final TextEditingController milestoneController = TextEditingController();

  Map<String, dynamic>? helpData;

  @override
  void initState() {
    super.initState();
    _loadHelpRequest();
  }

  Future<void> _loadHelpRequest() async {
    final doc = await FirebaseFirestore.instance
        .collection('help_requests')
        .doc(widget.helpRequestId)
        .get();

    if (doc.exists) {
      setState(() {
        helpData = doc.data();
      });
    }
  }

  Future<void> _submit() async {
    if (replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reply is required")),
      );
      return;
    }

    double milestone = 0;
    if (milestoneController.text.trim().isNotEmpty) {
      milestone = double.tryParse(milestoneController.text.trim()) ?? 0;
      if (milestone < 0) milestone = 0;
    }

    try {
      await FirebaseFirestore.instance
          .collection('help_requests')
          .doc(widget.helpRequestId)
          .update({
        'admin_reply': replyController.text.trim(),
        'milestone_goal': milestone,
        'total_saved': 0,
        'status': 'Resolved',
        'reply_date': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reply submitted successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit reply: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (helpData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final description = helpData!['description'] ?? "No description";

    return Scaffold(
      appBar: AppBar(
        title: Text("Request from ${widget.studentName}"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Student Request",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(description),

              const SizedBox(height: 24),

              const Text(
                "Reply",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: replyController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter your reply",
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Milestone Goal (Optional)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: milestoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter a number",
                ),
              ),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
