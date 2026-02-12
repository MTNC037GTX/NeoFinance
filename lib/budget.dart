import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Budget extends StatefulWidget {
  @override
  State<Budget> createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  late final String monthId;
  late final int currentYear;
  late final int currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    currentYear = now.year;
    currentMonth = now.month;
    monthId =
    '${currentYear}-${currentMonth < 10 ? '0$currentMonth' : currentMonth}';
    _ensureMonthlyBudget();
  }

  // Initialize the budget document for the current month
  Future<void> _ensureMonthlyBudget() async {
    final budgetRef = FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('budgets')
        .doc(monthId);

    if ((await budgetRef.get()).exists) return;

    await budgetRef.set({
      'month': monthId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Fetch only expense categories
    final categories = await FirebaseFirestore.instance
        .collection('categories')
        .where('type', isEqualTo: 'expense')
        .get();

    for (var c in categories.docs) {
      await budgetRef.collection('categories').doc(c.id).set({
        'categoryId': c.id,
        'categoryName': c['category_name'],
        'iconName': c['icon_name'],
        'budgetAmount': 0.0,
        'spentAmount': 0.0, // Add spent amount field
      });
    }
  }

  IconData _mapIcon(String name) {
    switch (name) {
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

  void _editBudget(DocumentReference ref, double current, String name) {
    final controller = TextEditingController(text: current.toStringAsFixed(2));
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit $name Budget"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: Size(180, 45),
              ),
            onPressed: () async {
              final value = double.tryParse(controller.text) ?? current;
              await ref.update({'budgetAmount': value});
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryStream = FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('budgets')
        .doc(monthId)
        .collection('categories')
        .snapshots();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: categoryStream,
        builder: (_, catSnap) {
          final categories = catSnap.data?.docs ?? [];

          if (categories.isEmpty) {
            return Center(child: Text("No expense categories in budget"));
          }

          // Get current month and year
          final now = DateTime.now();
          final monthString = "${now.year}-${now.month < 10 ? '0${now.month}' : now.month}";

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text showing current month
                Text(
                  "Budget for $monthString",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // List of categories
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (_, i) {
                      final data = categories[i].data() as Map<String, dynamic>;
                      final spent = (data['spentAmount'] ?? 0.0).toDouble();
                      final total = (data['budgetAmount'] ?? 0.0).toDouble();
                      final left = total - spent;
                      final progress = total == 0 ? 0.0 : spent / total;

                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          onTap: () => _editBudget(
                              categories[i].reference, total, data['categoryName']),
                          leading: Icon(_mapIcon(data['iconName']), size: 30),
                          title: Text(
                            data['categoryName'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Spent RM${spent.toStringAsFixed(2)} | Left RM${left.toStringAsFixed(2)}"),
                              SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0) as double,
                              ),
                            ],
                          ),
                          trailing: Text(
                            "RM${total.toStringAsFixed(2)}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
