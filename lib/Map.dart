import 'package:flutter/material.dart';
class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Event Map",style: TextStyle(fontSize: 21,),),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[ Text(".",style: TextStyle(fontSize: 21,),)]),

    );
  }
}
