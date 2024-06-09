import 'package:dart_frog/dart_frog.dart';
import 'package:demo/database.dart';
import 'package:demo/models/game.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final gameId = int.parse(id);

  if (context.request.method == HttpMethod.get) {
    await db.connect();
    final result = await db.connection.query('SELECT * FROM games WHERE game_id = @gameId', substitutionValues: {'gameId': gameId});
    if (result.isEmpty) {
      return Response(statusCode: 404);
    }
    final game = Game.fromJson({
      'gameId': result.first[0] as int,
      'team1': result.first[1] as int,
      'team2': result.first[2] as int,
      'startTime': result.first[3].toIso8601String(),
      'endTime': result.first[4]?.toIso8601String(),
      'isInProgress': result.first[5] as bool,
    });
    return Response.json(body: game.toJson());
  } else if (context.request.method == HttpMethod.put) {
    final payload = await context.request.json() as Map<String, dynamic>;
    final game = Game.fromJson(payload);
    await db.connect();
    await db.connection.query('''
      UPDATE games
      SET team1 = @team1, team2 = @team2, start_time = @start_time, end_time = @end_time, is_in_progress = @is_in_progress
      WHERE game_id = @gameId
    ''', substitutionValues: {
      'team1': game.team1,
      'team2': game.team2,
      'start_time': game.startTime.toIso8601String(),
      'end_time': game.endTime?.toIso8601String(),
      'is_in_progress': game.isInProgress,
      'gameId': gameId,
    });
    return Response.json(body: game.toJson());
  } else if (context.request.method == HttpMethod.delete) {
    await db.connect();
    
    // Delete related matches
    await db.connection.query('DELETE FROM matches WHERE game_id = @gameId', substitutionValues: {'gameId': gameId});
    
    // Delete the game
    await db.connection.query('DELETE FROM games WHERE game_id = @gameId', substitutionValues: {'gameId': gameId});
    return Response(statusCode: 204);
  } else {
    return Response(statusCode: 405);
  }
}
