
import 'package:decimal/decimal.dart';

import '../../model/Tweet.dart';

class NotifyCounter {

  String feedId;

  NotifyCounter({
    required this.feedId,
  });

  List<NotifyCounterItem> items = [];

  Map<String, int> _map = {};

  Tweet? tweet;

  bool isEvent = false;

  Decimal amount = Decimal.fromInt(0);

  int lastCreatedAt() {
    if (items.isNotEmpty) {
      return items.first.createdAt;
    }

    return 0;
  }

  bool push(NotifyCounterItem item) {
    if (_map[item.id] == null) {
      _map[item.id] = 1;
      items.add(item);

      if (item.amount != null) {
        amount = amount + item.amount!;
      }

      return true;
    }

    return false;
  }

  bool pushAndSort(NotifyCounterItem item) {
    var result = push(item);
    if (result) {
      items.sort((item0, item1) {
        return item1.createdAt - item0.createdAt;
      });
    }
    return result;
  }

}

class NotifyCounterItem {

  String id;

  String pubkey;

  int createdAt;

  String feedId;

  Decimal? amount;

  NotifyCounterItem({
    required this.id,
    required this.pubkey,
    required this.createdAt,
    required this.feedId,
    this.amount
  });

}