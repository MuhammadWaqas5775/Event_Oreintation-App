import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ueo_app/services/admin_service.dart';
import 'package:ueo_app/Signupscreen.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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
        title: const Text("Admin Dashboard",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.white)),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset("assets/background.png", fit: BoxFit.cover)),
          Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.7))),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildTabSwitcher(),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: _buildSelectedContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedIndex) {
      case 0: return const EventManagement();
      case 1: return const UserManagement();
      case 2: return const MemoriesManagement();
      default: return const EventManagement();
    }
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedIndex == 0) {
      return FloatingActionButton.extended(
        onPressed: () => showDialog(context: context, builder: (_) => const EventDialog()),
        label: const Text("Add Event"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
      );
    } else if (_selectedIndex == 1) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Signupscreen(showBackButton: true)),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
      );
    }
    return null;
  }

  Widget _buildTabSwitcher() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _tabItem(0, "Events", Icons.event_note),
          _tabItem(1, "Users", Icons.group),
          _tabItem(2, "Uploads", Icons.cloud_upload),
        ],
      ),
    );
  }

  Widget _tabItem(int index, String title, IconData icon) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurpleAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.white70, size: 20),
              const SizedBox(height: 4),
              Text(title,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class EventManagement extends StatelessWidget {
  const EventManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: adminService.getEvents(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!;
        if (events.isEmpty) {
          return const Center(
              child: Text("No events found",
                  style: TextStyle(color: Colors.white70)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    event['detail'][0]['imgurl'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.white10,
                      child: const Icon(Icons.image, color: Colors.white24),
                    ),
                  ),
                ),
                title: Text(event['title'],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text("${event['category']} • ${event['date']} ${event['time'] ?? ''}",
                        style: const TextStyle(color: Colors.white60, fontSize: 13)),
                    Text("Rs ${event['price']}",
                        style: const TextStyle(
                            color: Colors.deepPurpleAccent,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.blueAccent),
                      onPressed: () => showDialog(
                          context: context, builder: (_) => EventDialog(event: event)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _confirmDelete(context, event['id']),
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

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Confirm Delete", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this event?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              AdminService().deleteEvent(id);
              Navigator.pop(ctx);
            },
            child: const Text("Delete"),
          ),
        ],
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
        if (snapshot.hasError) {
          return Center(
              child: Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurpleAccent.withOpacity(0.2),
                  backgroundImage: (user['profileImageUrl'] != null &&
                          user['profileImageUrl'] != "")
                      ? NetworkImage(user['profileImageUrl'])
                      : null,
                  child: user['profileImageUrl'] == null ||
                          user['profileImageUrl'] == ""
                      ? Text(user['displayName']?[0].toUpperCase() ?? "U",
                          style: const TextStyle(color: Colors.white))
                      : null,
                ),
                title: Text(user['displayName'] ?? "User",
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(user['email'] ?? "",
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.person_remove_outlined,
                      color: Colors.redAccent),
                  onPressed: () => AdminService().deleteUser(user['uid']),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MemoriesManagement extends StatelessWidget {
  const MemoriesManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: adminService.getMemories(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final memories = snapshot.data!;
        if (memories.isEmpty) {
          return const Center(child: Text("No uploads found", style: TextStyle(color: Colors.white70)));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: memories.length,
          itemBuilder: (context, index) {
            final memory = memories[index];
            return Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        memory['imageUrl'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            memory['userName'] ?? "User",
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                          onPressed: () => _confirmDeleteMemory(context, memory['id']),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteMemory(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Delete Image?", style: TextStyle(color: Colors.white)),
        content: const Text("This memory will be removed permanently.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              AdminService().deleteMemory(id);
              Navigator.pop(ctx);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
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
  late TextEditingController _title, _cat, _date, _day, _price, _desc, _time;
  List<Map<String, dynamic>> _subEvents = [];
  XFile? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.event?['title']);
    _cat = TextEditingController(text: widget.event?['category']);
    _date = TextEditingController(text: widget.event?['date']);
    _time = TextEditingController(text: widget.event?['time'] ?? "12:00 PM");
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _time.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.event == null ? "New Event" : "Edit Event",
          style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final picked =
                          await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (picked != null) setState(() => _imageFile = picked);
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: kIsWeb
                                  ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                                  : Image.file(File(_imageFile!.path), fit: BoxFit.cover))
                          : (widget.event != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                      widget.event!['detail'][0]['imgurl'],
                                      fit: BoxFit.cover))
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo,
                                        color: Colors.white38, size: 40),
                                    SizedBox(height: 8),
                                    Text("Add Event Poster",
                                        style: TextStyle(color: Colors.white38)),
                                  ],
                                )),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildField(_title, "Title", Icons.title),
                _buildField(_cat, "Category", Icons.category),
                Row(
                  children: [
                    Expanded(child: _buildField(_date, "Date (e.g. Jan 05)", Icons.calendar_today)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectTime,
                        child: AbsorbPointer(
                          child: _buildField(_time, "Time", Icons.access_time),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildField(_day, "Day (e.g. Sunday)", Icons.today),
                _buildField(_price, "Price", Icons.attach_money),
                _buildField(_desc, "Description", Icons.description, maxLines: 3),
                const SizedBox(height: 20),
                const Text("Highlights",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
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
                            decoration: InputDecoration(
                              hintText: "Subevent description",
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none),
                            ),
                            onChanged: (v) => _subEvents[idx]['description'] = v,
                          ),
                        ),
                        IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.redAccent),
                            onPressed: () => _removeSubEvent(idx)),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                    onPressed: _addSubEvent,
                    icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                    label: const Text("Add Highlight")),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
        _isSaving
            ? const CircularProgressIndicator()
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _save,
                child: const Text("Save Event",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          labelStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1)),
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
            time: _time.text,
            day: _day.text,
            price: _price.text,
            description: _desc.text,
            imageFile: _imageFile,
            subEvents: _subEvents);
      } else {
        await _adminService.updateEvent(
            eventId: widget.event!['id'],
            title: _title.text,
            category: _cat.text,
            date: _date.text,
            time: _time.text,
            day: _day.text,
            price: _price.text,
            description: _desc.text,
            newImageFile: _imageFile,
            existingImageUrl: widget.event!['detail'][0]['imgurl'],
            subEvents: _subEvents);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
