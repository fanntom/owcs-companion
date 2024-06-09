import 'package:dart_frog/dart_frog.dart';
import '../../../lib/database.dart';
import '../../../lib/models/team.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final userId = request.headers['User-ID'];

  if (userId == null) {
    print('User ID is required');
    return Response(statusCode: 400, body: 'User ID is required');
  }

  try {
    if (request.method == HttpMethod.get) {
      final result = await db.connection.query('''
        SELECT t.* FROM teams t
        JOIN bookmarked_teams bt ON t.team_uid = bt.team_id
        WHERE bt.user_id = @userId
      ''', substitutionValues: {'userId': userId});

      final teams = result.map((row) => Team.fromJson({
        'teamUid': row[0],
        'teamName': row[1],
        'teamLogo': row[2],
        'region': row[3],
      })).toList();

      return Response.json(body: teams.map((t) => t.toJson()).toList());
    } else if (request.method == HttpMethod.post) {
      final payload = await request.json() as Map<String, dynamic>;
      print('Received payload: $payload'); // Log the received payload

      final teamId = payload['teamId'];
      if (teamId == null) {
        return Response(statusCode: 400, body: 'teamId is required');
      }

      final existingBookmark = await db.connection.query('''
        SELECT 1 FROM bookmarked_teams WHERE user_id = @userId AND team_id = @teamId
      ''', substitutionValues: {
        'userId': userId,
        'teamId': teamId,
      });

      if (existingBookmark.isEmpty) {
        await db.connection.query('''
          INSERT INTO bookmarked_teams (user_id, team_id)
          VALUES (@userId, @teamId)
        ''', substitutionValues: {
          'userId': userId,
          'teamId': teamId,
        });
        return Response(statusCode: 201);
      } else {
        return Response(statusCode: 409, body: 'Team already bookmarked');
      }
    } else if (request.method == HttpMethod.delete) {
      final payload = await request.json() as Map<String, dynamic>;
      final teamId = payload['teamId'];
      if (teamId == null) {
        return Response(statusCode: 400, body: 'teamId is required');
      }

      await db.connection.query('''
        DELETE FROM bookmarked_teams WHERE user_id = @userId AND team_id = @teamId
      ''', substitutionValues: {
        'userId': userId,
        'teamId': teamId,
      });

      return Response(statusCode: 204);
    } else {
      return Response(statusCode: 405);
    }
  } catch (e) {
    print('Error: $e');
    return Response(statusCode: 500, body: 'Internal Server Error');
  }
}
