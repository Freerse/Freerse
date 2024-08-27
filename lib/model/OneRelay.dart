import 'dart:convert';

import 'package:decimal/decimal.dart';

class OneRelay {
  String url;
  bool write;
  bool read;
  int status;

  OneRelay({
    required this.url,
    this.write = true,
    this.read = true,
    this.status = 0,
  });
}
