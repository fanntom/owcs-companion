import 'dart:convert';
import 'dart:async';
import 'package:process_run/shell.dart';
import 'package:postgres/postgres.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  final Shell _shell = Shell();

  factory SyncService() {
    return _instance;
  }

  SyncService._internal();

  Future<void> syncUsers() async {
    try {
      print('Running shell command to fetch users...');
      await _shell.run(
        'docker-compose exec keycloak ./opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password admin'
      );
      var result = await _shell.run(
        'docker-compose exec keycloak ./opt/keycloak/bin/kcadm.sh get users -r owcs-app'
      );

      print('Shell command result: $result');
      final output = result.map((r) => r.outText).join('\n');
      print('Shell command output: $output');

      final users = jsonDecode(output) as List<dynamic>;

      print('Users received from Keycloak:');
      for (var user in users) {
        print(user);
      }

      final dbConnection = PostgreSQLConnection(
        'localhost',
        5432,
        'owcs_db',
        username: 'owcs_user',
        password: 'owcs_password',
      );
      await dbConnection.open();

      for (var user in users) {
        final email = user['email'] as String;
        final username = user['username'] as String;
        final roles = (user['access'] as Map<String, dynamic>).keys.join(',');

        var existingUser = await dbConnection.query(
          'SELECT 1 FROM users WHERE user_id = @userId',
          substitutionValues: {'userId': email}
        );

        if (existingUser.isEmpty) {
          // Insert new user
          await dbConnection.query('''
            INSERT INTO users (user_id, username, email, roles)
            VALUES (@userId, @username, @email, @roles)
          ''', substitutionValues: {
            'userId': email,
            'username': username,
            'email': email,
            'roles': roles,
          });
        } else {
          // Update existing user
          await dbConnection.query('''
            UPDATE users
            SET username = @username, roles = @roles
            WHERE user_id = @userId
          ''', substitutionValues: {
            'userId': email,
            'username': username,
            'roles': roles,
          });
        }
      }

      await dbConnection.close();
      print('User data synchronized successfully.');
    } catch (e) {
      print('Failed to sync users: $e');
    }
  }

  void startSync() {
    syncUsers();
    Timer.periodic(Duration(minutes: 10), (timer) => syncUsers());
  }
}

final syncService = SyncService();
