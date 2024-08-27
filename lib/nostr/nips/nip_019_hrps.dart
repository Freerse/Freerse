
import 'package:bech32/bech32.dart';
import 'package:hex/hex.dart';

class Nip019Hrps {

  static const String NOSTR_PRE = "nostr:";

  static const String PUBLIC_KEY = "npub";
  static const String PRIVATE_KEY = "nsec";
  static const String NOTE_ID = "note";

  static const String NPROFILE = "nprofile";
  static const String NEVENT = "nevent";
  static const String NRELAY = "nrelay";
  static const String NADDR = "naddr";
}

class Nip019 {

  static bool isKey(String hrp, String str) {
    if (str.indexOf(hrp) == 0) {
      return true;
    } else {
      return false;
    }
  }

  static bool isPubkey(String str) {
    return isKey(Nip019Hrps.PUBLIC_KEY, str);
  }

  static String encodePubKey(String pubkey) {
    return _encodeKey(Nip019Hrps.PUBLIC_KEY, pubkey);
  }

  static String encodeSimplePubKey(String pubKey) {
    var code = encodePubKey(pubKey);
    var length = code.length;
    return code.substring(0, 6) + ":" + code.substring(length - 6);
  }

  static String decode(String npub) {
    try {
      var decoder = Bech32Decoder();
      var bech32Result = decoder.convert(npub);
      var data = convertBits(bech32Result.data, 5, 8, false);
      return HEX.encode(data);
    } catch (e) {
      print("Nip19 decode error ${e.toString()}");
      return "";
    }
  }

  static String _encodeKey(String hrp, String key) {
    var data = HEX.decode(key);
    data = convertBits(data, 8, 5, true);

    var encoder = Bech32Encoder();
    Bech32 input = Bech32(hrp, data);
    return encoder.convert(input);
  }

  static bool isPrivateKey(String str) {
    return isKey(Nip019Hrps.PRIVATE_KEY, str);
  }

  static String encodePrivateKey(String pubkey) {
    return _encodeKey(Nip019Hrps.PRIVATE_KEY, pubkey);
  }

  static bool isNoteId(String str) {
    return isKey(Nip019Hrps.NOTE_ID, str);
  }

  static String encodeNoteId(String id) {
    return _encodeKey(Nip019Hrps.NOTE_ID, id);
  }

  static List<int> convertBits(List<int> data, int from, int to, bool pad) {
    var acc = 0;
    var bits = 0;
    var result = <int>[];
    var maxv = (1 << to) - 1;

    data.forEach((v) {
      if (v < 0 || (v >> from) != 0) {
        throw Exception();
      }
      acc = (acc << from) | v;
      bits += from;
      while (bits >= to) {
        bits -= to;
        result.add((acc >> bits) & maxv);
      }
    });

    if (pad) {
      if (bits > 0) {
        result.add((acc << (to - bits)) & maxv);
      }
    } else if (bits >= from) {
      throw InvalidPadding('illegal zero padding');
    } else if (((acc << (to - bits)) & maxv) != 0) {
      throw InvalidPadding('non zero');
    }

    return result;
  }
}