import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'transaction.dart';
import 'budget.dart';
import 'summary.dart';
import 'about.dart';
import 'request_help.dart';
import 'landing.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Transaction(),   // index 0
    Budget(),        // index 1
    Summary(),       // index 2
    RequestHelp(),   // index 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _selectedIndex == 0
              ? "Transaction"
              : _selectedIndex == 1
              ? "Budget"
              : _selectedIndex == 2
              ? "Summary"
              : "Help",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.menu),
            onSelected: (value) async {
              if (value == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => About()),
                );
              } else if (value == 2) {
                // Log out user
                await FirebaseAuth.instance.signOut();
                // Redirect to Landing page
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Landing()),
                      (route) => false,
                );
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

      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: "Transactions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: "Budget",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Summary",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: "Help",
          ),
        ],
      ),
    );
  }
}