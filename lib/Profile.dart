
import 'package:flutter/material.dart';
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("This is User profile",style: TextStyle(fontSize: 21,),),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[ Text(".",style: TextStyle(fontSize: 21,),)]),

    );
  }
}
