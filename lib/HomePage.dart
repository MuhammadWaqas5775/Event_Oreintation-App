import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ueo_app/RegistrationScreen.dart';
import 'package:intl/intl.dart';
import 'package:ueo_app/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = "All";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      NotificationService().showInstantNotification();
    });
  }

  void _scheduleNotificationsForEvents(List<Map<String, dynamic>> events) {
    for (var event in events) {
      DateTime? eventDateTime = _parseDateTime(event['date'], event['time']);
      if (eventDateTime != null) {
        NotificationService().scheduleEventNotification(
          id: event['id'].hashCode,
          title: "Event Starting Soon!",
          body: "The event '${event['title']}' is starting now.",
          scheduleDate: eventDateTime,
        );
      }
    }
  }

  DateTime? _parseDateTime(String dateStr, String? timeStr) {
    try {
      final now = DateTime.now();
      final currentYear = now.year;
      
      String finalTimeStr = timeStr ?? "12:00 PM";
      
      DateTime parsed = DateFormat("MMM dd yyyy hh:mm a").parse("$dateStr $currentYear $finalTimeStr");
      
      if (parsed.isBefore(now)) {
        parsed = DateTime(currentYear + 1, parsed.month, parsed.day, parsed.hour, parsed.minute);
      }
      return parsed;
    } catch (e) {
      print("Error parsing date/time: $e");
      return null;
    }
  }

  IconData _getCategoryIcon(String category) {
    String cat = category.toLowerCase().trim();
    if (cat.contains("music") || cat.contains("art")) return Icons.music_note;
    if (cat.contains("tech") || cat.contains("science")) return Icons.science;
    if (cat.contains("business") || cat.contains("work")) return Icons.business;
    if (cat.contains("sport") || cat.contains("play")) return Icons.sports_basketball;
    if (cat.contains("food") || cat.contains("cook")) return Icons.fastfood;
    if (cat.contains("workshop") || cat.contains("learn")) return Icons.architecture;
    if (cat == "all") return Icons.grid_view;
    return Icons.star_border; 
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));

        final List<Map<String, dynamic>> events = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        if (events.isEmpty) return const Center(child: Text("No events available", style: TextStyle(color: Colors.white70)));

        _scheduleNotificationsForEvents(events);

        final categories = ["All", ...events.map((e) => e['category'] as String).toSet()];
        final filteredEvents = selectedCategory == "All"
            ? events
            : events.where((e) => e['category'] == selectedCategory).toList();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text("Explore Events", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white, letterSpacing: 1.2)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Find what interests you today", style: TextStyle(color: Colors.white70, fontSize: 16)),
              ),
              const SizedBox(height: 30),
              CarouselSlider(
                options: CarouselOptions(
                  height: 480.0,
                  enlargeCenterPage: true,
                  autoPlay: filteredEvents.length > 1,
                  viewportFraction: 0.85,
                ),
                items: filteredEvents.map((event) {
                  return Builder(
                    builder: (BuildContext context) {
                      String imgUrl = event['detail'][0]['imgurl'];
                      return GestureDetector(
                        onTap: () => _showEventDetails(context, event),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25.0),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: imgUrl.startsWith('http') 
                                    ? Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                                    : Image.asset(imgUrl, fit: BoxFit.cover),
                                ),
                                Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)])))),
                                Positioned(
                                  bottom: 25, left: 20, right: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(8)), child: Text(event['category'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                                      const SizedBox(height: 8),
                                      Text(event['title'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                                          const SizedBox(width: 5),
                                          Text("${event['day']}, ${event['date']}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                          const Spacer(),
                                          Text("Rs ${event['price']}", style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
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
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryCard(_getCategoryIcon(category), category, selectedCategory == category, () => setState(() => selectedCategory = category));
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.deepPurpleAccent : Colors.white12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
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
            String imgUrl = event['detail'][0]['imgurl'];
            return Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                          child: imgUrl.startsWith('http')
                            ? Image.network(imgUrl, height: 250, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                            : Image.asset(imgUrl, height: 250, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Positioned(top: 15, right: 20, child: CircleAvatar(backgroundColor: Colors.black26, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)))),
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
                              Expanded(child: Text(event['title'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
                              Text("Rs ${event['price']}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(children: [const Icon(Icons.calendar_month, color: Colors.grey, size: 18), const SizedBox(width: 8), Text("${event['day']}, ${event['date']} at ${event['time'] ?? '12:00 PM'}", style: const TextStyle(color: Colors.grey, fontSize: 16))]),
                          const Divider(height: 40),
                          const Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(event['detail'][0]['description'], style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5)),
                          const SizedBox(height: 30),
                          const Text("Highlights", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          ...((event['subevents'] as List?) ?? []).map<Widget>((subevent) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.check_circle_outline, color: Colors.deepPurple, size: 20)),
                                  const SizedBox(width: 15),
                                  Text(subevent['description'] ?? "Highlight", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity, height: 55,
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationScreen(eventTitle: event['title'], price: event['price']))),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
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
