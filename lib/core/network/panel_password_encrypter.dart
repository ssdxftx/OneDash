import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/pkcs1.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

/// 1Panel 登录密码加密。
///
/// 1Panel 前端从 `panel_public_key` Cookie 获取 RSA 公钥，使用随机 AES-256
/// 密钥加密密码，再用 RSA PKCS#1 v1.5 加密 AES 密钥，最终提交
/// `base64(rsaKey):base64(iv):base64(ciphertext)`。
class PanelPasswordEncrypter {
  const PanelPasswordEncrypter._();

  static String encrypt(String password, String publicKeyPem) {
    final publicKey = _parsePublicKey(publicKeyPem);
    final random = Random.secure();
    final aesKey = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
    final iv = Uint8List.fromList(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );

    final keyCipher = _rsaEncrypt(
      Uint8List.fromList(utf8.encode(aesKey)),
      publicKey,
    );
    final passwordCipher = _aesEncrypt(password, aesKey, iv);

    return '${base64Encode(keyCipher)}:'
        '${base64Encode(iv)}:'
        '${base64Encode(passwordCipher)}';
  }

  static RSAPublicKey _parsePublicKey(String pem) {
    var body = pem.trim();
    if (body.startsWith('"') && body.endsWith('"')) {
      body = body.substring(1, body.length - 1);
    }
    body = body
        .replaceAll('-----BEGIN PUBLIC KEY-----', '')
        .replaceAll('-----END PUBLIC KEY-----', '')
        .replaceAll('-----BEGIN RSA PUBLIC KEY-----', '')
        .replaceAll('-----END RSA PUBLIC KEY-----', '')
        .replaceAll(RegExp(r'\s'), '');
    final der = base64Decode(body);
    final root = ASN1Parser(der).nextObject() as ASN1Sequence;
    if (root.elements == null || root.elements!.isEmpty) {
      throw const FormatException('invalid RSA public key');
    }

    ASN1Sequence keySequence;
    if (root.elements!.length == 2 && root.elements![1] is ASN1BitString) {
      final bitString = root.elements![1] as ASN1BitString;
      final bytes = Uint8List.fromList(bitString.stringValues ?? const []);
      keySequence = ASN1Parser(bytes).nextObject() as ASN1Sequence;
    } else {
      keySequence = root;
    }
    final modulus = (keySequence.elements![0] as ASN1Integer).integer!;
    final exponent = (keySequence.elements![1] as ASN1Integer).integer!;
    return RSAPublicKey(modulus, exponent);
  }

  static Uint8List _rsaEncrypt(Uint8List data, RSAPublicKey publicKey) {
    final cipher = PKCS1Encoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    return cipher.process(data);
  }

  static Uint8List _aesEncrypt(String password, String aesKey, Uint8List iv) {
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESEngine()),
    );
    cipher.init(
      true,
      PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ParametersWithIV<KeyParameter>(
          KeyParameter(Uint8List.fromList(utf8.encode(aesKey))),
          iv,
        ),
        null,
      ),
    );
    return cipher.process(Uint8List.fromList(utf8.encode(password)));
  }
}
