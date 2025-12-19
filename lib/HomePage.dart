import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ueo_app/RegistrationScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> events = [
    {
      "title": 'Event 1',
      "day": "Monday",
      "date": Icons.calendar_today,
      "price": "500",
      "subevents": [
        {"icon": Icons.event, "description": "this is an event"},
        {"icon": Icons.event, "description": "this is an event"},
        {"icon": Icons.event, "description": "this is an event"},
      ],
      "detail": [
        {
          "description": "Detailed info about Event 1",
          "imgurl": "assets/b.jpg",
        },
      ],
    },
    {
      "title": 'Event 2',
      "day": "Tuesday",
      "date": Icons.calendar_today,
      "price": "750",
      "subevents": [
        {"icon": Icons.event, "description": "this is an event"},
        {"icon": Icons.event, "description": "this is an event"},
        {"icon": Icons.event, "description": "this is an event"},
      ],
      "detail": [
        {
          "description": "Detailed info about Event 2",
          "imgurl": "assets/img.png",
        },
      ],
    },
    {
      "title": 'Event 3',
      "day": "Wednesday",
      "date": Icons.calendar_today,
      "price": "1000",
      "subevents": [
        {"icon": Icons.event, "description": "this is an event"},
        {"icon": Icons.event, "description": "this is an event"},
        {"icon": Icons.event, "description": "this is an event"},
      ],
      "detail": [
        {
          "description": "Detailed info about Event 3",
          "imgurl": "assets/back.png",
        },
      ],
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20,),
              const Text("Upcoming Events",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
              const SizedBox(height: 20,),
              CarouselSlider(
                options: CarouselOptions(height: 400.0, enableInfiniteScroll: false),
                items: events.map((event) {
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return DraggableScrollableSheet(
                                initialChildSize: 0.6,
                                minChildSize: 0.4,
                                maxChildSize: 0.9,
                                expand: false,
                                builder: (_, scrollController) {
                                  return SingleChildScrollView(
                                    controller: scrollController,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Center(child: Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                                          const SizedBox(height: 10),
                                          Text(event['detail'][0]['description']),
                                          const SizedBox(height: 20),
                                          const Text("Event Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 10),
                                          Text("Event: ${event['title']}"),
                                          Text("Day: ${event['day']}"),
                                          Text("Ticket Price: Rs ${event['price']}"),
                                          const SizedBox(height: 5),
                                          ...event['subevents'].map<Widget>((subevent) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                                              child: Row(
                                                children: [
                                                  Icon(subevent['icon'], size: 16),
                                                  const SizedBox(width: 8),
                                                  Expanded(child: Text(subevent['description'])),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          const SizedBox(height: 20),
                                          const Text("Registration", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 10),
                                          InkWell(
                                            child: const Text("Click here to register for the event", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                                            onTap: () {
                                              Navigator.pop(context); // Close bottom sheet
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => RegistrationScreen(
                                                    eventTitle: event['title'],
                                                    price: event['price'],
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: AssetImage(event['detail'][0]['imgurl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
