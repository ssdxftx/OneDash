import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/network/panel_password_encrypter.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/pkcs1.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

const _publicPem = """
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmiRbaof8wPbUke7ApHid
5LZ2P6E7EYw578Wr0jqITOTOfuP7QB5TQ82oKlFrbcVxfYQ4JeK8R+aGIOoX+T3m
vm5Nhg/5+EaBkCnViZ6Aqy8z8sO8uhBoSWTqYsOFEATK/49LGVfsdrneSxVvS5WI
KRy47QtsE6bu2q9npChoQ5qQ3h6/2HT6oHHwz1RhGaDN9Ab2y3EDcqFCJuDoEQzg
GM+ediS/V0WnT1Wyu2zSfxoA9Zme2rUVxJNvrj3PO8AVxwGKFrXAbrRU/8BimiH9
bKt50FpNg3v8dv4V4grXBZFAfHfKyEgvrJRYAc1g8hJ+YQKA1eGFojB5Hje2g126
qQIDAQAB
-----END PUBLIC KEY-----
""";

const _privatePem = """
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAmiRbaof8wPbUke7ApHid5LZ2P6E7EYw578Wr0jqITOTOfuP7
QB5TQ82oKlFrbcVxfYQ4JeK8R+aGIOoX+T3mvm5Nhg/5+EaBkCnViZ6Aqy8z8sO8
uhBoSWTqYsOFEATK/49LGVfsdrneSxVvS5WIKRy47QtsE6bu2q9npChoQ5qQ3h6/
2HT6oHHwz1RhGaDN9Ab2y3EDcqFCJuDoEQzgGM+ediS/V0WnT1Wyu2zSfxoA9Zme
2rUVxJNvrj3PO8AVxwGKFrXAbrRU/8BimiH9bKt50FpNg3v8dv4V4grXBZFAfHfK
yEgvrJRYAc1g8hJ+YQKA1eGFojB5Hje2g126qQIDAQABAoIBAAZhq3Q3YZA2l9nb
1ddpU/YgVLhxKyIgmVRzLVgkiriOP3tS4nfG2aEkvknUOZufkUGGTBHLd4qNgW+S
6X+s36TyKZz7g9iSyLHofXn3WTHdICw0jNdyLvMc7bQ9joB5hlL6wnvv3y8SJmEa
59LsA6laElDkCGsu3dQpb2PFNX3Y86KtkhFXxi6MoSfONGod4O/zrl58EzxKleQn
mtDzwFWZiJvVA5qIK8dGkglTZZG1SrISsUDYbKZAfeEl760+MEaaHMo5ySWWWyaw
kWa5SBSO5M+3o7vVAeoVqXUl38mJZHz0hXlmnV7Zoo5/U9MS6hjojkYcMaDv4An3
0WmcXqECgYEAzAoPbnUq/QjgWD8Q+9WzNSHUy4taV5dz0Fm4uTI038DkkpAxhT8I
gBxBAlMCgXTjl9TCbiFDUMYthf7UieNITv0dYsZWTgjHCYTjc6VtEvgvlJiReeIe
srrF8a02+CRU7VilnwGyVAdw5GSpUJtQWTYlN9Br6rt8CiMvJK50tXECgYEAwWVX
l3/YaYwTW4YoP6jPSAZWds98JkRBT9v4d6hTXOSb77krKPcqj2R8/ThTZiQmGMzs
3EamEIF2h6oA3RHnyz4wuvFOZ6FkUhqUdnDtW1Cb8KvRduil5F5/R1jEl3zOBnJA
AM5KTcRSPD2Mw5HGxp68z59BgBfKfZKfhSvyXLkCgYEAiPS/wu7Wuh25KMK8Ta31
qlZZFX8mVuEMFfADdBvlLcO2KUKsWroipItSf5LkfazOD9353B5rps4/RE/2rc9n
e82eaeyjhaGSqCsQ2VFS04bPuThnfZ5v6JxBvaT83rbUYrQ8B20GHC0ac9O1aqu1
1QvpE3vM1DSgX9WaEU8ge6ECgYAr84oahhV6tzjW/gA7p3OkHLydt72xPKXTLlyj
ZP+9Br9hlaV3Y+SqPd4h9iEN/30g+cGCthObgLCdWEdl9mHFUNbmRVzaNFWGS0Ae
Qr/Olt05rvKloW3CHq+yWTwkaVqxIFnnVPqR/eHqitpov8J69SxXywupvr5oF2Bl
dX1ZEQKBgHY4y3awQwMg6G8d/6H98owbPA3hwxCiINXAtzZPKzc34x+upe1Lf1F5
nMCFX4TE0T0tjEFlzZs59+C9cyoPBqkS54hj/AW+AyeuibY8GPjSkuZmMLZorVmk
ZsR0vmjmhAC9qS2QkGSoTzFwoMhOIRxIEWbISDTrz8472qglrpRp
-----END RSA PRIVATE KEY-----
""";

RSAPrivateKey _parsePrivateKey() {
  final body = _privatePem
      .replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
      .replaceAll('-----END RSA PRIVATE KEY-----', '')
      .replaceAll(RegExp(r'\s'), '');
  final seq = ASN1Parser(base64Decode(body)).nextObject() as ASN1Sequence;
  BigInt at(int index) => (seq.elements![index] as ASN1Integer).integer!;
  return RSAPrivateKey(at(1), at(3), at(4), at(5));
}

void main() {
  test('encrypts a password that the 1Panel private key can decrypt', () {
    final encrypted = PanelPasswordEncrypter.encrypt('secret', _publicPem);
    final parts = encrypted.split(':');
    expect(parts.length, 3);

    final rsa = PKCS1Encoding(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(_parsePrivateKey()));
    final aesKey = utf8.decode(
      rsa.process(Uint8List.fromList(base64Decode(parts[0]))),
    );
    expect(aesKey.length, 32);

    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESEngine()),
    );
    cipher.init(
      false,
      PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ParametersWithIV<KeyParameter>(
          KeyParameter(Uint8List.fromList(utf8.encode(aesKey))),
          Uint8List.fromList(base64Decode(parts[1])),
        ),
        null,
      ),
    );
    final plain = cipher.process(Uint8List.fromList(base64Decode(parts[2])));
    expect(utf8.decode(plain), 'secret');
  });
}
