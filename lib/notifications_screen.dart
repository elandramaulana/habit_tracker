import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool notificationsEnabled = false;
  List<String> selectedHabits = [];
  List<String> selectedTimes = [];
  Map<String, String> allHabitsMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
      allHabitsMap = Map<String, String>.from(
        jsonDecode(prefs.getString('selectedHabitsMap') ?? '{}'),
      );
      selectedHabits = prefs.getStringList('notificationHabits') ?? [];
      selectedTimes = prefs.getStringList('notificationTimes') ?? [];
    });
  }

  Future<void> _saveNotificationSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', notificationsEnabled);
    await prefs.setStringList('notificationHabits', selectedHabits);
    await prefs.setStringList('notificationTimes', selectedTimes);
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add opacity if not included.
    }
    return Color(int.parse('0x$hexColor'));
  }

  Future<void> _sendTestNotification() async {
    // ✅ PERBAIKAN: Gunakan SnackBar sebagai placeholder
    // Untuk implementasi real notification, gunakan flutter_local_notifications

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔔 Test Notification',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text("It's time to work on your habits!"),
            if (selectedHabits.isNotEmpty) ...[
              SizedBox(height: 4),
              Text('Habits: ${selectedHabits.join(", ")}'),
            ],
            if (selectedTimes.isNotEmpty) ...[
              SizedBox(height: 4),
              Text('Times: ${selectedTimes.join(", ")}'),
            ],
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (kIsWeb) {
      print('Web notification would be sent here');
      print('Selected habits: ${selectedHabits.join(", ")}');
      print('Selected times: ${selectedTimes.join(", ")}');
    } else {
      print('Mobile notification would be sent here');
      // TODO: Implement flutter_local_notifications
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Text('Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Enable Notifications'),
              subtitle: Text('Turn on to receive habit reminders'),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
                _saveNotificationSettings();
              },
            ),
            Divider(),
            SizedBox(height: 10),
            Text(
              'Select Habits for Notification',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            allHabitsMap.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No habits available. Add habits first!',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: allHabitsMap.entries.map((entry) {
                      final habit = entry.key;
                      final colorHex = entry.value;
                      final color = _getColorFromHex(colorHex);
                      return FilterChip(
                        label: Text(habit),
                        labelStyle: TextStyle(
                          color: selectedHabits.contains(habit)
                              ? Colors.white
                              : color,
                          fontWeight: FontWeight.bold,
                        ),
                        selected: selectedHabits.contains(habit),
                        selectedColor: color,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: color, width: 2.0),
                        checkmarkColor: Colors.white,
                        onSelected: notificationsEnabled
                            ? (bool selected) {
                                setState(() {
                                  if (selected) {
                                    selectedHabits.add(habit);
                                  } else {
                                    selectedHabits.remove(habit);
                                  }
                                });
                                _saveNotificationSettings();
                              }
                            : null, // Disable jika notifications off
                      );
                    }).toList(),
                  ),
            SizedBox(height: 20),
            Text(
              'Select Times for Notification',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildTimeChip('Morning', '🌅', '8:00 AM'),
                _buildTimeChip('Afternoon', '☀️', '2:00 PM'),
                _buildTimeChip('Evening', '🌙', '8:00 PM'),
              ],
            ),
            SizedBox(height: 20),
            // Summary Card
            if (notificationsEnabled &&
                selectedHabits.isNotEmpty &&
                selectedTimes.isNotEmpty)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📋 Notification Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You will receive notifications for ${selectedHabits.length} habit(s)',
                      ),
                      Text('at ${selectedTimes.length} time(s) per day'),
                      SizedBox(height: 8),
                      Text(
                        'Selected habits: ${selectedHabits.join(", ")}',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Selected times: ${selectedTimes.join(", ")}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            Spacer(),
            // Test Notification Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    notificationsEnabled &&
                        selectedHabits.isNotEmpty &&
                        selectedTimes.isNotEmpty
                    ? _sendTestNotification
                    : null,
                icon: Icon(Icons.notifications_active),
                label: Text('Send Test Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ),
            SizedBox(height: 8),
            if (!notificationsEnabled ||
                selectedHabits.isEmpty ||
                selectedTimes.isEmpty)
              Center(
                child: Text(
                  'Enable notifications and select habits & times first',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(String time, String emoji, String timeDetail) {
    final isSelected = selectedTimes.contains(time);
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                timeDetail,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
      selected: isSelected,
      selectedColor: Colors.blue.shade700,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.blue.shade700 : Colors.grey,
        width: 2.0,
      ),
      checkmarkColor: Colors.white,
      onSelected: notificationsEnabled
          ? (bool selected) {
              setState(() {
                if (selected) {
                  selectedTimes.add(time);
                } else {
                  selectedTimes.remove(time);
                }
              });
              _saveNotificationSettings();
            }
          : null,
    );
  }
}
