import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';
import '../../lib/models/team.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final teamId = int.parse(id);

  if (context.request.method == HttpMethod.get) {
    final result = await db.connection.query('SELECT * FROM teams WHERE team_uid = @teamId', substitutionValues: {'teamId': teamId});
    if (result.isEmpty) {
      return Response(statusCode: 404);
    }
    final team = Team.fromJson({
      'teamUid': result.first[0],
      'teamName': result.first[1],
      'teamLogo': result.first[2],
      'region': result.first[3],
    });
    return Response.json(body: team.toJson());
  } else if (context.request.method == HttpMethod.put) {
    final payload = await context.request.json() as Map<String, dynamic>;
    final team = Team.fromJson(payload);
    await db.connection.query('''
      UPDATE teams
      SET team_name = @team_name, team_logo = @team_logo, region = @region
      WHERE team_uid = @teamId
    ''', substitutionValues: {
      'team_name': team.teamName,
      'team_logo': team.teamLogo,
      'region': team.region.name,
      'teamId': teamId,
    });
    return Response.json(body: team.toJson());
  } else if (context.request.method == HttpMethod.delete) {
    await db.connection.query('DELETE FROM teams WHERE team_uid = @teamId', substitutionValues: {'teamId': teamId});
    return Response(statusCode: 204);
  } else {
    return Response(statusCode: 405);
  }
}
