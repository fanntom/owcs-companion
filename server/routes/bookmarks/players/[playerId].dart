import 'package:dart_frog/dart_frog.dart';
import '../../../lib/database.dart';

Future<Response> onRequest(RequestContext context, String playerId) async {
  final userId = context.request.headers['User-ID'];

  if (userId == null) {
    return Response(statusCode: 400, body: 'User ID is required');
  }

  if (context.request.method == HttpMethod.get) {
    final result = await db.connection.query('''
      SELECT 1 FROM bookmarked_players WHERE user_id = @userId AND player_id = @playerId
    ''', substitutionValues: {
      'userId': userId,
      'playerId': int.parse(playerId),
    });

    if (result.isNotEmpty) {
      return Response.json(body: true);
    } else {
      return Response.json(body: false);
    }
  } else if (context.request.method == HttpMethod.delete) {
    await db.connection.query('''
      DELETE FROM bookmarked_players WHERE user_id = @userId AND player_id = @playerId
    ''', substitutionValues: {
      'userId': userId,
      'playerId': int.parse(playerId),
    });

    return Response(statusCode: 204);
  }

  return Response(statusCode: 405);
}
