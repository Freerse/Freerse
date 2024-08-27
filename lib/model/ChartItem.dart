import 'dart:convert';

import 'package:decimal/decimal.dart';

class ChartItem implements Comparable{
  String userId;
  String name;
  String? message;
  int? latestTime;
  bool topFrend = false;

  ChartItem({
    required this.userId,
    this.name = '',
    this.message = '',
    this.latestTime = 0,
    this.topFrend = false
  });

  @override
  int compareTo(other) {
    if(other.topFrend  == topFrend){
      return (other.latestTime ?? 0).compareTo(latestTime ?? 0);
    }
    if(other.topFrend && !topFrend){
     return 1;
    }
    return -1;
  }

  @override
  String toString() {
    return 'ChartItem{userId: $userId, name: $name, message: $message, latestTime: $latestTime}';
  }
}
