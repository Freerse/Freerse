import 'package:bip340/bip340.dart' as bip340;

import 'helpers.dart';

class Bip340 {
  String sign(String message, String privateKey) {
    String aux = Helpers().getSecureRandomHex(32);
    final sig = bip340.sign(privateKey, message, aux);
    return sig;
  }

  bool verify(String message, String signature, String? publicKey) {
    return bip340.verify(publicKey, message, signature);
  }

  String getPublicKey(String privateKey) {
    return bip340.getPublicKey(privateKey);
  }

  KeyPair generatePrivateKey() {
    String privKey = Helpers().getSecureRandomHex(32);
    String pubKey = getPublicKey(privKey);

    String privKeyHr = Helpers().encodeBech32(privKey, 'nsec');
    String pubKeyHr = Helpers().encodeBech32(pubKey, 'npub');

    var ids = Helpers().decodeBech32('');
    print('ids');
    print(ids);

    return KeyPair(privKey, pubKey, privKeyHr, pubKeyHr);
  }


  KeyPair importPrivateKey(privKeyHr) {
    var privkey = Helpers().decodeBech32(privKeyHr)[0];
    var pubkey = Bip340().getPublicKey(privkey);
    var publicKeyHr = Helpers().encodeBech32(pubkey, 'npub');
    return KeyPair(privkey, pubkey, privKeyHr, publicKeyHr);
  }
}

class KeyPair {
  /// [privateKey] is the private key in hex
  String privateKey;

  /// [publicKey] is the public key in hex
  String publicKey;

  /// [privateKeyHr] is the private key in bech32 with hrp 'nsec'
  String privateKeyHr;

  /// [publicKeyHr] is the public key in bech32 with hrp 'npub'
  String publicKeyHr;

  KeyPair(this.privateKey, this.publicKey, this.privateKeyHr, this.publicKeyHr);

  // to json
  Map<String, dynamic> toJson() => {
        'privateKey': privateKey,
        'publicKey': publicKey,
        'privateKeyHr': privateKeyHr,
        'publicKeyHr': publicKeyHr,
      };

  // from json
  factory KeyPair.fromJson(Map<String, dynamic> json) => KeyPair(
        json['privateKey'],
        json['publicKey'],
        json['privateKeyHr'],
        json['publicKeyHr'],
      );
}
