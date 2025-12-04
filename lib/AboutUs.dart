import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: Image(image:
            NetworkImage("https://moellim.com/wp-content/uploads/2025/02/2019-09-07-780x470.jpg")),
          ),
          Text(
            'The Riphah University Event Management System is a mobile application designed to streamline event organization within Riphah International University. It allows students, faculty, and organizers to easily view upcoming events, register for activities, receive notifications, and manage event details in one place. Our goal is to create a modern, efficient, and user-friendly platform that enhances communication and participation across the university.'
          ),
        ],
      ),
    );
  }
}
