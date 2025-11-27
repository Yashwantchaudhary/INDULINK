import 'package:flutter/material.dart';

class NotificationSettings extends StatefulWidget {
  final VoidCallback onBack;

  const NotificationSettings({super.key, required this.onBack});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  Map<String, bool> settings = {
    'pushNotifications': true,
    'emailNotifications': true,
    'smsNotifications': false,
    'bookingUpdates': true,
    'messageNotifications': true,
    'paymentReminders': true,
    'promotionalOffers': false,
    'securityAlerts': true,
    'newListings': true,
    'priceAlerts': false,
    'quietHours': true,
    'soundEnabled': true,
    'vibrationEnabled': true
  };

  String quietHoursStart = '22:00';
  String quietHoursEnd = '08:00';
  String emailFrequency = 'instant';

  void handleSettingChange(String key, bool value) {
    setState(() {
      settings[key] = value;
    });
  }

  List<Map<String, dynamic>> get notificationGroups => [
    {
      'title': 'Booking & Reservations',
      'icon': Icons.calendar_today,
      'color': Colors.blue,
      'settings': [
        {
          'key': 'bookingUpdates',
          'label': 'Booking confirmations & updates',
          'description': 'Get notified about booking status changes'
        }
      ]
    },
    {
      'title': 'Messages & Communication',
      'icon': Icons.message,
      'color': Colors.green,
      'settings': [
        {
          'key': 'messageNotifications',
          'label': 'New messages',
          'description': 'Notifications when hosts or guests message you'
        }
      ]
    },
    {
      'title': 'Payments & Financial',
      'icon': Icons.attach_money,
      'color': Colors.yellow,
      'settings': [
        {
          'key': 'paymentReminders',
          'label': 'Payment reminders',
          'description': 'Reminders for upcoming payments and due dates'
        }
      ]
    },
    {
      'title': 'Security & Safety',
      'icon': Icons.security,
      'color': Colors.red,
      'settings': [
        {
          'key': 'securityAlerts',
          'label': 'Security alerts',
          'description': 'Important security notifications and login alerts'
        }
      ]
    },
    {
      'title': 'Discovery & Recommendations',
      'icon': Icons.notifications,
      'color': Colors.purple,
      'settings': [
        {
          'key': 'newListings',
          'label': 'New property listings',
          'description': 'Get notified about new properties in your saved areas'
        },
        {
          'key': 'priceAlerts',
          'label': 'Price drop alerts',
          'description': 'Notifications when prices drop for wishlisted properties'
        }
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const Text(
                  'Notification Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Master Controls
                  const Text(
                    'Notification Channels',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchSetting(
                    'Push Notifications',
                    'Receive notifications on your device',
                    'pushNotifications',
                  ),
                  _buildSwitchSetting(
                    'Email Notifications',
                    'Receive notifications via email',
                    'emailNotifications',
                  ),
                  _buildSwitchSetting(
                    'SMS Notifications',
                    'Receive important updates via SMS',
                    'smsNotifications',
                  ),

                  const Divider(height: 32),

                  // Email Frequency
                  if (settings['emailNotifications']!)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email Frequency',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: emailFrequency,
                          onChanged: (value) => setState(() => emailFrequency = value!),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'instant', child: Text('Instant notifications')),
                            DropdownMenuItem(value: 'daily', child: Text('Daily digest')),
                            DropdownMenuItem(value: 'weekly', child: Text('Weekly summary')),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Notification Categories
                  ...notificationGroups.map((group) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  group['icon'] as IconData,
                                  size: 16,
                                  color: group['color'] as Color,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                group['title'] as String,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...group['settings'].map<Widget>((setting) {
                            return Container(
                              margin: const EdgeInsets.only(left: 44, bottom: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          setting['label'] as String,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          setting['description'] as String,
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: settings[setting['key'] as String]!,
                                    onChanged: (!settings['pushNotifications']! && !settings['emailNotifications']!)
                                        ? null
                                        : (value) => handleSettingChange(setting['key'] as String, value),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      )),

                  const Divider(height: 32),

                  // Marketing & Promotions
                  const Text(
                    'Marketing & Promotions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchSetting(
                    'Promotional offers',
                    'Receive special deals and discounts',
                    'promotionalOffers',
                  ),

                  const Divider(height: 32),

                  // Sound & Vibration
                  const Text(
                    'Sound & Vibration',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.volume_up, size: 20, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sound', style: TextStyle(fontWeight: FontWeight.w500)),
                            const Text(
                              'Play notification sounds',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: settings['soundEnabled']!,
                        onChanged: (value) => handleSettingChange('soundEnabled', value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchSetting(
                    'Vibration',
                    'Vibrate for notifications',
                    'vibrationEnabled',
                  ),

                  const Divider(height: 32),

                  // Quiet Hours
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quiet Hours',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const Text(
                            'Mute notifications during these hours',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      Switch(
                        value: settings['quietHours']!,
                        onChanged: (value) => handleSettingChange('quietHours', value),
                      ),
                    ],
                  ),

                  if (settings['quietHours']!)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('From', style: TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: quietHoursStart,
                                  onChanged: (value) => setState(() => quietHoursStart = value!),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: List.generate(24, (i) {
                                    return DropdownMenuItem(
                                      value: '${i.toString().padLeft(2, '0')}:00',
                                      child: Text('${i.toString().padLeft(2, '0')}:00'),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('To', style: TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: quietHoursEnd,
                                  onChanged: (value) => setState(() => quietHoursEnd = value!),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: List.generate(24, (i) {
                                    return DropdownMenuItem(
                                      value: '${i.toString().padLeft(2, '0')}:00',
                                      child: Text('${i.toString().padLeft(2, '0')}:00'),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Reset to Defaults
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          settings = {
                            'pushNotifications': true,
                            'emailNotifications': true,
                            'smsNotifications': false,
                            'bookingUpdates': true,
                            'messageNotifications': true,
                            'paymentReminders': true,
                            'promotionalOffers': false,
                            'securityAlerts': true,
                            'newListings': true,
                            'priceAlerts': false,
                            'quietHours': true,
                            'soundEnabled': true,
                            'vibrationEnabled': true
                          };
                          emailFrequency = 'instant';
                          quietHoursStart = '22:00';
                          quietHoursEnd = '08:00';
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Reset to Default Settings'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(String title, String subtitle, String key) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: settings[key]!,
            onChanged: (value) => handleSettingChange(key, value),
          ),
        ],
      ),
    );
  }
}