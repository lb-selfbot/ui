import 'package:flutter/material.dart';
import 'package:lightningui/widgets/config_editor.dart';

class EventsConfigPage extends StatelessWidget {
  const EventsConfigPage({super.key});

  static var fields = [
    {
      'name': 'Ban Notifier',
      'type': 'switch',
      'jsonQuery': '/Events/BanNotifier',
      'set': (Map<String, dynamic> config, bool value) {
        config['Events']['BanNotifier'] = value;
        return config;
      },
      'info': 'You will be notified when you get banned from a server.',
    },
    {
      'name': 'DM Notifier',
      'type': 'switch',
      'jsonQuery': '/Events/DMNotifier',
      'set': (Map<String, dynamic> config, bool value) {
        config['Events']['DMNotifier'] = value;
        return config;
      },
      'info': 'You will be notified when someone sends you a DM.',
    },
    {
      'name': 'DM Edit Notifier',
      'type': 'switch',
      'jsonQuery': '/Events/DMEditNotifier',
      'set': (Map<String, dynamic> config, bool value) {
        config['Events']['DMEditNotifier'] = value;
        return config;
      },
      'info': 'You will be notified when someone edits a DM sent to you.',
    },
    {
      'name': 'DM Delete Notifier',
      'type': 'switch',
      'jsonQuery': '/Events/DMDeleteNotifier',
      'set': (Map<String, dynamic> config, bool value) {
        config['Events']['DMDeleteNotifier'] = value;
        return config;
      },
      'info': 'You will be notified when someone deletes a DM sent to you.',
    },
    {
      'name': 'DM Typing Notifier',
      'type': 'switch',
      'jsonQuery': '/Events/DMTypingNotifier',
      'set': (Map<String, dynamic> config, bool value) {
        config['Events']['DMTypingNotifier'] = value;
        return config;
      },
      'info': 'You will be notified when someone is typing in your DMs.',
    },
    {
      'name': 'Discord Staff Detection',
      'type': 'switch',
      'jsonQuery': '/Events/DiscordStaffDetection',
      'set': (Map<String, dynamic> config, bool value) {
        config['Events']['DiscordStaffDetection'] = value;
        return config;
      },
      'info': 'You will be notified when a Discord staff member is detected.',
    },
    {
      'name': 'Ghost Ping Detection',
      'type': 'switch',
      'jsonQuery': '/Events/GhostPingDetection',
      'set': (Map<String, dynamic> config, bool value) {
        config['Events']['GhostPingDetection'] = value;
        return config;
      },
      'info':
          'You will be notified when you are pinged and the message is deleted.',
    },
    {
      'name': 'Message Delete Notifier',
      'type': 'switch',
      'jsonQuery': '/Events/MessageDeleteNotifier',
      'set': (Map<String, dynamic> config, bool value) {
        config['Events']['MessageDeleteNotifier'] = value;
        return config;
      },
      'info': 'You will be notified when a message is deleted.',
    },
    {
      'name': 'Selfbot Detection',
      'type': 'switch',
      'jsonQuery': '/Events/SelfbotDetection',
      'set': (Map<String, dynamic> config, bool value) {
        config['Events']['SelfbotDetection'] = value;
        return config;
      },
      'info': 'You will be notified when a user is detected using a selfbot.',
    },
    {
      'name': 'Ticket Notifier',
      'type': 'switch',
      'jsonQuery': '/Events/TicketNotifier',
      'set': (Map<String, dynamic> config, bool value) {
        config['Events']['TicketNotifier'] = value;
        return config;
      },
      'info':
          'You will be notified when a ticket is opened in a server your are administrating.',
    },
    {
      'name': 'Session Connected',
      'type': 'switch',
      'jsonQuery': '/Events/SessionConnected',
      'set': (Map<String, dynamic> config, bool value) {
        config['Events']['SessionConnected'] = value;
        return config;
      },
      'info':
          'You will be notified when a device is logged in to your Discord account.',
    },
    {
      'name': 'Session Disconnected',
      'type': 'switch',
      'jsonQuery': '/Events/SessionDisconnected',
      'set': (Map<String, dynamic> config, bool value) {
        config['Events']['SessionDisconnected'] = value;
        return config;
      },
      'info':
          'You will be notified when a device is logged out of your Discord account.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ConfigEditor(fields: fields);
  }
}
