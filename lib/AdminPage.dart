import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ueo_app/services/admin_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final AdminService _adminService = AdminService();
  int _selectedIndex = 0;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Admin Panel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset("assets/background.png", fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.6))),
          SafeArea(
            child: Row(
              children: [
                NavigationRail(
                  backgroundColor: Colors.transparent,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    if (index == 2) {
                      _logout();
                    } else {
                      setState(() => _selectedIndex = index);
                    }
                  },
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: const IconThemeData(color: Colors.deepPurpleAccent),
                  unselectedIconTheme: const IconThemeData(color: Colors.white70),
                  selectedLabelTextStyle: const TextStyle(color: Colors.deepPurpleAccent),
                  unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.event), label: Text('Events')),
                    NavigationRailDestination(icon: Icon(Icons.people), label: Text('Users')),
                    NavigationRailDestination(icon: Icon(Icons.logout), label: Text('Logout')),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Colors.white10),
                Expanded(
                  child: _selectedIndex == 0 ? const EventManagement() : const UserManagement(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventManagement extends StatelessWidget {
  const EventManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => showDialog(context: context, builder: (_) => const EventDialog()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: adminService.getEvents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final events = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                color: Colors.white.withOpacity(0.1),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      event['detail'][0]['imgurl'], 
                      width: 50, height: 50, fit: BoxFit.cover, 
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white)
                    ),
                  ),
                  title: Text(event['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("${event['category']} • Rs ${event['price']}", style: const TextStyle(color: Colors.white70)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent), onPressed: () => showDialog(context: context, builder: (_) => EventDialog(event: event))),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => adminService.deleteEvent(event['id'])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UserManagement extends StatelessWidget {
  const UserManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: adminService.getUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final users = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              color: Colors.white.withOpacity(0.1),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: (user['profileImageUrl'] != null && user['profileImageUrl'] != "") ? NetworkImage(user['profileImageUrl']) : null,
                  child: user['profileImageUrl'] == null ? const Icon(Icons.person) : null,
                ),
                title: Text(user['displayName'] ?? "User", style: const TextStyle(color: Colors.white)),
                subtitle: Text(user['email'] ?? "", style: const TextStyle(color: Colors.white70)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => adminService.deleteUser(user['uid']),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class EventDialog extends StatefulWidget {
  final Map<String, dynamic>? event;
  const EventDialog({super.key, this.event});
  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();
  late TextEditingController _title, _cat, _date, _day, _price, _desc;
  List<Map<String, dynamic>> _subEvents = [];
  XFile? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.event?['title']);
    _cat = TextEditingController(text: widget.event?['category']);
    _date = TextEditingController(text: widget.event?['date']);
    _day = TextEditingController(text: widget.event?['day']);
    _price = TextEditingController(text: widget.event?['price']);
    _desc = TextEditingController(text: widget.event?['detail'][0]['description']);
    if (widget.event != null && widget.event!['subevents'] != null) {
      _subEvents = List<Map<String, dynamic>>.from(widget.event!['subevents']);
    }
  }

  void _addSubEvent() {
    setState(() => _subEvents.add({"description": ""}));
  }

  void _removeSubEvent(int index) {
    setState(() => _subEvents.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(widget.event == null ? "New Event" : "Edit Event", style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      if (_imageFile != null) 
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10), 
                          child: kIsWeb ? Image.network(_imageFile!.path, height: 150) : Image.file(File(_imageFile!.path), height: 150)
                        )
                      else if (widget.event != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(widget.event!['detail'][0]['imgurl'], height: 150, fit: BoxFit.cover)
                        ),
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (picked != null) setState(() => _imageFile = picked);
                        }, 
                        icon: const Icon(Icons.image), 
                        label: const Text("Select Event Poster")
                      ),
                    ],
                  ),
                ),
                _buildField(_title, "Title"),
                _buildField(_cat, "Category"),
                _buildField(_date, "Date (Oct 25)"),
                _buildField(_day, "Day (Monday)"),
                _buildField(_price, "Price"),
                _buildField(_desc, "Description", maxLines: 3),
                const SizedBox(height: 20),
                const Text("Sub-events / Highlights", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                ..._subEvents.asMap().entries.map((entry) {
                  int idx = entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _subEvents[idx]['description'],
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Subevent description",
                              hintStyle: TextStyle(color: Colors.white38),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                            ),
                            onChanged: (v) => _subEvents[idx]['description'] = v,
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.remove_circle, color: Colors.redAccent), onPressed: () => _removeSubEvent(idx)),
                      ],
                    ),
                  );
                }).toList(),
                TextButton.icon(onPressed: _addSubEvent, icon: const Icon(Icons.add), label: const Text("Add Highlight")),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        _isSaving ? const CircularProgressIndicator() : ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
          onPressed: _save, 
          child: const Text("Save Event", style: TextStyle(color: Colors.white))
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple)),
        ),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      if (widget.event == null) {
        await _adminService.addEvent(
          title: _title.text, 
          category: _cat.text, 
          date: _date.text, 
          day: _day.text, 
          price: _price.text, 
          description: _desc.text, 
          imageFile: _imageFile, 
          subEvents: _subEvents
        );
      } else {
        await _adminService.updateEvent(
          eventId: widget.event!['id'], 
          title: _title.text, 
          category: _cat.text, 
          date: _date.text, 
          day: _day.text, 
          price: _price.text, 
          description: _desc.text, 
          newImageFile: _imageFile, 
          existingImageUrl: widget.event!['detail'][0]['imgurl'], 
          subEvents: _subEvents
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }
}
