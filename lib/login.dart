import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'admin_screen.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // Sign in with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) return;

      // Check email domain for admin
      bool isAdmin = user.email!.endsWith('@neofinance.com');

      // Redirect based on role
      if (isAdmin) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminScreen()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login failed. Please try again";;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(""),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                  SizedBox(height: 30),
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      controller: emailController,
                      maxLength: 50,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Enter your email address",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Email cannot be empty";
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return "Enter a valid email";
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      controller: passwordController,
                      maxLength: 30,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Enter your password",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Password cannot be empty";
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                      minimumSize: Size(250, 50),
                    ),
                    onPressed: _login,
                    child: Text("Log in"),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Register()),
                      );
                    },
                    child: Text("Don't have an account? Register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
