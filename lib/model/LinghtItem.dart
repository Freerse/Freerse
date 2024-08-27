import 'dart:convert';

import 'package:decimal/decimal.dart';

class LinghtItem implements Comparable{
  String pubkey;
  int createTime;
  Decimal? amount;
  String? zapEventId;

  LinghtItem({
    required this.pubkey,
    this.createTime = 0,
    this.amount,
    this.zapEventId,
  });

  @override
  int compareTo(other) {
    return (amount?.toDouble() ?? 0).compareTo(other.amount?.toDouble() ?? 0);
  }
}
