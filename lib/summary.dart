import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class Summary extends StatefulWidget {
  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  DateTime? fromDate;
  DateTime? toDate;

  Future<void> _pickDate(bool isFrom) async {
    DateTime initialDate = isFrom
        ? fromDate ?? DateTime.now()
        : toDate ?? (fromDate ?? DateTime.now());

    DateTime firstDate = isFrom
        ? DateTime(2000)
        : fromDate ?? DateTime(2000); // To date cannot be before From

    DateTime lastDate = isFrom
        ? toDate ?? DateTime(2100) // From date cannot be after To
        : DateTime(2100);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          // Optional: if From date is after current To, clear To
          if (toDate != null && toDate!.isBefore(fromDate!)) toDate = null;
        } else {
          toDate = picked;
          // Optional: if To date is before current From, clear From
          if (fromDate != null && fromDate!.isAfter(toDate!)) fromDate = null;
        }
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final transactionsRef = FirebaseFirestore.instance
        .collection('user')
        .doc(user.uid)
        .collection('transactions');

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Text("Filter Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("From", style: TextStyle(fontSize: 14)),
                      SizedBox(height: 5),
                      TextField(
                        readOnly: true,
                        onTap: () => _pickDate(true),
                        decoration: InputDecoration(
                          hintText: "Select date",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        controller: TextEditingController(
                          text: fromDate == null
                              ? ""
                              : "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("To", style: TextStyle(fontSize: 14)),
                      SizedBox(height: 5),
                      TextField(
                        readOnly: true,
                        onTap: () => _pickDate(false),
                        decoration: InputDecoration(
                          hintText: "Select date",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        controller: TextEditingController(
                          text: toDate == null
                              ? ""
                              : "${toDate!.day}/${toDate!.month}/${toDate!.year}",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: transactionsRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  // Filter by date
                  final filtered = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final ts = (data['timestamp'] as Timestamp).toDate();
                    if (fromDate != null && ts.isBefore(fromDate!)) return false;
                    if (toDate != null && ts.isAfter(toDate!)) return false;
                    return true;
                  }).toList();

                  double totalIncome = 0;
                  double totalExpense = 0;
                  Map<String, double> incomeData = {};
                  Map<String, double> expenseData = {};

                  for (var doc in filtered) {
                    final data = doc.data() as Map<String, dynamic>;
                    final ts = (data['timestamp'] as Timestamp).toDate();
                    final dateKey = "${ts.day}/${ts.month}"; // e.g., "20/12"
                    final amount = (data['amount'] ?? 0).toDouble();

                    if (data['type'] == 'income') {
                      totalIncome += amount;
                      incomeData[dateKey] = (incomeData[dateKey] ?? 0) + amount;
                    } else {
                      totalExpense += amount;
                      expenseData[dateKey] = (expenseData[dateKey] ?? 0) + amount;
                    }
                  }

                  // Combine all dates and sort
                  final dates = incomeData.keys.toSet().union(expenseData.keys.toSet()).toList();
                  dates.sort((a, b) {
                    final aParts = a.split('/');
                    final bParts = b.split('/');
                    final aDate = DateTime(0, int.parse(aParts[1]), int.parse(aParts[0]));
                    final bDate = DateTime(0, int.parse(bParts[1]), int.parse(bParts[0]));
                    return aDate.compareTo(bDate);
                  });

                  // Find max Y for chart
                  double maxY = [
                    ...incomeData.values,
                    ...expenseData.values,
                  ].fold(0.0, (prev, e) => e > prev ? e : prev) * 1.2;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Income & Expenses Cards
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 100,
                              child: Card(
                                color: Colors.white54,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Income", style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.w600)),
                                      Text("RM ${totalIncome.toStringAsFixed(2)}", style: TextStyle(fontSize: 20, color: Colors.green)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            SizedBox(
                              width: 200,
                              height: 100,
                              child: Card(
                                color: Colors.white54,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Expenses", style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.w600)),
                                      Text("RM ${totalExpense.toStringAsFixed(2)}", style: TextStyle(fontSize: 20, color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),

                        // Bar Chart
                        SizedBox(
                          width: double.infinity,
                          height: 300,
                          child: BarChart(
                            BarChartData(
                              maxY: maxY,
                              barGroups: List.generate(dates.length, (index) {
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: incomeData[dates[index]] ?? 0,
                                      color: Colors.green,
                                      width: 12,
                                    ),
                                    BarChartRodData(
                                      toY: expenseData[dates[index]] ?? 0,
                                      color: Colors.red,
                                      width: 12,
                                    ),
                                  ],
                                  barsSpace: 4,
                                );
                              }),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      int idx = value.toInt();
                                      if (idx >= 0 && idx < dates.length) return Text(dates[idx], style: TextStyle(fontSize: 10));
                                      return Text("");
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    interval: 1000,
                                    getTitlesWidget: (value, meta) => Text("RM${value.toInt()}", style: TextStyle(fontSize: 10)),
                                  ),
                                ),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(show: true),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
