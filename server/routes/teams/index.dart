import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/team.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final searchQuery = request.uri.queryParameters['search'];

  if (request.method == HttpMethod.get) {
    List<List<dynamic>> result;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      result = await db.connection.query('''
        SELECT * FROM teams
        WHERE team_name ILIKE @searchQuery
      ''', substitutionValues: {
        'searchQuery': '%$searchQuery%',
      });
    } else {
      result = await db.connection.query('SELECT * FROM teams');
    }

    final teams = result.map((row) => Team.fromJson({
      'teamUid': row[0],
      'teamName': row[1],
      'teamLogo': row[2],
      'region': row[3],
    })).toList();

    return Response.json(body: teams.map((t) => t.toJson()).toList());
  } else if (request.method == HttpMethod.post) {
    final payload = await request.json() as Map<String, dynamic>;
    final team = Team.fromJson(payload);
    await db.connection.query('''
      INSERT INTO teams (team_name, team_logo, region)
      VALUES (@team_name, @team_logo, @region)
    ''', substitutionValues: {
      'team_name': team.teamName,
      'team_logo': team.teamLogo,
      'region': team.region.name,
    });
    return Response.json(body: team.toJson(), statusCode: 201);
  } else {
    return Response(statusCode: 405);
  }
}
