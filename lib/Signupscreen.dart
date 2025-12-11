import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Import Firestore
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});
  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmpassword = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  bool isobscurepassword = true;
  bool isobscureconfirmpassword = true;

  // --- FIX: Updated the signup function to save user data ---
  Future<void> signup() async {
    // Validate the form first
    if (!_formkey.currentState!.validate()) {
      return;
    }

    try {
      // Step 1: Create the user in Firebase Authentication
      final UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(), // Use .trim() to remove extra spaces
        password: password.text.trim(),
      );

      final User? user = userCredential.user;

      // Step 2: If the user was created, save their data to Firestore
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name.text.trim(),
          'email': email.text.trim(),
          'profileImageUrl': null, // Set image URL to null initially
        });

        // Step 3: Navigate to the login page
        if (mounted) {
          // Use pushNamedAndRemoveUntil to prevent user from going back to signup page
          Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      // Optional: Show a user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "An unknown sign-up error occurred."),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("Firebase Error: \${e.code} → \${e.message}");
    }
  }

  @override
  void dispose() {
    name.dispose(); // Also dispose the name controller
    email.dispose();
    password.dispose();
    confirmpassword.dispose();
    super.dispose();
  }

  // --- NO UI CHANGES BELOW THIS LINE ---
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top:0,
            child: Container(
              height:MediaQuery.of(context).size.height*0.25,
              width:MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(40.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              // child: Text("Get Started",style: TextStyle(fontSize: 2,fontWeight: FontWeight.bold,color: Colors.white),)
            ),
          ),
          Positioned(
            bottom: 1,
            child: Container(
                width:MediaQuery.of(context).size.width,
                height:MediaQuery.of(context).size.height*0.8,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40))),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40)),
                  ),
                  child: Form(
                    key: _formkey,
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: SingleChildScrollView( // Added SingleChildScrollView to prevent overflow
                        child: Column(
                          children: [
                            TextFormField(
                                controller: name,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter your name";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  label: Text("Name"),
                                  hintText: "Name",
                                  prefixIcon: Icon(Icons.person),
                                )),
                            // Text("@isLogedin"),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: email,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter your email";
                                }
                                final emailregex = RegExp(
                                    r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\$');
                                if (!emailregex.hasMatch(value)) {
                                  return "Please enter a valid email";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: Text("Email"),
                                hintText: "Email",
                                prefixIcon: Icon(Icons.email),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter your password";
                                  }
                                  if (value.length < 6) {
                                    return "Password must be at least 6 characters";
                                  }
                                  return null;
                                },
                                controller: password,
                                obscureText: isobscurepassword,
                                decoration: InputDecoration(
                                    label: Text("Password"),
                                    hintText: "Password",
                                    prefixIcon: Icon(Icons.lock),
                                    suffixIcon: GestureDetector(
                                        child: Icon(isobscurepassword
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                        onTap: () {
                                          setState(() {
                                            isobscurepassword =
                                            !isobscurepassword;
                                          });
                                        }))),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter your confirm password";
                                  }
                                  if (value != password.text) {
                                    return "Password does not match";
                                  }
                                  return null;
                                },
                                controller: confirmpassword,
                                obscureText: isobscureconfirmpassword,
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                    label: Text("Confirm Password"),
                                    hintText: "Confirm Password",
                                    prefixIcon: Icon(Icons.lock),
                                    suffixIcon: GestureDetector(
                                      child: Icon(isobscureconfirmpassword
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onTap: () {
                                        setState(() {
                                          isobscureconfirmpassword =
                                          !isobscureconfirmpassword;
                                        });
                                      },
                                    ))),
                            SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(300, 50),
                                  backgroundColor: Colors.deepOrange[100]),
                              onPressed: () {
                                // Moved validation check inside the signup function
                                signup();
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 55.0),
                              child: Row(
                                children: [
                                  Text("Already have an account?"),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, "/");
                                      },
                                      child: Text(
                                        "Sign in",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
            ),
          ),
        ],
      ),
    );
  }
}
