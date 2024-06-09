import 'package:dart_frog/dart_frog.dart';
import '../../../lib/database.dart';

Future<Response> onRequest(RequestContext context, String teamId) async {
  final request = context.request;
  final userId = request.headers['User-ID'];

  if (userId == null) {
    return Response(statusCode: 400, body: 'User ID is required');
  }

  try {
    if (request.method == HttpMethod.get) {
      final result = await db.connection.query('''
        SELECT 1 FROM bookmarked_teams WHERE user_id = @userId AND team_id = @teamId
      ''', substitutionValues: {
        'userId': userId,
        'teamId': int.parse(teamId),
      });

      final isBookmarked = result.isNotEmpty;
      return Response.json(body: isBookmarked);
    } else if (request.method == HttpMethod.delete) {
      await db.connection.query('''
        DELETE FROM bookmarked_teams WHERE user_id = @userId AND team_id = @teamId
      ''', substitutionValues: {
        'userId': userId,
        'teamId': int.parse(teamId),
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
