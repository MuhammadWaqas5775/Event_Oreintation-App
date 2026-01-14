import 'package:flutter/material.dart';
import 'package:ueo_app/notification_service.dart';

class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({super.key});

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  bool? _hasPermission;
  String _statusMessage = 'Ready to test notifications';

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await NotificationService().canScheduleExactAlarms();
    setState(() {
      _hasPermission = hasPermission;
      _statusMessage = hasPermission
          ? '✅ Exact alarm permission granted'
          : '⚠️ Exact alarm permission not granted';
    });
  }

  Future<void> _requestPermission() async {
    setState(() {
      _statusMessage = 'Opening system settings...';
    });
    
    await NotificationService().requestExactAlarmPermission();
    
    await Future.delayed(const Duration(seconds: 1));
    await _checkPermission();
  }

  Future<void> _testInstantNotification() async {
    setState(() {
      _statusMessage = 'Sending instant notification...';
    });
    
    await NotificationService().showInstantNotification();
    
    setState(() {
      _statusMessage = '✅ Instant notification sent!';
    });
  }

  Future<void> _test10SecondNotification() async {
    final now = DateTime.now();
    final scheduledFor = now.add(const Duration(seconds: 10));
    
    setState(() {
      _statusMessage = 'Scheduling 10-second notification...';
    });
    
    await NotificationService().scheduleTestNotification();
    
    setState(() {
      _statusMessage = '✅ Scheduled for ${scheduledFor.hour}:${scheduledFor.minute}:${scheduledFor.second}\nWait 10 seconds... Keep screen on!';
    });
    
    print('⏰ Notification should appear at: ${scheduledFor.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: _hasPermission == true ? Colors.green.shade50 : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _hasPermission == true ? Icons.check_circle : Icons.warning,
                      size: 48,
                      color: _hasPermission == true ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Permission Section
            const Text(
              'Permission',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _checkPermission,
              icon: const Icon(Icons.refresh),
              label: const Text('Check Permission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            if (_hasPermission == false)
              ElevatedButton.icon(
                onPressed: _requestPermission,
                icon: const Icon(Icons.settings),
                label: const Text('Request Permission'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Test Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _testInstantNotification,
              icon: const Icon(Icons.notifications_active),
              label: const Text('Send Instant Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _hasPermission == true ? _test10SecondNotification : null,
              icon: const Icon(Icons.schedule),
              label: const Text('Schedule 10-Second Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                disabledBackgroundColor: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Instructions Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'How to Test',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Check if permission is granted\n'
                      '2. If not, tap "Request Permission" and enable it in settings\n'
                      '3. Come back and tap "Check Permission" again\n'
                      '4. Test instant notification (should appear immediately)\n'
                      '5. Test 10-second notification (KEEP SCREEN ON during test)\n\n'
                      '⚠️ On Vivo/Oppo phones: Go to Settings → Battery → \n'
                      'Background Power Consumption → Find this app → Allow\n\n'
                      '⚠️ Also disable "Battery Optimization" for this app',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
