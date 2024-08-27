
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

class SimpleRelaysService {

  String? name;

  OnRelayMsg? onRelayMsg;

  List<String> relays;

  Map<String, WebSocket> relaySockMap = {};

  bool _working = true;

  SimpleRelaysService({
    required this.relays,
    this.name = "SimpleRelaysService",
    this.onRelayMsg,
  });

  void sendEvent(Map event) {
    doSend(["EVENT", event]);
  }

  void doSend(List msg) {
    var msgStr = json.encode(msg);
    log(msgStr);
    for (var entry in relaySockMap.entries) {
      entry.value.add(msgStr);
    }
  }

  void connect() {
    for (var relay in relays) {
      _doConnect(relay);
    }
  }

  Future<void> _doConnect(String relay) async {
    try {
      log("$name connect to $relay");
      var socket = await WebSocket.connect(relay);
      socket.listen((value) {
        onEvent(socket, value);
      }, onDone: () {
        log("$name relay $relay connection done.");
        doReConnect(relay);
      });
      relaySockMap[relay] = socket;
      _reConnectNum = 0;
    } catch (e) {
      doReConnect(relay);
    }
  }

  int _reConnectNum = 0;

  Future<void> doReConnect(String relay) async {
    if (!_working) {
      return;
    }

    _reConnectNum++;
    relaySockMap.remove(relay);
    // 这里需要等待一会再请求
    await Future.delayed(Duration(seconds: 3 * _reConnectNum));
    _doConnect(relay);
  }

  void onEvent(WebSocket socket, msgText) {
    log(msgText);
    if (msgText is String) {
      if (onRelayMsg != null) {
        var msgJson = json.decode(msgText);
        onRelayMsg!(socket, msgJson);
      }
    }
  }

  void close() {
    _working = false;
    for (var entry in relaySockMap.entries) {
      var ws = entry.value;
      try {
        ws.close();
      } catch (e) {
        log("close error $e");
      }
    }
  }

}

typedef OnRelayMsg = Function(WebSocket socket, List);