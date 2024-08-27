import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/paddings/iso7816d4.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:convert/convert.dart';

class Nip04{
  Uint8List? getSharedSecret(String privateKey, String publicKey) {
    ECDomainParameters params = ECCurve_secp256k1();
    BigInt privateKeyInt = BigInt.parse(privateKey, radix: 16);
    ECPoint? publicKeyPoint = params.curve.decodePoint(hex.decode(publicKey));
    ECPoint? sharedSecretPoint = publicKeyPoint! * privateKeyInt;
    return sharedSecretPoint?.getEncoded(false).sublist(1);
  }

  Uint8List generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(length, (index) => random.nextInt(256)));
  }

  String encrypt(String privateKey, String publicKey, String text) {
    Uint8List? sharedSecret = getSharedSecret(privateKey,'02'+publicKey);
    Uint8List? normalizedKey = sharedSecret?.sublist(0, 32);

    Uint8List iv = generateRandomBytes(16);
    Uint8List plaintext = Uint8List.fromList(utf8.encode(text));

    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    );

    cipher.init(
      true,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(normalizedKey!), iv),
        null,
      ),
    );

    Uint8List ciphertext = cipher.process(plaintext);
    String ctBase64 = base64Encode(ciphertext);
    String ivBase64 = base64Encode(iv);

    return '$ctBase64?iv=$ivBase64';
  }

  String decrypt(String privateKey, String publicKey, String data) {
    List<String> parts = data.split('?iv=');
    String ctBase64 = parts[0];
    String ivBase64 = parts[1];

    Uint8List? sharedSecret = getSharedSecret(privateKey, '02'+publicKey);
    Uint8List? normalizedKey = sharedSecret?.sublist(0, 32);

    Uint8List ciphertext = base64Decode(ctBase64);
    Uint8List iv = base64Decode(ivBase64);

    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    );

    cipher.init(
      false,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(normalizedKey!), iv),
        null,
      ),
    );

    Uint8List plaintext = cipher.process(ciphertext);
    String text = utf8.decode(plaintext);

    return text;
  }
}
