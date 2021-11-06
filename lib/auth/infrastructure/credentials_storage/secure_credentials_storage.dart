import 'package:codehub/auth/infrastructure/credentials_storage/credentials_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/src/credentials.dart';

class SecureCredentialsStorage implements CredentialsStorage {
  final FlutterSecureStorage _storage;

  SecureCredentialsStorage(this._storage);

  @override
  Future<Credentials?> read() {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  Future<void> save(Credentials credentials) {
    // TODO: implement save
    throw UnimplementedError();
  }

  @override
  Future<void> clear() {
    // TODO: implement clear
    throw UnimplementedError();
  }
}
