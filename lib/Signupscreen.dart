import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Signupscreen extends StatefulWidget {
  final bool showBackButton;
  const Signupscreen({super.key, this.showBackButton = false});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isObscure = true;
  bool _isLoading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (cred.user != null) {
        await cred.user!.updateDisplayName(_nameController.text.trim());
        
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          if (widget.showBackButton) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Success'),
                content: const Text('User added successfully!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? " failed to add user"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showBackButton
          ? AppBar(
              title: const Text("Add User"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset("assets/background.png", fit: BoxFit.cover)),
          Container(color: Colors.black.withOpacity(0.5)),
          
          Center(
            child: SingleChildScrollView(
              padding:  EdgeInsets.all(24.0),
              child: Column(
                children: [
                   Icon(Icons.person_add_outlined, size: 80, color: Colors.white),
                   SizedBox(height: 30),
                  
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person)),
                              validator: (v) => (v == null || v.isEmpty) ? "Enter name" : null,
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                              validator: (v) => (v == null || !v.contains('@')) ? "Enter valid email" : null,
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _isObscure,
                              decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock)),
                              validator: (v) => (v == null || v.length < 6) ? "Min 6 characters" : null,
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _confirmController,
                              obscureText: _isObscure,
                              decoration: const InputDecoration(labelText: "Confirm Password", prefixIcon: Icon(Icons.lock_reset)),
                              validator: (v) => (v != _passwordController.text) ? "Passwords don't match" : null,
                            ),
                            const SizedBox(height: 25),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _isLoading ? null : _signup,
                                child: _isLoading 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Add user", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
