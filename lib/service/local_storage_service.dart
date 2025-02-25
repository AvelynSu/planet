import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:planet/model/planet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static Future<void> saveMnemonics(List<Planet> mnemonics,
      {String? isCurrentAddress}) async {
    const storage = FlutterSecureStorage();

    final existingData = await storage.read(key: 'planets');
    List<dynamic> storedList =
        existingData != null ? jsonDecode(existingData) : [];

    // 새로 받은 Planet 객체들을 처리
    for (var planet in mnemonics) {
      final json = planet.toJson(isLocal: true);
      final existingIndex =
          storedList.indexWhere((item) => item['address'] == planet.address);

      if (existingIndex != -1) {
        // 이미 있는 주소면 덮어쓰기
        storedList[existingIndex] = json;
      } else {
        // 없는 주소면 추가
        storedList.add(json);
      }
    }

    // isCurrentAddress에 값이 있으면 해당 주소의 객체만 isCurrent가 true, 나머지는 false로 설정
    if (isCurrentAddress != null) {
      storedList = storedList.map((item) {
        Map<String, dynamic> planetMap = Map<String, dynamic>.from(item);
        planetMap['isCurrent'] = planetMap['address'] == isCurrentAddress;
        return planetMap;
      }).toList();
    }

    final encodedJson = jsonEncode(storedList);
    await storage.write(key: 'planets', value: encodedJson);
  }

  static Future<List<Planet>> getLocalPlanets() async {
    const storage = FlutterSecureStorage();
    final encodedJson = await storage.read(key: 'planets');

    if (encodedJson == null) return [];

    final jsonList = jsonDecode(encodedJson) as List;
    return jsonList.map((json) => Planet.fromJson(json)).toList();
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
