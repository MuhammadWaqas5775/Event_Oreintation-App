import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ueo_app/RegistrationScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> events = [
    {
      "title": 'Summer Festival 2024',
      "day": "Monday",
      "date": "Oct 25",
      "price": "500",
      "category": "Music & Arts",
      "subevents": [
        {"icon": Icons.music_note, "description": "Live Concert"},
        {"icon": Icons.brush, "description": "Art Exhibition"},
        {"icon": Icons.fastfood, "description": "Food Stalls"},
      ],
      "detail": [
        {
          "description": "Experience the ultimate summer vibes with live performances from top artists, stunning art installations, and a variety of delicious local cuisines. Don't miss out on this unforgettable day!",
          "imgurl": "assets/b.jpg",
        },
      ],
    },
    {
      "title": 'Tech Innovation Summit',
      "day": "Tuesday",
      "date": "Nov 12",
      "price": "750",
      "category": "Technology",
      "subevents": [
        {"icon": Icons.laptop, "description": "Keynote Speeches"},
        {"icon": Icons.code, "description": "Coding Workshop"},
        {"icon": Icons.handyman, "description": "Product Demos"},
      ],
      "detail": [
        {
          "description": "Join industry leaders and tech enthusiasts for a day of inspiring talks, hands-on workshops, and a first look at the latest technological advancements shaping our future.",
          "imgurl": "assets/img.png",
        },
      ],
    },
    {
      "title": 'Corporate Networking',
      "day": "Wednesday",
      "date": "Dec 05",
      "price": "1000",
      "category": "Business",
      "subevents": [
        {"icon": Icons.people, "description": "Networking Session"},
        {"icon": Icons.work, "description": "Career Fair"},
        {"icon": Icons.business, "description": "Panel Discussion"},
      ],
      "detail": [
        {
          "description": "Expand your professional network and discover new opportunities. Meet with representatives from top companies and engage in meaningful discussions about the business landscape.",
          "imgurl": "assets/back.png",
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                "Explore Events",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Find what interests you today",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            CarouselSlider(
              options: CarouselOptions(
                height: 480.0,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                enableInfiniteScroll: true,
                viewportFraction: 0.85,
              ),
              items: events.map((event) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () => _showEventDetails(context, event),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                  event['detail'][0]['imgurl'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 25,
                                left: 20,
                                right: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        event['category'],
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      event['title'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                                        const SizedBox(width: 5),
                                        Text(
                                          "${event['day']}, ${event['date']}",
                                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "Rs ${event['price']}",
                                          style: const TextStyle(
                                            color: Colors.amber,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            _buildSectionHeader("Popular Collections"),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                children: [
                  _buildCategoryCard(Icons.music_note, "Music"),
                  _buildCategoryCard(Icons.sports_basketball, "Sports"),
                  _buildCategoryCard(Icons.theater_comedy, "Drama"),
                  _buildCategoryCard(Icons.fastfood, "Food"),
                  _buildCategoryCard(Icons.science, "Tech"),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("See All", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String label) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showEventDetails(BuildContext context, Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                          child: Image.asset(
                            event['detail'][0]['imgurl'],
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 15,
                          right: 20,
                          child: CircleAvatar(
                            backgroundColor: Colors.black26,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  event['title'],
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                "Rs ${event['price']}",
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_month, color: Colors.grey, size: 18),
                              const SizedBox(width: 8),
                              Text("${event['day']}, ${event['date']}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                          const Divider(height: 40),
                          const Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(
                            event['detail'][0]['description'],
                            style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                          ),
                          const SizedBox(height: 30),
                          const Text("Highlights", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          ...event['subevents'].map<Widget>((subevent) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(subevent['icon'], color: Colors.deepPurple, size: 20),
                                  ),
                                  const SizedBox(width: 15),
                                  Text(subevent['description'], style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 5,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
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
                              child: const Text("Register Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
