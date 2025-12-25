import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ueo_app/RegistrationScreen.dart';
import 'package:ueo_app/notification_service.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = "All"; // Current filter state

  final List<Map<String, dynamic>> events = [
    {
      "id": 1,
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
          "imgurl": "assets/music.jpg",
        },
      ],
    },
    {
      "id": 2,
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
          "imgurl": "assets/Technology.jpg",
        },
      ],
    },
    {
      "id": 3,
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
          "imgurl": "assets/bussiness.jpg",
        },
      ],
    },
    {
      "id": 4,
      "title": 'Championship Finals 2024',
      "day": "Saturday",
      "date": "Nov 30",
      "price": "300",
      "category": "Sports",
      "subevents": [
        {"icon": Icons.sports_soccer, "description": "Live Football Match"},
        {"icon": Icons.emoji_events, "description": "Trophy Ceremony"},
        {"icon": Icons.groups, "description": "Fan Zone Activities"},
      ],
      "detail": [
        {
          "description": "Witness the thrill of the championship finals! Grab your jerseys and cheer for your favorite team in an electric atmosphere filled with sportsmanship and excitement.",
          "imgurl": "assets/sport.jpg",
        },
      ],
    },
    {
      "id": 5,
      "title": 'Global Food Carnival',
      "day": "Sunday",
      "date": "Dec 15",
      "price": "200",
      "category": "Food",
      "subevents": [
        {"icon": Icons.restaurant, "description": "International Cuisines"},
        {"icon": Icons.soup_kitchen, "description": "Cooking Masterclass"},
        {"icon": Icons.celebration, "description": "Street Food Fest"},
      ],
      "detail": [
        {
          "description": "A paradise for food lovers! Taste authentic dishes from around the world, watch top chefs in action, and enjoy a vibrant day dedicated to the joy of eating.",
          "imgurl": "assets/food.jpg",
        },
      ],
    },
    {
      "id": 6,
      "title": 'Creative Arts Workshop',
      "day": "Friday",
      "date": "Oct 18",
      "price": "1200",
      "category": "Workshops",
      "subevents": [
        {"icon": Icons.palette, "description": "Oil Painting Session"},
        {"icon": Icons.architecture, "description": "Sculpting Class"},
        {"icon": Icons.create, "description": "Sketching Basics"},
      ],
      "detail": [
        {
          "description": "Unleash your inner artist in this intensive hands-on workshop. Guided by experts, you will learn techniques in painting and sculpting to create your own masterpiece.",
          "imgurl": "assets/workshops.jpg",
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _scheduleEventNotifications();
  }

  void _scheduleEventNotifications() async {
    for (var event in events) {
      DateTime? eventDate = _parseDate(event['date']);
      if (eventDate != null) {
        await NotificationService().scheduleNotification(
          event['id'],
          "Upcoming Event: ${event['title']}",
          "Your event '${event['title']}' is happening in 3 days!",
          eventDate,
        );
      }
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      int year = 2024;
      return DateFormat("MMM dd yyyy").parse("$dateStr $year");
    } catch (e) {
      return null;
    }
  }

  // Helper to filter events
  bool _eventMatchesCategory(Map<String, dynamic> event, String category) {
    if (category == "All") return true;
    String eventCat = event['category'].toString().toLowerCase();
    String targetCat = category.toLowerCase();

    // Map card labels to data categories
    if (targetCat == "tech") return eventCat.contains("technology");
    if (targetCat == "music" || targetCat == "arts") return eventCat.contains("music") || eventCat.contains("arts");
    
    return eventCat.contains(targetCat);
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = events.where((e) => _eventMatchesCategory(e, _selectedCategory)).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics:  BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Padding(
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
             Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Find what interests you today",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
             SizedBox(height: 30),
            
            // Carousel or Empty State
            filteredEvents.isEmpty 
              ? _buildNoEventsPlaceholder()
              : CarouselSlider(
                  options: CarouselOptions(
                    height: 480.0,
                    enlargeCenterPage: true,
                    autoPlay: filteredEvents.length > 1,
                    autoPlayInterval:  Duration(seconds: 5),
                    enableInfiniteScroll: filteredEvents.length > 1,
                    viewportFraction: 0.85,
                  ),
                  items: filteredEvents.map((event) {
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () => _showEventDetails(context, event),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset:  Offset(0, 8),
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
                                            Colors.black.withValues(alpha: 0.8),
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
                                          padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            event['category'],
                                            style:  TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                         SizedBox(height: 8),
                                        Text(
                                          event['title'],
                                          style:  TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                         SizedBox(height: 4),
                                        Row(
                                          children: [
                                             Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                                             SizedBox(width: 5),
                                            Text(
                                              "${event['day']}, ${event['date']}",
                                              style:  TextStyle(color: Colors.white70, fontSize: 14),
                                            ),
                                             Spacer(),
                                            Text(
                                              "Rs ${event['price']}",
                                              style:  TextStyle(
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
            
             SizedBox(height: 30),
            _buildSectionHeader("Popular Collections"),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:  EdgeInsets.symmetric(horizontal: 15),
                children: [
                  _buildCategoryCard(Icons.grid_view, "All"),
                  _buildCategoryCard(Icons.business_center, "Business"),
                  _buildCategoryCard(Icons.science, "Tech"),
                  _buildCategoryCard(Icons.music_note, "Music"),
                  _buildCategoryCard(Icons.brush, "Arts"),
                  _buildCategoryCard(Icons.sports_basketball, "Sports"),
                  _buildCategoryCard(Icons.school, "Workshops"),
                  _buildCategoryCard(Icons.fastfood, "Food"),
                ],
              ),
            ),
             SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNoEventsPlaceholder() {
    return Container(
      height: 480,
      width: double.infinity,
      margin:  EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(25),
      ),
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, color: Colors.white30, size: 80),
          SizedBox(height: 20),
          Text("No events in this category yet", style: TextStyle(color: Colors.white70, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = "All";
              });
            },
            child:  Text("See All", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String label) {
    bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: AnimatedContainer(
        duration:  Duration(milliseconds: 300),
        width: 100,
        margin:  EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.deepPurpleAccent : Colors.white12),
          boxShadow: isSelected ? [BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 10)] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white70, size: 30),
             SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.w500)),
          ],
        ),
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
              decoration:  BoxDecoration(
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
                          borderRadius:  BorderRadius.vertical(top: Radius.circular(30)),
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
                              icon:  Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding:  EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  event['title'],
                                  style:  TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                "Rs ${event['price']}",
                                style:  TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                              ),
                            ],
                          ),
                           SizedBox(height: 8),
                          Row(
                            children: [
                               Icon(Icons.calendar_month, color: Colors.grey, size: 18),
                               SizedBox(width: 8),
                              Text("${event['day']}, ${event['date']}", style:  TextStyle(color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                           Divider(height: 40),
                           Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                           SizedBox(height: 12),
                          Text(
                            event['detail'][0]['description'],
                            style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                          ),
                           SizedBox(height: 30),
                           Text("Highlights", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                           SizedBox(height: 15),
                          ...event['subevents'].map<Widget>((subevent) {
                            return Padding(
                              padding:  EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding:  EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(subevent['icon'], color: Colors.deepPurple, size: 20),
                                  ),
                                   SizedBox(width: 15),
                                  Text(
                                    subevent['description'],
                                    style:  TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                           SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () {
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child:  Text(
                                "Register Now",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                           SizedBox(height: 20),
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
