import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_transaction.dart';

class Transaction extends StatefulWidget {
  const Transaction({Key? key}) : super(key: key);

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  final user = FirebaseAuth.instance.currentUser;
  String? selectedTransactionId;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final userDocRef =
    FirebaseFirestore.instance.collection('user').doc(user!.uid);
    final transactionsRef = userDocRef.collection('transactions');
    final categoriesRef =
    FirebaseFirestore.instance.collection('categories');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Balance
            StreamBuilder<DocumentSnapshot>(
              stream: userDocRef.snapshots(),
              builder: (context, snapshot) {
                double balance = 0;
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data =
                  snapshot.data!.data() as Map<String, dynamic>?;
                  balance = (data?['balance'] ?? 0).toDouble();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total balance",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "RM ${balance.toStringAsFixed(2)}",
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

            // Income & Expenses
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

            Row(
              children: [
                const Text(
                  "Transaction history",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (selectedTransactionId != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteSelectedTransaction,
                  ),
              ],
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
                    return const Center(
                        child: Text("Loading transactions..."));
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                        child: Text("No transactions yet"));
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final data =
                      docs[index].data() as Map<String, dynamic>;
                      final transactionId = docs[index].id;
                      final categoryId = data['category_id'];
                      final amount =
                      (data['amount'] ?? 0).toDouble();
                      final isIncome = data['type'] == 'income';

                      return FutureBuilder<DocumentSnapshot>(
                        future:
                        categoriesRef.doc(categoryId).get(),
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

                          final isSelected =
                              selectedTransactionId == transactionId;

                          return Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.indigo.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: Icon(
                                _mapIconNameToIconData(iconName),
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
                              onTap: () {
                                setState(() {
                                  selectedTransactionId =
                                  isSelected
                                      ? null
                                      : transactionId;
                                });
                              },
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

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => selectedTransactionId = null);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddTransaction()),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteSelectedTransaction() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userRef =
    FirebaseFirestore.instance.collection('user').doc(uid);

    final txRef = userRef
        .collection('transactions')
        .doc(selectedTransactionId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final txSnap = await transaction.get(txRef);
      if (!txSnap.exists) return;

      final txData = txSnap.data() as Map<String, dynamic>;
      final amount = (txData['amount'] ?? 0).toDouble();
      final type = txData['type'];

      final userSnap = await transaction.get(userRef);
      final currentBalance =
      (userSnap['balance'] ?? 0).toDouble();

      double newBalance = currentBalance;

      if (type == 'income') {
        newBalance -= amount;
      } else if (type == 'expense') {
        newBalance += amount;
      }

      transaction.update(userRef, {
        'balance': newBalance,
      });

      transaction.delete(txRef);
    });

    setState(() {
      selectedTransactionId = null;
    });
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

  IconData _mapIconNameToIconData(String? iconName) {
    switch (iconName) {
      case 'food':
        return Icons.fastfood;
      case 'transport':
        return Icons.directions_car;
      case 'salary':
        return Icons.payments_outlined;
      case 'allowance':
        return Icons.money;
      case 'bonus':
        return Icons.card_giftcard;
      case 'freelance':
        return Icons.work_outline;
      case 'investment':
        return Icons.show_chart;
      case 'housing':
        return Icons.home;
      case 'utilities':
        return Icons.lightbulb_outline;
      case 'health':
        return Icons.local_hospital;
      case 'entertainment':
        return Icons.movie;
      case 'education':
        return Icons.school;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }
}
