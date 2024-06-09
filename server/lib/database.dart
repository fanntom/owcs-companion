import 'package:postgres/postgres.dart';

class Database {
  static final Database _instance = Database._internal();
  late PostgreSQLConnection connection;

  factory Database() {
    return _instance;
  }

  Database._internal() {
    connection = PostgreSQLConnection(
      'localhost',
      5432,
      'owcs_db',
      username: 'owcs_user',
      password: 'owcs_password',
    );
  }

  Future<void> connect() async {
    if (connection.isClosed) {
      await connection.open();
    }
  }
}

final db = Database();
