import 'package:flutter/material.dart';
class Mapscreen extends StatefulWidget {
  const Mapscreen({super.key});

  @override
  State<Mapscreen> createState() => _MapscreenState();
}

class _MapscreenState extends State<Mapscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Event Map",style: TextStyle(fontSize: 21,),),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Text(".",style: TextStyle(fontSize: 21,),),
          Text("Map",style: TextStyle(fontSize: 21,),),
        ],
      ),

    );
  }
}
