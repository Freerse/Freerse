
import 'dart:developer';

import 'package:freerse/utils/string_utils.dart';

import '../../../../helpers/bip340.dart';

class WalletConnectionInfo {

  String relay;

  String secret;

  String pubkey;

  String? lud16;

  WalletConnectionInfo({
    required this.relay,
    required this.secret,
    required this.pubkey,
    this.lud16,
  });

  static WalletConnectionInfo? validAndParse(String? link) {
    if (StringUtils.isBlank(link)) {
      return null;
    }

    try {
      var uri = Uri.parse(link!);
      var pubkey = uri.host;
      var pars = uri.queryParameters;
      var relay = pars["relay"];
      var secret = pars["secret"];
      var lud16 = pars["lud16"];

      if (uri.scheme == "nostr+walletconnect" && StringUtils.isNotBlank(relay) && StringUtils.isNotBlank(secret)) {
        return WalletConnectionInfo(relay: relay!, secret: secret!, pubkey: pubkey, lud16: lud16);
      }
    } catch (e) {
      log("WalletConnectionInfo validAndParse error $e");
    }

    return null;
  }

  @override
  String toString() {
    // var pubkey = Bip340().getPublicKey(secret);
    var relayStr = Uri.encodeQueryComponent(relay);
    var text = "nostr+walletconnect:$pubkey?relay=$relayStr&secret=$secret";
    if (StringUtils.isNotBlank(lud16)) {
      text += "&lud16=${lud16!}";
    }
    return text;
  }

  String senderPubkey() {
    return Bip340().getPublicKey(secret);
  }

}