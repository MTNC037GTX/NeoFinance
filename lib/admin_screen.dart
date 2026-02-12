import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'category_list.dart';
import 'student_list.dart';
import 'help_list.dart';
import 'about.dart';
import 'landing.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    CategoryList(),
    StudentList(),
    HelpList(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _selectedIndex == 0
              ? "Manage Category"
              : _selectedIndex == 1
              ? "Student List"
              : "Review Help Request",
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


      body: _pages[_selectedIndex], // 👈 show selected page
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
            icon: Icon(Icons.list_alt),
            label: "Category",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Student Log",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: "Review Help",
          ),
        ],
      ),
    );
  }
}