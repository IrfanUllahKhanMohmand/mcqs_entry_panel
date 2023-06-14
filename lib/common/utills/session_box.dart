import 'package:hive/hive.dart';

class SessionBox {
  static const String _boxName = 'sessionBox';
  static const String _tokenKey = 'sessionToken';

  static Future<void> saveToken(String token) async {
    final box = await Hive.openBox<String>(_boxName);
    await box.put(_tokenKey, token);
    await box.close();
  }

  static Future<String?> getToken() async {
    final box = await Hive.openBox<String>(_boxName);
    final token = box.get(_tokenKey);
    await box.close();
    return token;
  }

  static Future<void> deleteToken() async {
    final box = await Hive.openBox<String>(_boxName);
    await box.delete(_tokenKey);
    await box.close();
  }
}
