import 'package:dart_frog/dart_frog.dart';
import 'package:demo/database.dart';
import 'package:demo/models/match.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    // Ensure the database connection is open
    if (db.connection.isClosed) {
      await db.connection.open();
    }

    if (context.request.method == HttpMethod.get) {
      final gameId = context.request.uri.queryParameters['gameId'];
      List<List<dynamic>> result;

      if (gameId != null) {
        result = await db.connection.query(
          'SELECT * FROM matches WHERE game_id = @gameId',
          substitutionValues: {'gameId': int.parse(gameId)},
        );
      } else {
        result = await db.connection.query('SELECT * FROM matches');
      }

      final matches = result.map((row) => Match.fromJson({
        'matchId': row[0],
        'mapId': row[1],
        'team1': row[2],
        'team2': row[3],
        'matchScore1': row[4],
        'matchScore2': row[5],
        'matchTime': (row[6] as DateTime).toIso8601String(),
        'gameId': row[7],
      })).toList();
      return Response.json(body: matches.map((m) => m.toJson()).toList());
    } else if (context.request.method == HttpMethod.post) {
      final payload = await context.request.json();
      final match = Match.fromJson(payload as Map<String, dynamic>);
      await db.connection.query('''
        INSERT INTO matches (map_id, team1, team2, match_score1, match_score2, match_time, game_id)
        VALUES (@map_id, @team1, @team2, @match_score1, @match_score2, @match_time, @game_id)
      ''', substitutionValues: {
        'map_id': match.mapId.name,
        'team1': match.team1,
        'team2': match.team2,
        'match_score1': match.matchScore1,
        'match_score2': match.matchScore2,
        'match_time': match.matchTime.toIso8601String(),
        'game_id': match.gameId,
      });
      return Response.json(body: match.toJson(), statusCode: 201);
    } else {
      return Response(statusCode: 405);
    }
  } catch (e) {
    print('Error: $e');
    return Response(statusCode: 500, body: 'Internal Server Error');
  }
}
