import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../services/nostr/relays/relay_tracker.dart';

/// websocket cotrol
class SocketControl {
  // late WebSocket socket;
  WebSocket? _socket;
  String id;
  String connectionUrl;
  Map<String, dynamic> requestInFlight = {};
  Map<String, Completer> completers = {};
  Map<String, StreamController> streamControllers = {};
  Map<String, Map> additionalData = {};
  bool socketIsRdy = false;
  bool socketIsFailing = false;
  int socketFailingAttempts = 0;

  StreamController<Map<String, dynamic>>? receiveEventStreamController;
  RelayTracker? relayTracker;

  SocketControl(this.id, this.connectionUrl);

  SocketControl.connect(this.id, this.connectionUrl,
      this.receiveEventStreamController, this.relayTracker) {
    reconnect();
  }

  Future<void> reconnect() async {
    close();

    try {
      log("begin to connect relay $connectionUrl");
      _socket = await WebSocket.connect(connectionUrl);
      log(" relay $connectionUrl connected!");
      socketIsRdy = true;
      _socket!.listen((event) {
        // print("receive event ${id}");
        // print(event);
        var eventJson = json.decode(event);
        if (receiveEventStreamController != null) {
          receiveEventStreamController!.add({
            "event": eventJson,
            "socketControl": this,
          });
        }
        if (relayTracker != null) {
          relayTracker!.analyzeNostrEvent(eventJson, this);
        }
      });
    } catch (e) {
      await Future.delayed(Duration(seconds: 30));
      reconnect();
    }
  }

  void send(dynamic data) {
    if (socketIsRdy && _socket != null) {
      // print("sendData");
      // print(data);
      _socket!.add(data);
    }
  }

  void _onError() {
    print("relay onError $socketIsRdy");
    if (!socketIsRdy) {
      return;
    }
    socketIsRdy = false;
    reconnect();
  }

  void close() {
    socketIsRdy = false;
    try {
      if (_socket != null) {
        _socket!.close();
      }
    } catch (e) {}
  }

  // void send(dynamic data) {
  //   if (socketIsRdy) {
  //     socket.add(data);
  //   }
  // }

}
