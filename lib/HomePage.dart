import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
    return Center(
      child: Stack(
          children:[ Container(
            width:double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(""),fit: BoxFit.cover),
            ),
            child: Column(
              children: [
                SizedBox(height: 50,),
                Text("Schedule",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                Text("Upcoming Events",style:TextStyle(fontSize: 23,fontWeight: FontWeight.bold) ,),
                SizedBox(height: 50,),
                CarouselSlider(
                  options: CarouselOptions(height: 400.0,enableInfiniteScroll: false),
                  items: events.map((event) {
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: (){
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true, // IMPORTANT: Allows the sheet to have a custom height
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Container(
                                        height:600,
                                        decoration: BoxDecoration(borderRadius:BorderRadius.circular(40)),
                                        width: MediaQuery.of(context).size.width,
                                        child: SingleChildScrollView(
                                          child: Column(
                                              children: event['detail'].map<Widget>((detail) {
                                                return Padding(
                                                    padding: const EdgeInsets.only(bottom: 15.0),
                                                    child: Column(
                                                        children: [
                                                          Text(detail['description'],style: TextStyle(fontSize: 20,),),
                                                          Container(
                                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(40),),
                                                              child: Image(image:AssetImage(detail['imgurl']),fit: BoxFit.cover,)),
                                                        ]
                                                    ));
                                              }
                                              ).toList()
                                          ),
                                        )
                                    ),
                                  );
                                }
                            );
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              padding:EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(18.0)
                              ),
                              child: Column(
                                  children: [
                                    Text(
                                      event['title'],
                                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Colors.white),
                                    ),
                                    Text(event['day'],
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                                    ),
                                    SizedBox(height: 10,),
                                    Icon(event['date'],color: Colors.white,),
                                    SizedBox(height:30),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: event['subevents'].length,
                                        itemBuilder: (context, index) => Card(
                                          child: ListTile(
                                            leading: Icon(event['subevents'][index]['icon']),
                                            title: Text(event['subevents'][index]['description']),
                                          ),
                                        ),
                                      ),
                                    )
                                  ]
                              )
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          ]),
    );
  }
}
