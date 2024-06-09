import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import '../models/broadcast.dart';

const String apiKey = 'your-api-here';
const String channelId = 'channel-here';

Future<List<Broadcast>> fetchYouTubeBroadcasts() async {
  final url = 'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&maxResults=10&order=date&type=video&key=$apiKey';
  final response = await http.get(Uri.parse(url));
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List<Broadcast> broadcasts = [];

    for (var item in data['items'] as List<dynamic>) {
      final isLive = item['snippet']['liveBroadcastContent'] == 'live';
      final broadcast = Broadcast(
        broadcastID: 0, // This will be set by the database
        broadcastUrl: 'https://www.youtube.com/watch?v=${item['id']['videoId']}',
        broadcastTime: DateTime.parse(item['snippet']['publishedAt'] as String),
        isLive: isLive,
        broadcastTitle: item['snippet']['title'] as String,
      );
      broadcasts.add(broadcast);
    }
    print('Fetched ${broadcasts.length} broadcasts from YouTube');
    return broadcasts;
  } else {
    throw Exception('Failed to fetch broadcasts from YouTube');
  }
}

class YouTubeSyncService {
  static final YouTubeSyncService _instance = YouTubeSyncService._internal();
  late final String _connectionString;
  late final String _username;
  late final String _password;
  late final String _database;

  factory YouTubeSyncService({
    required String connectionString,
    required String username,
    required String password,
    required String database,
  }) {
    _instance._connectionString = connectionString;
    _instance._username = username;
    _instance._password = password;
    _instance._database = database;
    return _instance;
  }

  YouTubeSyncService._internal();

  Future<void> syncBroadcasts() async {
    try {
      List<Broadcast> broadcasts = await fetchYouTubeBroadcasts();
      final dbConnection = PostgreSQLConnection(
        _connectionString,
        5432,
        _database,
        username: _username,
        password: _password,
      );

      await dbConnection.open();

      for (var broadcast in broadcasts) {
        var existingBroadcast = await dbConnection.query(
          'SELECT 1 FROM broadcasts WHERE broadcast_url = @broadcastUrl',
          substitutionValues: {'broadcastUrl': broadcast.broadcastUrl},
        );

        if (existingBroadcast.isEmpty) {
          // Insert new broadcast
          await dbConnection.query('''
            INSERT INTO broadcasts (broadcast_url, broadcast_time, is_live, broadcast_title)
            VALUES (@broadcastUrl, @broadcastTime, @isLive, @broadcastTitle)
          ''', substitutionValues: {
            'broadcastUrl': broadcast.broadcastUrl,
            'broadcastTime': broadcast.broadcastTime.toIso8601String(),
            'isLive': broadcast.isLive,
            'broadcastTitle': broadcast.broadcastTitle,
          });
        } else {
          // Update existing broadcast
          await dbConnection.query('''
            UPDATE broadcasts
            SET broadcast_time = @broadcastTime, is_live = @isLive, broadcast_title = @broadcastTitle
            WHERE broadcast_url = @broadcastUrl
          ''', substitutionValues: {
            'broadcastUrl': broadcast.broadcastUrl,
            'broadcastTime': broadcast.broadcastTime.toIso8601String(),
            'isLive': broadcast.isLive,
            'broadcastTitle': broadcast.broadcastTitle,
          });
        }
      }

      await dbConnection.close();
      print('Broadcast data synchronized successfully.');
    } catch (e) {
      print('Failed to sync broadcasts: $e');
    }
  }

  void startSync() {
    syncBroadcasts();
    Timer.periodic(Duration(hours: 1), (timer) => syncBroadcasts());
  }
}

final youTubeSyncService = YouTubeSyncService(
  connectionString: 'localhost',
  username: 'owcs_user',
  password: 'owcs_password',
  database: 'owcs_db',
);
