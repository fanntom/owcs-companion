import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/player.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final searchQuery = request.uri.queryParameters['search'];
  final teamIdQuery = request.uri.queryParameters['teamId'];

  if (request.method == HttpMethod.get) {
    List<List<dynamic>> result;

    if (teamIdQuery != null) {
      // If teamId query parameter is provided, filter players by team ID
      final teamId = int.tryParse(teamIdQuery);
      if (teamId == null) {
        return Response(statusCode: 400, body: 'Invalid teamId');
      }
      result = await db.connection.query(
        'SELECT * FROM players WHERE current_team_id = @teamId ORDER BY position ASC',
        substitutionValues: {'teamId': teamId},
      );
    } else if (searchQuery != null && searchQuery.isNotEmpty) {
      // If search query parameter is provided, filter players by search query
      result = await db.connection.query(
        'SELECT * FROM players WHERE playertag ILIKE @searchQuery OR realname ILIKE @searchQuery',
        substitutionValues: {'searchQuery': '%$searchQuery%'},
      );
    } else {
      // Otherwise, return all players
      result = await db.connection.query('SELECT * FROM players');
    }

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
    final player = Player.fromJson(payload);
    await db.connection.query('''
      INSERT INTO players (playertag, realname, current_team_id, player_logo, position, region, is_active)
      VALUES (@playertag, @realname, @current_team_id, @player_logo, @position, @region, @is_active)
    ''', substitutionValues: {
      'playertag': player.playertag,
      'realname': player.realname,
      'current_team_id': player.currentTeamId,
      'player_logo': player.playerLogo,
      'position': player.position.name,
      'region': player.region.name,
      'is_active': player.isActive,
    });
    return Response.json(body: player.toJson(), statusCode: 201);
  } else {
    return Response(statusCode: 405);
  }
}
