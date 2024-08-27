import 'package:json_cache/json_cache.dart';

import '../../../model/socket_control.dart';
import '../relays/relays.dart';

class FeedDetail{
  late JsonCache _jsonCache;
  late Relays _relays;

  late Map<String, SocketControl> _connectedRelaysRead;


  FeedDetail(){

  }
}
