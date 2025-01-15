import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:omegaproject/auth/conn_interface.dart';

import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'Login.dart';



class Register extends StatefulWidget {
  @override
  _RegisterScreenSt createState() => _RegisterScreenSt();
}

class _RegisterScreenSt extends State<Register> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  File? _selectedFile; // Variable to store the selected file

  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;



  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Check if the email already exists in the Firestore Fisher_users collection
        var querySnapshot = await _firestore
            .collection('Fisher_users')
            .where('email', isEqualTo: _emailController.text.trim())
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // If email already exists in Firestore Fisher_users
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email already exists in Fisher_users.')),
          );
          return; // Exit function if email is found
        }

        // Register the user with Firebase Auth
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        User? user = userCredential.user;

        if (user != null) {
          // Save user data in Firestore Fisher_users
          await _firestore.collection('Fisher_users').doc(user.uid).set({
            'full_name': _fullNameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone_number': _phoneNumberController.text.trim(),
            'uid': user.uid,
            'date_created': FieldValue.serverTimestamp(),
            'status': 'pending', // Default status
          });

          // Success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful, wait for the confirmation.')),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Email is already registered in Firebase Authentication.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Weak password. Password should be at least 6 characters.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        // Generic error handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section

                  Padding(

                    padding: const EdgeInsets.only(top: 03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Omega Fisherman ',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        Transform.rotate(
                          angle: 0.5, // Adjust this value to control rotation
                          child: Icon(
                            FontAwesomeIcons.fish,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),

                      ],
                    ),
                  ),
                  const SizedBox(height: 70),
                  // Full Name Field
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle:
                      const TextStyle(fontSize: 22, color: Colors.white),
                      hintText: 'Enter your full name',
                      filled: true,
                      fillColor: const Color(0xFF20D0C4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  // Phone Number Field
                  TextFormField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle:
                      const TextStyle(fontSize: 22, color: Colors.white),
                      hintText: 'Enter your phone number',
                      filled: true,
                      fillColor: const Color(0xFF20D0C4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle:
                      const TextStyle(fontSize: 22, color: Colors.white),
                      hintText: 'Enter your email address',
                      filled: true,
                      fillColor: const Color(0xFF20D0C4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    validator: (value) {
                      final emailRegex = RegExp(
                          r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      } else if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle:
                      const TextStyle(fontSize: 22, color: Colors.white),
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
                  const SizedBox(height: 25),
                  // File Upload Button

                  const SizedBox(height: 35),
                  // Register Button
                  ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF20D0C4),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Login()),
                          );
                        },
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
