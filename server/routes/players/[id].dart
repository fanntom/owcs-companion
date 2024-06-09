import 'package:dart_frog/dart_frog.dart';
import 'package:demo/database.dart';
import 'package:demo/models/player.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final playerId = int.parse(id);

  if (context.request.method == HttpMethod.get) {
    final result = await db.connection.query('SELECT * FROM players WHERE player_uid = @playerId', substitutionValues: {'playerId': playerId});
    if (result.isEmpty) {
      return Response(statusCode: 404);
    }
    final player = Player.fromJson({
      'playerUid': result.first[0],
      'playertag': result.first[1],
      'realname': result.first[2],
      'currentTeamId': result.first[3],
      'playerLogo': result.first[4],
      'position': result.first[5],
      'region': result.first[6],
      'isActive': result.first[7],
    });
    return Response.json(body: player.toJson());
  } else if (context.request.method == HttpMethod.put) {
    final payload = await context.request.json() as Map<String, dynamic>;
    final player = Player.fromJson(payload);
    await db.connection.query('''
      UPDATE players
      SET playertag = @playertag, realname = @realname, current_team_id = @current_team_id,
          player_logo = @player_logo, position = @position, region = @region, is_active = @is_active
      WHERE player_uid = @playerId
    ''', substitutionValues: {
      'playertag': player.playertag,
      'realname': player.realname,
      'current_team_id': player.currentTeamId,
      'player_logo': player.playerLogo,
      'position': player.position.name,
      'region': player.region.name,
      'is_active': player.isActive,
      'playerId': playerId,
    });
    return Response.json(body: player.toJson());
  } else if (context.request.method == HttpMethod.delete) {
    await db.connection.query('DELETE FROM players WHERE player_uid = @playerId', substitutionValues: {'playerId': playerId});
    return Response(statusCode: 204);
  } else {
    return Response(statusCode: 405);
  }
}
