import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:omegaproject/Fisher/Fisher_auth/register.dart';
import 'package:omegaproject/auth/Login_Interface.dart';
import 'package:omegaproject/vendeur/home_vendeur.dart';

import '../interface.dart';
import 'forget_password.dart';

class Login extends StatefulWidget {
  @override
  _LoginScreenSt createState() => _LoginScreenSt();
}

class _LoginScreenSt extends State<Login> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;

  // Email validation regex pattern
  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter your email address';
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Attempt to sign in with email and password
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        User? user = userCredential.user;

        if (user != null) {
          // Fetch user data from Firestore
          DocumentSnapshot userData = await _firestore.collection('Fisher_users').doc(user.uid).get();

          if (userData.exists) {
            // Check the user's status
            String status = userData.get('status') ?? '';

            if (status == 'confirmed') {
              // Status is confirmed, navigate to the home page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login successful')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Interface()),
              );
            } else {
              // Status is not confirmed, show a message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your account is awaiting admin approval.')),
              );
            }
          } else {
            // No user data found in Firestore
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No user data found in Firestore')),
            );
          }
        }
      } catch (e) {
        if (e is FirebaseAuthException) {
          String errorMessage;
          // Handling FirebaseAuth-specific error codes
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'No user found with this email. Please check and try again.';
              break;
            case 'wrong-password':
              errorMessage = 'Incorrect password. Please try again.';
              break;
            case 'invalid-email':
              errorMessage = 'The email address is not valid.';
              break;
            default:
              errorMessage = 'Login failed: ${e.message}';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        } else {
          // Handling unexpected errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unexpected error: ${e.toString()}')),
          );
        }
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF012B2E),
        //title: Text('Login Fisher'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 40.0),
          onPressed: () {
            Navigator.pop(context); // Return to the previous screen
          },
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF012B2E), Color(0xFF0F4235)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Background to ensure no white space
            Container(
              height: MediaQuery.of(context).size.height, // Full screen height
              width: MediaQuery.of(context).size.width, // Full screen width
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF012B2E), Color(0xFF0F4235)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),

                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              'Omega Fisherman ',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          Transform.rotate(
                            angle: 0.5,
                            child: Icon(
                              FontAwesomeIcons.fish,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: const TextStyle(fontSize: 22, color: Colors.white),
                          hintText: 'Enter your email address',
                          filled: true,
                          fillColor: const Color(0xFF20D0C4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                        validator: _validateEmail, // Email validation
                      ),
                      const SizedBox(height: 25),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(fontSize: 22, color: Colors.white),
                          hintText: 'Enter your password',
                          filled: true,
                          fillColor: const Color(0xFF20D0C4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 35),

                      // Login Button
                      ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF20D0C4),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Signup Option
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Forgot password?",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ForgotPassword()),
                              );
                            },
                            child: const Text(
                              'Reset it here',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

