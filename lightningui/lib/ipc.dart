import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:lightningui/launching.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

abstract class OP {
  static const int connected = 98;
  static const int hello = 99;
  static const int exit = 100;
  static const int restart = 101;
  static const int notification = 102;
  static const int invalidToken = 103;
  static const int error = 104;
  static const int configUpdate = 105;
  static const int newToken = 106;
  static const int consoleAppend = 107;
  static const int consoleClear = 108;
  static const int consoleSet = 109;
}

class IPC {
  static WebSocketChannel? channel;

  static bool websocketConnected = false;

  static String defaultConsoleString =
      '<image Source="assets/Banner.png" Width="650" Height="150" Centered />\n<text Color="#C1EFFF" Centered>Waiting for launch...</text>';
  static String consoleString = defaultConsoleString;

  static Map<String, Function()> onChangeListeners = {};
  static Map<String, Function()> onConfigChangeListeners = {};

  static void callListeners(Map<String, Function()> listeners) {
    try {
      listeners.forEach((_, listener) {
        listener();
      });
    } catch (e) {
      log("Error calling listeners: $e");
    }
  }

  static void addChangeListener(String name, Function() listener) =>
      onChangeListeners[name] = listener;
  static void removeChangeListener(String name) =>
      onChangeListeners.remove(name);

  static void addConfigChangeListener(String name, Function() listener) =>
      onConfigChangeListeners[name] = listener;
  static void removeConfigChangeListener(String name) =>
      onConfigChangeListeners.remove(name);

  static void connect() {
    try {
      channel = IOWebSocketChannel.connect('ws://localhost:13249/');
      channel!.stream.listen(
        onMessage,
        onDone: () {
          channel = null;
          websocketConnected = false;
          tryConnect();
          onDisconnect();
          callListeners(onChangeListeners);
        },
        onError: (Object error) {
          channel = null;
          websocketConnected = false;
          onDisconnect();
          callListeners(onChangeListeners);
        },
      );
    } catch (e) {
      return;
    }
  }

  static void onDisconnect() {
    consoleString = defaultConsoleString;
  }

  static void tryConnect() {
    Future.doWhile(() async {
      return Socket.connect(InternetAddress.loopbackIPv4, 13249).then((socket) {
        try {
          socket.address;
        } on SocketException catch (_) {
          return Future.delayed(const Duration(seconds: 1), () => true);
        }

        connect();
        return false;
      }, onError: (e) {
        return Future.delayed(const Duration(seconds: 1), () => true);
      });
    });
  }

  static void onMessage(dynamic message) {
    var op = 0;
    var data = {};
    try {
      message = json.decode(message as String) as Map<String, dynamic>;
      op = message['op'] as int;
      data = message['data'] as Map<String, dynamic>;
    } catch (e) {
      return;
    }
    log("ipc: $op");
    switch (op) {
      case OP.connected:
        send({'op': OP.hello});
        websocketConnected = true;
        callListeners(onChangeListeners);
        break;
      case OP.consoleAppend:
        consoleString += '\n${data['text']}';
        callListeners(onChangeListeners);
        break;
      case OP.consoleClear:
        consoleString = '';
        callListeners(onChangeListeners);
        break;
      case OP.consoleSet:
        consoleString = data['text'];
        callListeners(onChangeListeners);
        break;
      case OP.configUpdate:
        callListeners(onConfigChangeListeners);
        break;
      case OP.restart:
        // Sleep for 1 second to allow the selfbot to exit
        Future.delayed(const Duration(seconds: 1), () async {
          await Launching.launch(force: true);
        });
        break;
      case OP.error:
        FlutterPlatformAlert.showAlert(
          windowTitle: "LightningBot - Error",
          text: "An error has occurred!\n\nError data: ${data['text']}",
          iconStyle: IconStyle.error,
        );
        break;
    }
  }

  static void send(dynamic value) {
    if (channel != null) {
      channel!.sink.add(json.encode(value));
    }
  }
}
