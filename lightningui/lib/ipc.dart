import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:path_provider/path_provider.dart';

abstract class OP {
  static const int connected = 98;
  static const int hello = 99;
  static const int exit = 100;
  static const int restart = 101;
  static const int notification = 102;
  static const int invalidToken = 103;
  static const int error = 104;
  static const int configEdit = 105;
  static const int newToken = 106;
  static const int consoleAppend = 107;
  static const int consoleClear = 108;
  static const int consoleSet = 109;
}

class IPC {
  static WebSocketChannel? channel;

  static bool websocketConnected = false;

  static String consoleString =
      '<image Source="assets/Logo.150.png" Width="650" Height="150" Centered />\n<text Color="#3CA5FF" Centered>Logged in to Lightning#0420</text>';

  // loaded in the main function
  // TODO: deprecate
  static String documentsDirectory = "";
  static String applicationDirectory = "";

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
          callListeners(onChangeListeners);
          tryConnect();
        },
        onError: (Object error) {
          channel = null;
          websocketConnected = false;
          callListeners(onChangeListeners);
        },
      );
    } catch (e) {
      return;
    }
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
        getApplicationDocumentsDirectory().then((value) {
          send({
            'op': OP.hello,
            'data': {'mainFolder': value.path},
          });
        });
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
      case OP.configEdit:
        callListeners(onConfigChangeListeners);
        break;
    }
  }

  static void send(dynamic value) {
    if (channel != null) {
      channel!.sink.add(json.encode(value));
    }
  }
}
