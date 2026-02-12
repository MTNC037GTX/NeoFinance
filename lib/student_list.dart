import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_log.dart';

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!.docs;

          if (students.isEmpty) {
            return const Center(child: Text("No students found"));
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.separated(
              itemCount: students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final data = students[index].data() as Map<String, dynamic>;
                final studentId = students[index].id;
                final studentName = data['name'] ?? 'Unnamed Student';

                return Card(
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // sharp rectangle
                  ),
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: const Icon(
                      Icons.person,
                      size: 32,
                      color: Colors.indigo,
                    ),
                    title: Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentLog(userId: studentId),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
