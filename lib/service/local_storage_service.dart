import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:planet/model/planet_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static Future<void> saveMnemonics(List<PlanetDto> mnemonics) async {
    const storage = FlutterSecureStorage();
    final jsonList = mnemonics.map((m) => m.toJson()).toList();
    final encodedJson = jsonEncode(jsonList);

    await storage.write(key: 'planets', value: encodedJson);
  }

  static Future<List<PlanetDto>> getLocalPlanets() async {
    const storage = FlutterSecureStorage();
    final encodedJson = await storage.read(key: 'planets');

    if (encodedJson == null) return [];

    final jsonList = jsonDecode(encodedJson) as List;
    return jsonList.map((json) => PlanetDto.fromJson(json)).toList();
  }

  static Future<void> clearMnemonics() async {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
  }
}

// todo :
class MnemonicCrypto {
  static const String _keyString = 'test_secure_key';

  // 니모닉 암호화
  static String encryptMnemonic(String mnemonic) {
    try {
      final key = encrypt.Key.fromUtf8(_keyString);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final encrypted = encrypter.encrypt(mnemonic, iv: iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Encryption failed');
    }
  }

  // 니모닉 복호화
  static String decryptMnemonic(String encryptedMnemonic) {
    try {
      final key = encrypt.Key.fromUtf8(_keyString);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final decrypted = encrypter.decrypt64(encryptedMnemonic, iv: iv);
      return decrypted;
    } catch (e) {
      print('복호화 중 에러 발생: $e');
      throw Exception('Decryption failed');
    }
  }
}

class SharedPrefsUtil {
  static late final SharedPreferences _prefs;

  SharedPrefsUtil._();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getString(String key) => _prefs.getString(key);

  static Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  static bool? getBool(String key) => _prefs.getBool(key);

  static Future<bool> setBool(String key, bool value) =>
      _prefs.setBool(key, value);

  static Future<bool> remove(String key) => _prefs.remove(key);

  static Future<bool> clear() => _prefs.clear();
}
