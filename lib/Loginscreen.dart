import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool ischecked = false;
  String eemail = "";
  String epassword = "";
  final email = TextEditingController();
  final password = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool isobscurepassword = true;
  Future<void> logein()async {
   try{
     await FirebaseAuth.instance.signInWithEmailAndPassword(
         email: email.text,
         password: password.text
     );
if(ischecked){
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool("remember", true);
  prefs.setString("email", email.text.trim());
}
Navigator.pushNamed(context,"/MainPage");
   }on FirebaseAuthException catch(e){
     print("error");
}
   }



  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(color: Colors.deepPurple),
          Positioned(
            bottom: 1,
            child: Container(
              width: 390,
              height: 700,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                ),
                child: Form(
                  key: _formkey,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        const Text(
                          "Welcome Back",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 30),

                        TextFormField(
                          controller: email,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter your email";
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: "Email",
                            hintText: "Enter your email",
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 25),
                        TextFormField(
                          controller: password,
                          obscureText:isobscurepassword,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter your password";
                            }
                          },
                          decoration:  InputDecoration(
                            labelText: "Password",
                            hintText: "Enter your password",
                            prefixIcon: Icon(Icons.lock),
                              suffixIcon: GestureDetector(
                                child: Icon(Icons.remove_red_eye),
                                onTap: (){
                                  setState(() {
                                    isobscurepassword=!isobscurepassword;
                                  });
                                },
                              )
                          )
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: ischecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      ischecked = value!;
                                    });
                                  },
                                ),
                                const Text("Remember me"),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            minimumSize: const Size(300, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              logein();
                            }
                          },
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                            const Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context,"/Signupscreen");
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(fontWeight: FontWeight.bold),
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
          ),
        ],
      ),
    );
  }
}
