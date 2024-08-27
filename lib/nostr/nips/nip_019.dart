const String ALPHABET = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';

final Map<String, int> ALPHABET_MAP = {
  for (var z = 0; z < ALPHABET.length; z++) ALPHABET[z]: z
};

int polymodStep(int pre) {
  int b = pre >> 25;
  return ((pre & 0x1ffffff) << 5) ^
  (-((b >> 0) & 1) & 0x3b6a57b2) ^
  (-((b >> 1) & 1) & 0x26508e6d) ^
  (-((b >> 2) & 1) & 0x1ea119fa) ^
  (-((b >> 3) & 1) & 0x3d4233dd) ^
  (-((b >> 4) & 1) & 0x2a1462b3);
}

dynamic prefixChk(String prefix) {
  int chk = 1;
  for (int i = 0; i < prefix.length; ++i) {
    int c = prefix.codeUnitAt(i);
    if (c < 33 || c > 126) return 'Invalid prefix ($prefix)';

    chk = polymodStep(chk) ^ (c >> 5);
  }
  chk = polymodStep(chk);

  for (int i = 0; i < prefix.length; ++i) {
    int v = prefix.codeUnitAt(i);
    chk = polymodStep(chk) ^ (v & 0x1f);
  }
  return chk;
}

dynamic convert(List<int> data, int inBits, int outBits, bool pad) {
  int value = 0;
  int bits = 0;
  int maxV = (1 << outBits) - 1;

  List<int> result = [];
  for (int i = 0; i < data.length; ++i) {
    value = (value << inBits) | data[i];
    bits += inBits;

    while (bits >= outBits) {
      bits -= outBits;
      result.add((value >> bits) & maxV);
    }
  }

  if (pad) {
    if (bits > 0) {
      result.add((value << (outBits - bits)) & maxV);
    }
  } else {
    if (bits >= inBits) return 'Excess padding';
    //if ((value << (outBits - bits)) & maxV) return 'Non-zero padding';
  }

  return result;
}

List<int> toWords(List<int> bytes) {
  return List<int>.from(convert(bytes, 8, 5, true));
}

dynamic fromWordsUnsafe(List<int> words) {
  var res = convert(words, 5, 8, false);
  if (res is List<int>) return res;
}

List<int> fromWords(List<int> words) {
  var res = convert(words, 5, 8, false);
  if (res is List<int>) return res;
  throw ArgumentError(res);
}

class Bech32 {
  final int encodingConst;

  Bech32(this.encodingConst);

  int unsignedShiftRight(int number, int shiftAmount) {
    return (number & 0xFFFFFFFF) >> shiftAmount;
  }

  List<int> hexStringToBytes(String hexString) {
    int len = hexString.length;
    List<int> bytes = List<int>.filled(len ~/ 2, 0, growable: false);
    for (int i = 0; i < len; i += 2) {
      bytes[i ~/ 2] = int.parse(hexString.substring(i, i + 2), radix: 16);
    }
    return bytes;
  }


  String encodeString(String prefix, String text, [int? limit]){
    List<int> words = toWords(hexStringToBytes(text));
    limit ??= 90;
    if (prefix.length + 7 + words.length > limit) {
      throw ArgumentError('Exceeds length limit');
    }

    prefix = prefix.toLowerCase();

    int chk = prefixChk(prefix);
    if (chk is String) throw ArgumentError(chk);

    String result = prefix + '1';
    for (int i = 0; i < words.length; ++i) {
      int x = words[i];
      if (x >> 5 != 0) throw ArgumentError('Non 5-bit word');

      chk = polymodStep(chk) ^ x;
      result += ALPHABET[x];
    }

    for (int i = 0; i < 6; ++i) {
      chk = polymodStep(chk);
    }
    chk ^= encodingConst;

    for (int i = 0; i < 6; ++i) {
      int v = (chk >> ((5 - i) * 5)) & 0x1f;
      result += ALPHABET[v];
    }

    return result;
  }

  String encode(String prefix, List<int> words, [int? limit]) {
    limit ??= 90;
    if (prefix.length + 7 + words.length > limit) {
      throw ArgumentError('Exceeds length limit');
    }

    prefix = prefix.toLowerCase();

    int chk = prefixChk(prefix);
    if (chk is String) throw ArgumentError(chk);

    String result = prefix + '1';
    for (int i = 0; i < words.length; ++i) {
      int x = words[i];
      if (x >> 5 != 0) throw ArgumentError('Non 5-bit word');

      chk = polymodStep(chk) ^ x;
      result += ALPHABET[x];
    }

    for (int i = 0; i < 6; ++i) {
      chk = polymodStep(chk);
    }
    chk ^= encodingConst;

    for (int i = 0; i < 6; ++i) {
      int v = (chk >> ((5 - i) * 5)) & 0x1f;
      result += ALPHABET[v];
    }

    return result;
  }

  dynamic _decode(String str, [int? limit]) {
    limit ??= 90;
    if (str.length < 8) return '$str too short';
    if (str.length > limit) return 'Exceeds length limit';

    String lowered = str.toLowerCase();
    String uppered = str.toUpperCase();
    if (str != lowered && str != uppered) return 'Mixed-case string $str';
    str = lowered;

    int split = str.lastIndexOf('1');
    if (split == -1) return 'No separator character for $str';
    if (split == 0) return 'Missing prefix for $str';

    String prefix = str.substring(0, split);
    String wordChars = str.substring(split + 1);
    if (wordChars.length < 6) return 'Data too short';

    int chk = prefixChk(prefix);
    if (chk is String) return chk;

    List<int> words = [];
    for (int i = 0; i < wordChars.length; ++i) {
      String c = wordChars[i];
      int? v = ALPHABET_MAP[c];
      if (v == null) return 'Unknown character $c';
      chk = polymodStep(chk) ^ v;

      if (i + 6 >= wordChars.length) continue;
      words.add(v);
    }

    if (chk != encodingConst) return 'Invalid checksum for $str';
    return {'prefix': prefix, 'words': words};
  }

  Map<String, dynamic>? decodeUnsafe(String str, [int? limit]) {
    var res = _decode(str, limit);
    if (res is Map<String, dynamic>) return res;
  }

  Map<String, dynamic> decode(String str, [int? limit]) {
    var res = _decode(str, limit);
    if (res is Map<String, dynamic>) return res;
    throw ArgumentError(res);
  }
}

final Bech32 bech32 = Bech32(1);
final Bech32 bech32m = Bech32(0x2bc830a3);


