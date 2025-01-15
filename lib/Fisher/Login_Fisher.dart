import 'package:flutter/material.dart';

import 'interface.dart';

class LoginFisher extends StatefulWidget {
  @override
  _LoginInterfaceState createState() => _LoginInterfaceState();
}

class _LoginInterfaceState extends State<LoginFisher> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the input fields
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _secretCodeController = TextEditingController();

  // Regular expression for full name validation (only alphabets)
  final RegExp nameRegExp = RegExp(r'^[a-zA-Z\s]+$');

  // Password visibility toggle
  bool _isPasswordVisible = false;

  // Function to navigate to the Map page
  void _navigateToMapPage() {
    if (_formKey.currentState!.validate()) {
      // If validation passes, navigate to the map page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Interface()), // Replace with your actual map page
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Login Fisher'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Return to the previous screen
          },
        ),
      ),
      body: Container(
        constraints: BoxConstraints.expand(), // Make the container fill the screen
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF012B2E), Color(0xFF0F4235)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Logo taking all available space
            Expanded(
              child: Container(
                alignment: Alignment.center, // Center the logo
                child: Image.asset(
                  'assets/images/logo.jpeg',
                  fit: BoxFit.cover, // Adjust the image to cover the entire area
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    // Full name field
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Fullname',
                        labelStyle: TextStyle(fontSize: 22, color: Colors.white),
                        hintText: 'Enter your full name',
                        filled: true,
                        fillColor: Color(0xFF20D0C4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        } else if (!nameRegExp.hasMatch(value)) {
                          return 'Full name can only contain letters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 25),
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(fontSize: 22, color: Colors.white),
                        hintText: 'Enter your password',
                        filled: true,
                        fillColor: Color(0xFF20D0C4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 25),
                    // Secret Code field
                    TextFormField(
                      controller: _secretCodeController,
                      decoration: InputDecoration(
                        labelText: 'Secret Code',
                        labelStyle: TextStyle(fontSize: 22, color: Colors.white),
                        hintText: 'Enter your secret code',
                        filled: true,
                        fillColor: Color(0xFF20D0C4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your secret code';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 35),
                    // Login button
                    ElevatedButton(
                      onPressed: _navigateToMapPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF20D0C4),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
