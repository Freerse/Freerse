import 'dart:convert';

import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:freerse/nostr/request.dart';

typedef OnEvent = void Function(String e);


class Relay{
  late final int id;
  late final String url;
  late final WebSocketChannel webSocket;
  RxBool isConnect = false.obs;
  Map requestIds = <String,int>{};


  Relay(this.id,this.url);

  register(OnEvent o) {
    webSocket = WebSocketChannel.connect(
      Uri.parse(url)
    );

    isConnect = RxBool(true);

    webSocket.stream.listen(
          (data) {
            o(data);
      },
      onError: (error) => {
        print('错误:'+url),
        print(error),
        isConnect = RxBool(false)
      },
    );
  }

  void send(Request rq) {
    if(webSocket != null){
      webSocket.sink.add(rq.serialize());
      requestIds[rq.subscriptionId] = 0;
    }else{
      isConnect = RxBool(false);
    }
  }

  void unsub(String id) {
    if(webSocket != null){
      webSocket.sink.add(jsonEncode(["CLOSE", id]));
      requestIds[id] = 1;
    }else{
      isConnect = RxBool(false);
    }
  }

  void close(){
    webSocket.sink.close();
    isConnect = RxBool(false);
  }

}
