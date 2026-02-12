import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'about.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({Key? key}) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

enum Type { income, expense }

class _AddTransactionState extends State<AddTransaction> {
  Type _selected = Type.income;
  String? selectedCategoryName;
  String? selectedCategoryId;
  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String selectedTypeString = _selected == Type.income ? 'income' : 'expense';
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add New", style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.menu),
            onSelected: (value) {
              if (value == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => About()));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.black),
                    SizedBox(width: 8),
                    Text("About"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black),
                    SizedBox(width: 8),
                    Text("Log Out"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio buttons
            Text("Select Type", style: TextStyle(fontSize: 16)),
            Column(
              children: [
                RadioListTile<Type>(
                  title: Text("Income"),
                  value: Type.income,
                  groupValue: _selected,
                  activeColor: Colors.indigo,
                  onChanged: (Type? value) {
                    setState(() {
                      _selected = value!;
                      selectedCategoryName = null;
                      selectedCategoryId = null;
                    });
                  },
                ),
                RadioListTile<Type>(
                  title: Text("Expense"),
                  value: Type.expense,
                  groupValue: _selected,
                  activeColor: Colors.indigo,
                  onChanged: (Type? value) {
                    setState(() {
                      _selected = value!;
                      selectedCategoryName = null;
                      selectedCategoryId = null;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // Category dropdown
            Text("Select Category", style: TextStyle(fontSize: 16)),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .where('type', isEqualTo: selectedTypeString)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    "Error loading categories: ${snapshot.error}",
                    style: TextStyle(color: Colors.red),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final categories = snapshot.data!.docs;
                if (categories.isEmpty) return Text("No categories available for this type");

                return DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Category"),
                  value: selectedCategoryName,
                  items: categories.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final catName = data['category_name'] ?? "Unnamed";
                    return DropdownMenuItem<String>(
                      value: catName,
                      child: Text(catName),
                      onTap: () => selectedCategoryId = doc.id,
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryName = value;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 20),

            // Amount input
            Text("Amount", style: TextStyle(fontSize: 16)),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: "Enter Amount",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 30),

            // Submit button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: Size(250, 60),
                ),
                onPressed: () async {
                  if (user == null ||
                      selectedCategoryName == null ||
                      selectedCategoryId == null ||
                      amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a valid positive number for amount")),
                    );
                    return;
                  }

                  final userDocRef = FirebaseFirestore.instance.collection('user').doc(user.uid);

                  // Add the transaction with correct timestamp field
                  await userDocRef.collection('transactions').add({
                    'type': selectedTypeString,
                    'category_name': selectedCategoryName,
                    'category_id': selectedCategoryId,
                    'amount': amount,
                    'timestamp': FieldValue.serverTimestamp(), // Correct field name
                  });

                  // Update user balance
                  await FirebaseFirestore.instance.runTransaction((transaction) async {
                    final snapshot = await transaction.get(userDocRef);
                    double currentBalance = 0;
                    if (snapshot.exists) {
                      final data = snapshot.data() as Map<String, dynamic>;
                      currentBalance = (data['balance'] ?? 0).toDouble();
                    }

                    double newBalance = currentBalance;
                    if (selectedTypeString == 'income') {
                      newBalance += amount;
                    } else {
                      newBalance -= amount;

                      // Update spentAmount in budget
                      final now = DateTime.now();
                      final monthId =
                          '${now.year}-${now.month < 10 ? '0${now.month}' : now.month}';
                      final budgetCatRef = FirebaseFirestore.instance
                          .collection('user')
                          .doc(user.uid)
                          .collection('budgets')
                          .doc(monthId)
                          .collection('categories')
                          .doc(selectedCategoryId);

                      final budgetSnapshot = await transaction.get(budgetCatRef);
                      double currentSpent = 0;
                      if (budgetSnapshot.exists) {
                        final data = budgetSnapshot.data() as Map<String, dynamic>;
                        currentSpent = (data['spentAmount'] ?? 0).toDouble();
                      }

                      transaction.update(budgetCatRef, {'spentAmount': currentSpent + amount});
                    }

                    transaction.update(userDocRef, {'balance': newBalance});
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Transaction added and balance updated")),
                  );

                  Navigator.pop(context);
                },
                child: Text("Submit", style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
