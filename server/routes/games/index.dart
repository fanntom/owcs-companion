import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/game.dart';
import '../../lib/models/match.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    if (context.request.method == HttpMethod.get) {
      final status = context.request.uri.queryParameters['status'];
      final teamId = context.request.uri.queryParameters['teamId'];
      final query = _buildQuery(status, teamId);

      final gamesResult = await db.connection.query(query);
      final games = <Game>[];

      for (final row in gamesResult) {
        final gameId = row[0] as int;
        final matchesResult = await db.connection.query(
          'SELECT * FROM matches WHERE game_id = @gameId',
          substitutionValues: {'gameId': gameId},
        );
        final matches = matchesResult.map((matchRow) => Match.fromJson({
          'matchId': matchRow[0],
          'mapId': matchRow[1],
          'team1': matchRow[2],
          'team2': matchRow[3],
          'matchScore1': matchRow[4],
          'matchScore2': matchRow[5],
          'matchTime': matchRow[6].toIso8601String(),
          'gameId': matchRow[7],
        })).toList();

        final game = Game(
          gameId: row[0] as int,
          team1: row[1] as int,
          team2: row[2] as int,
          startTime: row[3] as DateTime,
          endTime: row[4] as DateTime?,
          isInProgress: row[5] as bool,
          matches: matches,
        );

        games.add(game);
      }

      return Response.json(body: games.map((g) => g.toJson()).toList());
    } else if (context.request.method == HttpMethod.post) {
      final payload = await context.request.json() as Map<String, dynamic>;
      final game = Game.fromJson(payload);

      await db.connection.query('''
        INSERT INTO games (team1, team2, start_time, end_time, is_in_progress)
        VALUES (@team1, @team2, @start_time, @end_time, @is_in_progress)
      ''', substitutionValues: {
        'team1': game.team1,
        'team2': game.team2,
        'start_time': game.startTime.toIso8601String(),
        'end_time': game.endTime?.toIso8601String(),
        'is_in_progress': game.isInProgress,
      });

      return Response.json(body: game.toJson(), statusCode: 201);
    } else {
      return Response(statusCode: 405);
    }
  } catch (e) {
    print('Error: $e');
    return Response(statusCode: 500, body: 'Internal Server Error');
  }
}

String _buildQuery(String? status, String? teamId) {
  String query = 'SELECT * FROM games';
  List<String> conditions = [];
  if (status == 'upcoming') {
    conditions.add('start_time > NOW() AND is_in_progress = FALSE');
  } else if (status == 'current') {
    conditions.add('is_in_progress = TRUE');
  } else if (status == 'previous') {
    conditions.add('end_time < NOW() AND is_in_progress = FALSE');
  }

  if (teamId != null) {
    conditions.add('(team1 = $teamId OR team2 = $teamId)');
  }

  if (conditions.isNotEmpty) {
    query += ' WHERE ' + conditions.join(' AND ');
  }

  return query;
}
