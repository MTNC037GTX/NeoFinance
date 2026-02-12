import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';

class Landing extends StatelessWidget {
  const Landing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "images/logo.png",
              width: 200,
              height: 200,
            ),
            SizedBox(height: 10),
            Text(
                "NeoFinance",
                style: TextStyle(
                    fontSize: 28.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Orbitron',
                ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                  minimumSize: Size(250,50),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
                },
                child: Text("Get Started")
            ),
            SizedBox(height: 10),
            TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                },
                child: Text("I have an account"),
            ),
          ],
        ),
      ),
    );
  }
}
