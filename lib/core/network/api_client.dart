import 'package:http/http.dart' as http;
import '../../features/auth/data/datasources/auth_local_data_source.dart';

class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final AuthLocalDataSource _authLocalDataSource;

  AuthenticatedClient(this._inner, this._authLocalDataSource);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final accessToken = await _authLocalDataSource.getAccessToken();
    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    var response = await _inner.send(request);

    if (response.statusCode == 401) {
      // Token might be expired, try to refresh
      final refreshed = await _refreshToken();
      if (refreshed) {
        final newAccessToken = await _authLocalDataSource.getAccessToken();
        final newRequest = _copyRequest(request);
        newRequest.headers['Authorization'] = 'Bearer $newAccessToken';
        response = await _inner.send(newRequest);
      }
    }

    return response;
  }

  Future<bool> _refreshToken() async {
    // Mocking the refresh logic
    await Future.delayed(const Duration(milliseconds: 500));
    // Assume success and save new tokens
    await _authLocalDataSource.cacheToken(
        "new_access_token", "new_refresh_token");
    return true;
  }

  http.BaseRequest _copyRequest(http.BaseRequest request) {
    http.BaseRequest requestCopy;

    if (request is http.Request) {
      requestCopy = http.Request(request.method, request.url)
        ..encoding = request.encoding
        ..bodyBytes = request.bodyBytes;
    } else {
      // Fallback or throw for other types if strictly needed, but simple Request is ok for now
      requestCopy = http.Request(request.method, request.url);
    }

    requestCopy.headers.addAll(request.headers);
    requestCopy.followRedirects = request.followRedirects;
    requestCopy.maxRedirects = request.maxRedirects;
    requestCopy.persistentConnection = request.persistentConnection;

    return requestCopy;
  }
}
