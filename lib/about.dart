import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.menu),
            onSelected: (value) {
              if (value == 1) {
                return null;
              } else {
                return null;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.black,
                      ),
                      Text("About"),
                    ],
                  ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(
                    Icons.logout,
                    color: Colors.black,
                  ),
                    Text("Log Out"),
                  ],
                ),
              )
            ],
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "About this app:",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
            ),
            SizedBox(height: 20),
            Text(
                "Version: 1.0",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
            ),
            SizedBox(height: 20),
            Text(
                "Developed by: Chin Lam Fung",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
            ),
          ],
        ),
      ),
    );
  }
}
