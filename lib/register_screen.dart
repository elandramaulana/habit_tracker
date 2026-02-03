import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:habit_tracker/country_list.dart';
import 'package:habit_tracker/habit_tracker_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  double _age = 25;
  String _country = 'United States';
  List<String> _countries = [];

  List<String> selectedHabits = [];
  List<String> availableHabits = [
    'Wake Up Early',
    'Workout',
    'Drink Water',
    'Meditate',
    'Read a Book',
    'Practice Gratitude',
    'Sleep 8 Hours',
    'Eat Healthy',
    'Journal',
    'Walk 10,000 Steps',
  ];
  final Map<String, Color> _habitColors = {
    'Amber': Colors.amber,
    'Red Accent': Colors.redAccent,
    'Light Blue': Colors.lightBlue,
    'Light Green': Colors.lightGreen,
    'Purple Accent': Colors.purpleAccent,
    'Orange': Colors.orange,
    'Teal': Colors.teal,
    'Deep Purple': Colors.deepPurple,
  };

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      List<String> countries = await fetchCountries();
      setState(() {
        _countries = countries;
      });
    } catch (e) {
      // Handle error
      _showToast('Error fetching countries');
    }
  }

  // 1️⃣ VALIDATE FORM
  bool validateForm() {
    if (_nameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        selectedHabits.isEmpty) {
      return false;
    }
    return true;
  }

  // // 2️⃣ SAVE DATA
  // Future<void> saveUserData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   await prefs.setString('name', _nameController.text);
  //   await prefs.setString('username', _usernameController.text);
  //   await prefs.setString('email', _emailController.text);
  //   await prefs.setString('password', _passwordController.text);
  //   await prefs.setInt('age', _age.round());
  //   await prefs.setString('country', _country);
  //   await prefs.setStringList('habits', selectedHabits);
  //   await prefs.setString('selectedHabitsMap', jsonEncode(selectedHabitsMap));
  // }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _register() async {
    final name = _nameController.text;
    final username = _usernameController.text;

    if (username.isEmpty || name.isEmpty) {
      _showToast('Please fill in all fields');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Assign random colors to selected habits.
    Map<String, String> selectedHabitsMap = {};
    final random = Random();
    final colorKeys = _habitColors.keys.toList();
    for (var habit in selectedHabits) {
      var randomColor =
          _habitColors[colorKeys[random.nextInt(colorKeys.length)]]!;
      selectedHabitsMap[habit] = randomColor.value.toRadixString(16);
    }

    await prefs.setString('name', _nameController.text);
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setInt('age', _age.round());
    await prefs.setString('country', _country);
    await prefs.setStringList('habits', selectedHabits);
    await prefs.setString('selectedHabitsMap', jsonEncode(selectedHabitsMap));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HabitTrackerScreen(username: username),
      ),
    );
  }

  void _toggleHabitSelection(String habit) {
    setState(() {
      if (selectedHabits.contains(habit)) {
        selectedHabits.remove(habit);
      } else {
        selectedHabits.add(habit);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text(
          'Register',
          style: TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(_nameController, 'Name', Icons.person),
              const SizedBox(height: 10),
              _buildInputField(
                _usernameController,
                'Username',
                Icons.alternate_email,
              ),
              const SizedBox(height: 10),
              _buildInputField(_emailController, 'Email', Icons.email),
              const SizedBox(height: 10),
              _buildInputField(
                _passwordController,
                'Password',
                Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 15),
              Text(
                'Age: ${_age.round()}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Slider(
                value: _age,
                min: 21,
                max: 100,
                divisions: 79,
                activeColor: Colors.blue.shade600,
                onChanged: (value) {
                  setState(() => _age = value);
                },
              ),
              const SizedBox(height: 10),
              _buildCountryDropdown(),
              const SizedBox(height: 15),
              const Text(
                'Select Your Habits',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: availableHabits.map((habit) {
                  final isSelected = selectedHabits.contains(habit);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedHabits.remove(habit);
                        } else {
                          selectedHabits.add(habit);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade600 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade700),
                      ),
                      child: Text(
                        habit,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (validateForm()) {
                      Fluttertoast.showToast(
                        msg: 'Register successful',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                      _register;
                    } else {
                      Fluttertoast.showToast(
                        msg: 'All fields are required',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  },

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
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    IconData icon, {
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

  Widget _buildCountryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButton<String>(
        value: _country,
        icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
        isExpanded: true,
        underline: SizedBox(),
        items: _countries.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _country = newValue!;
          });
        },
      ),
    );
  }
}
