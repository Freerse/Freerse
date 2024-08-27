import 'dart:convert';

import 'package:decimal/decimal.dart';

class UserItem {
  String userId;
  String avater;
  String name;
  String about;

  UserItem({
    required this.userId,
    this.avater = '',
    this.name = '',
    this.about = ''
  });

  // @override
  // int compareTo(other) {
  //   return (amount?.toDouble() ?? 0).compareTo(other.amount?.toDouble() ?? 0);
  // }
}
