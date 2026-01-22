import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheToken(String accessToken, String refreshToken) async {
    await secureStorage.write(key: 'ACCESS_TOKEN', value: accessToken);
    await secureStorage.write(key: 'REFRESH_TOKEN', value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: 'ACCESS_TOKEN');
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: 'REFRESH_TOKEN');
  }

  @override
  Future<void> clearToken() async {
    await secureStorage.delete(key: 'ACCESS_TOKEN');
    await secureStorage.delete(key: 'REFRESH_TOKEN');
  }
}
