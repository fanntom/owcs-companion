import 'package:dart_frog/dart_frog.dart';
import 'package:demo/database.dart';
import 'package:demo/models/match.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final matchId = int.parse(id);

  if (context.request.method == HttpMethod.get) {
    final result = await db.connection.query('SELECT * FROM matches WHERE match_id = @matchId', substitutionValues: {'matchId': matchId});
    if (result.isEmpty) {
      return Response(statusCode: 404);
    }
    final match = Match.fromJson({
      'matchId': result.first[0] as int,
      'mapId': result.first[1] as String,
      'team1': result.first[2] as int,
      'team2': result.first[3] as int,
      'matchScore1': result.first[4] as int,
      'matchScore2': result.first[5] as int,
      'matchTime': result.first[6].toIso8601String(),
      'gameId': result.first[7] as int,
    });
    return Response.json(body: match.toJson());
  } else if (context.request.method == HttpMethod.put) {
    final payload = await context.request.json() as Map<String, dynamic>;
    final match = Match.fromJson(payload);
    await db.connection.query('''
      UPDATE matches
      SET map_id = @map_id, team1 = @team1, team2 = @team2, match_score1 = @match_score1, match_score2 = @match_score2, match_time = @match_time, game_id = @game_id
      WHERE match_id = @matchId
    ''', substitutionValues: {
      'map_id': match.mapId.name,
      'team1': match.team1,
      'team2': match.team2,
      'match_score1': match.matchScore1,
      'match_score2': match.matchScore2,
      'match_time': match.matchTime.toIso8601String(),
      'game_id': match.gameId,
      'matchId': matchId,
    });
    return Response.json(body: match.toJson());
  } else if (context.request.method == HttpMethod.delete) {
    await db.connection.query('DELETE FROM matches WHERE match_id = @matchId', substitutionValues: {'matchId': matchId});
    return Response(statusCode: 204);
  } else {
    return Response(statusCode: 405);
  }
}
