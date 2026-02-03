import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:habit_tracker/habit_tracker_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final String defaultUsername = 'testuser';
  final String defaultPassword = 'password123';

  // 2️⃣ VALIDATE FORM
  bool validateForm() {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      return false;
    }
    return true;
  }

  // 3️⃣ AUTHENTICATE USER
  Future<void> authenticateUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String username = _usernameController.text.trim();
    String password = _passwordController.text;

    // Default login
    if (username == defaultUsername && password == defaultPassword) {
      await prefs.setString('name', 'Test User');
      await prefs.setString('username', 'testuser');
      await prefs.setDouble('age', 25);
      await prefs.setString('country', 'United States');
      Fluttertoast.showToast(msg: 'Login successful (default)');
      Navigator.pushReplacement(
        // ✅ Tambahkan Navigator
        context,
        MaterialPageRoute(
          builder: (context) => HabitTrackerScreen(username: username),
        ),
      );
      return;
    }

    // Registered user login
    String? savedEmail = prefs.getString('email');
    String? savedUsername = prefs.getString('username');
    String? savedPassword = prefs.getString('password');

    if (savedPassword == null) {
      Fluttertoast.showToast(msg: 'No registered user found');
      return;
    }

    bool isValidUser =
        (username == savedEmail || username == savedUsername) &&
        password == savedPassword;

    if (isValidUser) {
      Fluttertoast.showToast(msg: 'Login successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HabitTrackerScreen(username: username),
        ),
      );
    } else {
      await prefs.clear();
      Fluttertoast.showToast(
        msg: "The username or password was incorrect",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  // 4️⃣ HANDLE LOGIN
  void handleLogin() {
    if (validateForm()) {
      authenticateUser();
    } else {
      Fluttertoast.showToast(msg: 'All fields are required');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Habitt',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // 1️⃣ EMAIL FIELD
                _buildInputField(
                  controller: _usernameController,
                  hint: 'Enter your username',
                  icon: Icons.person,
                ),

                const SizedBox(height: 20),

                // 1️⃣ PASSWORD FIELD
                _buildInputField(
                  controller: _passwordController,
                  hint: 'Enter your password',
                  icon: Icons.lock,
                  isPassword: true,
                ),

                const SizedBox(height: 30),

                // LOGIN BUTTON
                ElevatedButton(
                  onPressed: handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // SIGN UP
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: hint.contains('username') ? TextInputType.name : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
