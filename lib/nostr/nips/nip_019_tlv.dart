import 'dart:convert';

import 'package:bech32/bech32.dart';
import 'package:hex/hex.dart';

import 'nip_019_hrps.dart';

class Nip19Tlv {
  static bool isNprofile(String text) {
    return Nip019.isKey(Nip019Hrps.NPROFILE, text);
  }

  static bool isNevent(String text) {
    return Nip019.isKey(Nip019Hrps.NEVENT, text);
  }

  static bool isNrelay(String text) {
    return Nip019.isKey(Nip019Hrps.NRELAY, text);
  }

  static bool isNaddr(String text) {
    return Nip019.isKey(Nip019Hrps.NADDR, text);
  }

  static List<int> _decodePreHandle(String text) {
    try {
      text = text.replaceAll(Nip019Hrps.NOSTR_PRE, "");

      var decoder = Bech32Decoder();
      var bech32Result = decoder.convert(text, 1000);
      var buf = Nip019.convertBits(bech32Result.data, 5, 8, false);

      return buf;
    } catch (e) {
      return [];
    }
  }

  static Nprofile? decodeNprofile(String text) {
    List<int> buf = _decodePreHandle(text);

    String? pubkey;
    List<String> relays = [];

    int startIndex = 0;
    while (true) {
      var tlvData = TLVUtil.readTLVEntry(buf, startIndex: startIndex);
      if (tlvData == null) {
        break;
      }
      startIndex += tlvData.length + 2;

      if (tlvData.typ == TLVType.Default) {
        pubkey = HEX.encode(tlvData.data);
      } else if (tlvData.typ == TLVType.Relay) {
        var relay = utf8.decode(tlvData.data);
        relays.add(relay);
      }
    }

    if (pubkey != null) {
      return Nprofile(pubkey: pubkey, relays: relays);
    }

    return null;
  }

  static Nevent? decodeNevent(String text) {
    List<int> buf = _decodePreHandle(text);

    String? id;
    List<String> relays = [];
    String? author;

    int startIndex = 0;
    while (true) {
      var tlvData = TLVUtil.readTLVEntry(buf, startIndex: startIndex);
      if (tlvData == null) {
        break;
      }
      startIndex += tlvData.length + 2;

      if (tlvData.typ == TLVType.Default) {
        id = HEX.encode(tlvData.data);
      } else if (tlvData.typ == TLVType.Relay) {
        var relay = utf8.decode(tlvData.data);
        relays.add(relay);
      } else if (tlvData.typ == TLVType.Author) {
        author = HEX.encode(tlvData.data);
      }
    }

    if (id != null) {
      return Nevent(id: id, relays: relays, author: author);
    }

    return null;
  }

  static Nrelay? decodeNrelay(String text) {
    List<int> buf = _decodePreHandle(text);

    String? addr;

    int startIndex = 0;
    while (true) {
      var tlvData = TLVUtil.readTLVEntry(buf, startIndex: startIndex);
      if (tlvData == null) {
        break;
      }
      startIndex += tlvData.length + 2;

      if (tlvData.typ == TLVType.Default) {
        var relay = utf8.decode(tlvData.data);
        addr = relay;
      }
    }

    if (addr != null) {
      return Nrelay(addr);
    }

    return null;
  }

  static Naddr? decodeNaddr(String text) {
    List<int> buf = _decodePreHandle(text);

    String? id;
    String? author;
    int? kind;
    List<String> relays = [];

    int startIndex = 0;
    while (true) {
      var tlvData = TLVUtil.readTLVEntry(buf, startIndex: startIndex);
      if (tlvData == null) {
        break;
      }
      startIndex += tlvData.length + 2;

      if (tlvData.typ == TLVType.Default) {
        id = HEX.encode(tlvData.data);
      } else if (tlvData.typ == TLVType.Relay) {
        var relay = utf8.decode(tlvData.data);
        relays.add(relay);
      } else if (tlvData.typ == TLVType.Kind) {
        kind = tlvData.data[0];
      } else if (tlvData.typ == TLVType.Author) {
        author = HEX.encode(tlvData.data);
      }
    }

    if (id != null && author != null && kind != null) {
      return Naddr(id: id, author: author, kind: kind, relays: relays);
    }

    return null;
  }

  static String _handleEncodeResult(String hrp, List<int> buf) {
    var encoder = Bech32Encoder();
    Bech32 input = Bech32(hrp, buf);
    return Nip019Hrps.NPROFILE + encoder.convert(input, 2000);
  }

  static String encodeNprofile(Nprofile o) {
    List<int> buf = [];
    TLVUtil.writeTLVEntry(buf, TLVType.Default, HEX.decode(o.pubkey));
    if (o.relays != null) {
      for (var relay in o.relays!) {
        TLVUtil.writeTLVEntry(buf, TLVType.Relay, utf8.encode(relay));
      }
    }

    buf = Nip019.convertBits(buf, 8, 5, true);

    return _handleEncodeResult(Nip019Hrps.NPROFILE, buf);
  }

  static String encodeNevent(Nevent o) {
    List<int> buf = [];
    TLVUtil.writeTLVEntry(buf, TLVType.Default, HEX.decode(o.id));
    if (o.relays != null) {
      for (var relay in o.relays!) {
        TLVUtil.writeTLVEntry(buf, TLVType.Relay, utf8.encode(relay));
      }
    }
    if (o.author != null) {
      TLVUtil.writeTLVEntry(buf, TLVType.Author, utf8.encode(o.author!));
    }

    buf = Nip019.convertBits(buf, 8, 5, true);

    return _handleEncodeResult(Nip019Hrps.NEVENT, buf);
  }

  static String encodeNrelay(Nrelay o) {
    List<int> buf = [];
    TLVUtil.writeTLVEntry(buf, TLVType.Default, utf8.encode(o.addr));

    buf = Nip019.convertBits(buf, 8, 5, true);

    return _handleEncodeResult(Nip019Hrps.NRELAY, buf);
  }

  static String encodeNaddr(Naddr o) {
    List<int> buf = [];
    TLVUtil.writeTLVEntry(buf, TLVType.Default, HEX.decode(o.id));
    TLVUtil.writeTLVEntry(buf, TLVType.Author, HEX.decode(o.author));
    TLVUtil.writeTLVEntry(buf, TLVType.Kind, [o.kind]);
    if (o.relays != null) {
      for (var relay in o.relays!) {
        TLVUtil.writeTLVEntry(buf, TLVType.Relay, utf8.encode(relay));
      }
    }

    buf = Nip019.convertBits(buf, 8, 5, true);

    return _handleEncodeResult(Nip019Hrps.NRELAY, buf);
  }
}

class Nprofile {
  String pubkey;

  List<String>? relays;

  Nprofile({required this.pubkey, this.relays});
}

class Nevent {
  String id;

  List<String>? relays;

  String? author;

  Nevent({required this.id, this.relays, this.author});
}

class Nrelay {
  String addr;

  Nrelay(this.addr);
}

class Naddr {
  String id;

  String author;

  int kind;

  List<String>? relays;

  Naddr({
    required this.id,
    required this.author,
    required this.kind,
    this.relays,
  });
}

class TLVUtil {
  static TLVData? readTLVEntry(
      List<int> data, {
        int startIndex = 0,
      }) {
    var dataLength = data.length;
    if (dataLength < startIndex + 2) {
      return null;
    }

    var typ = data[startIndex];
    var length = data[startIndex + 1];

    if (dataLength >= startIndex + 2 + length) {
      var d = data.sublist(startIndex + 2, startIndex + 2 + length);

      return TLVData(typ, length, d);
    }

    return null;
  }

  static writeTLVEntry(List<int> buf, int typ, List<int> data) {
    var length = data.length;
    buf.add(typ);
    buf.add(length);
    buf.addAll(data);
  }
}

class TLVData {
  int typ;

  int length;

  List<int> data;

  TLVData(this.typ, this.length, this.data);
}

class TLVType {
  static const int Default = 0;
  static const int Relay = 1;
  static const int Author = 2;
  static const int Kind = 3;
}