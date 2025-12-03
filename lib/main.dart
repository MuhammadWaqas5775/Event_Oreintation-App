import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Loginscreen.dart';
import 'HomePage.dart';
import 'MainPage.dart';
import 'Memories.dart';
import 'Profile.dart';
import 'Map.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      initialRoute:"/",
      routes:
      {
        "/": (context) => Loginscreen(),
        "/Signupscreen": (context) => Signupscreen(),
        "/MainPage": (context) => MainPage(),
        "/HomePage": (context) => HomePage(),
        "/Memories":(context)=> Memories(),
        "/Map":(context)=>Map(),
        "/Profile":(context)=>Profile(),
      },
      debugShowCheckedModeBanner: false,

    );
  }
}
class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});
  @override
  State<Signupscreen> createState() => _SignupscreenState();
}
class _SignupscreenState extends State<Signupscreen> {
  final name=TextEditingController();
  final email=TextEditingController();
  final password=TextEditingController();
  final confirmpassword=TextEditingController();
final _formkey=GlobalKey<FormState>();
bool isobscurepassword=true;
bool isobscureconfirmpassword=true;
Future<void>_saveuser()async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("email", email.text);
  await prefs.setString("password", password.text);

  if (mounted)
  {
    Navigator.pushNamed(context, "/");
  }
}
  @override
void dispose(){
  email.dispose();
  password.dispose();
  super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return
      Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(40.0),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                ),
              // child: Text("Get Started",style: TextStyle(fontSize: 2,fontWeight: FontWeight.bold,color: Colors.white),)
            ),
            Positioned(
              bottom: 1,
              child: Container(
                  width: 390,
                  height: 700,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40)
                      )
                  ),
                  child:Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40)),
                    ),
                    child: Form(
key: _formkey,
                      child: Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            TextFormField(
                                controller: name,
                                validator: (value){
                                  if(value!.isEmpty){
                                    return "Please enter your name";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  label: Text("Name"),
                                  hintText: "Name",
                                  prefixIcon: Icon(Icons.person),
                                )
                            ),
                            // Text("@isLogedin"),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: email,
                              validator: (value){
                                if(value!.isEmpty){
                                  return "Please enter your email";
                                }
                                final emailregex=RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if(! emailregex.hasMatch(value)){
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
                                validator: (value){
                                  if(value!.isEmpty){
                                    return "Please enter your password";
                                  }
                                  if(value.length<6){
                                    return "Password must be at least 6 characters";
                                  }
                                  return null;
                                },
                                controller: password,
                                obscureText:isobscurepassword,
                                decoration: InputDecoration(
                                    label: Text("Password"),
                                    hintText: "Password",
                                    prefixIcon: Icon(Icons.lock),
                                    suffixIcon: GestureDetector(
                                      child: Icon(Icons.remove_red_eye,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          isobscurepassword = !isobscurepassword;
                                        }
                                        );
                                            }
                                    )
                                )
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                                validator: (value){
                                  if(value!.isEmpty){
                                    return "Please enter your confirm password";
                                  }
                                  if(value!=password.text){
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
                                    child: Icon(Icons.remove_red_eye),
                                    onTap: (){
                                      setState(() {
                                        isobscureconfirmpassword=!isobscureconfirmpassword;
                                      });
                                    },
                                )
                            )
    ),
                            SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(300, 50),
                                  backgroundColor: Colors.deepPurple),
                              onPressed: (){
                                if(_formkey.currentState!.validate()){
                                  _saveuser();
                                }
                              },
                              child: Text("Sign Up",style:TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.white),),
                            ),
                            Padding(
                              padding:  EdgeInsets.only(left:55.0),
                              child: Row(
                                children: [
                                  Text("Already have an account?"),
                                  TextButton(onPressed: (){
                                    Navigator.pushNamed(context,"/");
                                  }, child: Text("Sign in",style: TextStyle(fontWeight: FontWeight.bold),))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
              ),
            )
          ],
        ),
    );
  }
}
