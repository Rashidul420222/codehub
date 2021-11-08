import 'package:codehub/auth/domain/auth_failure.dart';
import 'package:codehub/auth/infrastructure/credentials_storage/credentials_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:oauth2/oauth2.dart';
import 'package:http/http.dart' as http;

class GithubOAuthHttpClient extends http.BaseClient {
  final httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return httpClient.send(request);
  }
}

class GithubAuthenticator {
  final CredentialsStorage _credentialsStorage;

  GithubAuthenticator(this._credentialsStorage);

  static const clientId = '52a64130377ac1c3a4ba';
  static const clientSecrets = 'd0f3061ab4b3d0ca04af9ef0c7b0bef1b6fe5168';
  static const scopes = ['read:user', 'repo'];
  static final authorizationEndpoint =
      Uri.parse('https://github.com/login/oauth/authorize');
  static final tokenEndpoint =
      Uri.parse('https://github.com/login/oauth/access_token');
  static final redirectUrl = Uri.parse('http://localhost:3000/callback');

  Future<Credentials?> getSignedInCredentials() async {
    try {
      final storedCredentials = await _credentialsStorage.read();

      if (storedCredentials != null) {
        if (storedCredentials.canRefresh && storedCredentials.isExpired) {}
        return storedCredentials;
      }
    } on PlatformException {
      return null;
    }
  }

  Future<bool> isSignedIn() =>
      getSignedInCredentials().then((credentials) => credentials != null);

  AuthorizationCodeGrant codeGrant() {
    return AuthorizationCodeGrant(
      clientId,
      authorizationEndpoint,
      tokenEndpoint,
      secret: clientSecrets,
      httpClient: GithubOAuthHttpClient(),
    );
  }

  Uri getAuthorizationUrl(AuthorizationCodeGrant grant) {
    return grant.getAuthorizationUrl(redirectUrl, scopes: scopes);
  }

  Future<Either<AuthFailure, Unit>> HandleAuthorizationResponse(
    AuthorizationCodeGrant grant,
    Map<String, String> queryParams,
  ) async {
    try {
      final httpClient = await grant.handleAuthorizationResponse(queryParams);
      await _credentialsStorage.save(httpClient.credentials);
      return right(unit);
    } on FormatException {
      return left(const AuthFailure.server());
    } on AuthorizationException catch (e) {
      return left(AuthFailure.server('${e.error} : ${e.description}'));
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }
}
