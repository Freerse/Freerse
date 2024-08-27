
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:freerse/services/nostr/nips/nip47/wallet_connection_info.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:freerse/services/nostr/relays/simple_relays_service.dart';
import 'package:get/get.dart';

class NostrWalletConnectService {

  NostrService nostrService = Get.find();

  SimpleRelaysService? simpleRelaysService;

  WalletConnectionInfo? info;

  void init() {

  }

}