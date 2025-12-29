import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _rememberMe = false;
  bool _isObscure = true;
  bool _isLoading = false;

  // Hardcoded Admin Credentials
  final String _adminEmail = "admin@ueo.com";
  final String _adminPassword = "adminpassword123";

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 🛡️ Check if it's the Admin
    if (email == _adminEmail && password == _adminPassword) {
      try {
        // Sign in to Firebase Auth as well to satisfy security rules
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/AdminPage");
        }
        return;
      } catch (e) {
        // If Firebase login fails (user not created yet), still allow Admin entry or show error
        print("Admin Firebase Login Error: $e");
      }
    }

    // 👤 Normal User Login
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("remember", true);
        await prefs.setString("email", email);
      }
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/MainPage");
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Login failed"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset("assets/background.png", fit: BoxFit.cover)),
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text("Welcome Back", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text("Login to your account", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 40),
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
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                              validator: (v) => (v == null || !v.contains('@')) ? "Enter a valid email" : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _isObscure,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _isObscure = !_isObscure),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6) ? "Password too short" : null,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v!)),
                                const Text("Remember me"),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _isLoading ? null : _login,
                                child: _isLoading 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Sign In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account?"),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context, "/Signupscreen"),
                                  child: const Text("Sign Up"),
                                ),
                              ],
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
