import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String error = "";

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        error = "Passwords do not match";
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      final newUser = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (newUser.user != null) {
        final uid = newUser.user!.uid;
        final now = DateTime.now();
        final monthId =
            '${now.year}-${now.month < 10 ? '0${now.month}' : now.month}';

        final userDocRef = FirebaseFirestore.instance.collection('user').doc(uid);

        // Initialize user document
        await userDocRef.set({
          'name': nameController.text,
          'email': emailController.text,
          'balance': 0.0,
          'created_at': Timestamp.now(),
        });

        // Initialize budget collection for the current month
        final budgetRef = userDocRef.collection('budgets').doc(monthId);
        await budgetRef.set({
          'month': monthId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Fetch all expense categories
        final categoriesSnapshot = await FirebaseFirestore.instance
            .collection('categories')
            .where('type', isEqualTo: 'expense')
            .get();

        for (var cat in categoriesSnapshot.docs) {
          await budgetRef.collection('categories').doc(cat.id).set({
            'categoryId': cat.id,
            'categoryName': cat['category_name'],
            'iconName': cat['icon_name'],
            'budgetAmount': 0.0,
            'spentAmount': 0.0, // initialize spent amount
          });
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed. Please try again';
      if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid';
      }
      setState(() {
        error = message;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() => isLoading = false);
    }
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

                  // Name
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      controller: nameController,
                      maxLength: 30,
                      decoration: InputDecoration(
                        labelText: "Name",
                        hintText: "Enter your name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? "Name required" : null,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Email
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      controller: emailController,
                      maxLength: 50,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Enter your email address",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Email required";
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value))
                          return "Enter a valid email";
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 10),

                  // Password
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
                      validator: (value) =>
                      value == null || value.isEmpty ? "Password required" : null,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Confirm Password
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      controller: confirmPasswordController,
                      maxLength: 30,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        hintText: "Enter your password again",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Confirm password required"
                          : null,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Submit Button
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                      minimumSize: Size(250, 50),
                    ),
                    onPressed: _register,
                    child: Text("Register"),
                  ),
                  SizedBox(height: 20),
                  if (error.isNotEmpty)
                    Text(
                      error,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
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
