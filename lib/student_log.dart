import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentLog extends StatefulWidget {
  final String userId;

  const StudentLog({Key? key, required this.userId}) : super(key: key);

  @override
  State<StudentLog> createState() => _StudentLogState();
}

class _StudentLogState extends State<StudentLog> {
  String? selectedTransactionId;

  @override
  Widget build(BuildContext context) {
    final userDocRef =
    FirebaseFirestore.instance.collection('user').doc(widget.userId);
    final transactionsRef = userDocRef.collection('transactions');
    final categoriesRef =
    FirebaseFirestore.instance.collection('categories');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Transactions"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Name + Balance
            StreamBuilder<DocumentSnapshot>(
              stream: userDocRef.snapshots(),
              builder: (context, snapshot) {
                String studentName = "Student";
                double balance = 0;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data =
                  snapshot.data!.data() as Map<String, dynamic>;
                  studentName = data['name'] ?? "Student";
                  balance = (data['balance'] ?? 0).toDouble();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Student Name",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Income & Expense Summary
            StreamBuilder<QuerySnapshot>(
              stream: transactionsRef.snapshots(),
              builder: (context, snapshot) {
                double income = 0;
                double expense = 0;

                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final amount = (data['amount'] ?? 0).toDouble();
                    if (data['type'] == 'income') income += amount;
                    if (data['type'] == 'expense') expense += amount;
                  }
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCard("Income", income, Colors.green),
                    const SizedBox(width: 12),
                    _buildCard("Expenses", expense, Colors.red),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            const Text(
              "Transaction history",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            // Transaction List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: transactionsRef
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: Text("Loading..."));
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("No transactions"));
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final data =
                      docs[index].data() as Map<String, dynamic>;
                      final categoryId = data['category_id'];
                      final amount =
                      (data['amount'] ?? 0).toDouble();
                      final isIncome = data['type'] == 'income';

                      return FutureBuilder<DocumentSnapshot>(
                        future: categoriesRef.doc(categoryId).get(),
                        builder: (context, catSnapshot) {
                          String categoryName = "Unknown";
                          String? iconName;

                          if (catSnapshot.hasData &&
                              catSnapshot.data!.exists) {
                            final catData =
                            catSnapshot.data!.data()
                            as Map<String, dynamic>;
                            categoryName =
                                catData['category_name'] ?? "Unknown";
                            iconName = catData['icon_name'];
                          }

                          return Card(
                            elevation: 1,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            child: ListTile(
                              leading: Icon(
                                _mapIcon(iconName),
                                color: isIncome
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(categoryName),
                              trailing: Text(
                                "${isIncome ? '+' : '-'} RM ${amount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: isIncome
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, double amount, Color color) {
    return SizedBox(
      width: 200,
      height: 100,
      child: Card(
        color: Colors.white54,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "RM ${amount.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _mapIcon(String? iconName) {
    switch (iconName) {
      case 'food':
        return Icons.fastfood;
      case 'salary':
        return Icons.attach_money;
      case 'transport':
        return Icons.directions_car;
      default:
        return Icons.category;
    }
  }
}
