import 'package:dart_frog/dart_frog.dart';
import '../../../lib/database.dart';
import '../../../lib/models/player.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final userId = request.headers['User-ID'];

  if (userId == null) {
    return Response(statusCode: 400, body: 'User ID is required');
  }

  if (request.method == HttpMethod.get) {
    final result = await db.connection.query('''
      SELECT p.* FROM players p
      JOIN bookmarked_players bp ON p.player_uid = bp.player_id
      WHERE bp.user_id = @userId
    ''', substitutionValues: {'userId': userId},);

    final players = result.map((row) => Player.fromJson({
      'playerUid': row[0],
      'playertag': row[1],
      'realname': row[2],
      'currentTeamId': row[3],
      'playerLogo': row[4],
      'position': row[5],
      'region': row[6],
      'isActive': row[7],
    })).toList();

    return Response.json(body: players.map((p) => p.toJson()).toList());
  } else if (request.method == HttpMethod.post) {
    final payload = await request.json() as Map<String, dynamic>;
    final playerId = payload['playerId'] as int;

    final existingBookmark = await db.connection.query('''
      SELECT 1 FROM bookmarked_players WHERE user_id = @userId AND player_id = @playerId
    ''', substitutionValues: {
      'userId': userId,
      'playerId': playerId,
    });

    if (existingBookmark.isEmpty) {
      await db.connection.query('''
        INSERT INTO bookmarked_players (user_id, player_id)
        VALUES (@userId, @playerId)
      ''', substitutionValues: {
        'userId': userId,
        'playerId': playerId,
      });
      return Response(statusCode: 201);
    } else {
      return Response(statusCode: 409, body: 'Player already bookmarked');
    }
  } else if (request.method == HttpMethod.delete) {
    final payload = await request.json() as Map<String, dynamic>;
    final playerId = payload['playerId'] as int;

    await db.connection.query('''
      DELETE FROM bookmarked_players WHERE user_id = @userId AND player_id = @playerId
    ''', substitutionValues: {
      'userId': userId,
      'playerId': playerId,
    });

    return Response(statusCode: 204);
  } else {
    return Response(statusCode: 405);
  }
}
