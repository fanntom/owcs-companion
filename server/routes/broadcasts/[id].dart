import 'package:dart_frog/dart_frog.dart';
import 'package:demo/database.dart';
import 'package:demo/models/broadcast.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final broadcastId = int.parse(id);

  try {
    if (context.request.method == HttpMethod.get) {
      await db.connect();
      final result = await db.connection.query(
        'SELECT * FROM broadcasts WHERE broadcast_id = @broadcastId',
        substitutionValues: {'broadcastId': broadcastId},
      );

      if (result.isEmpty) {
        return Response(statusCode: 404);
      }

      final broadcast = Broadcast.fromJson({
        'broadcastID': result.first[0] as int,
        'broadcastUrl': result.first[1] as String,
        'broadcastTime': (result.first[2] as DateTime).toIso8601String(),
        'isLive': result.first[3] as bool,
        'broadcastTitle': result.first[4] as String,
      });

      return Response.json(body: broadcast.toJson());
    } else if (context.request.method == HttpMethod.put) {
      final payload = await context.request.json() as Map<String, dynamic>;
      final broadcast = Broadcast.fromJson(payload);

      await db.connect();
      await db.connection.query('''
        UPDATE broadcasts
        SET broadcast_url = @broadcast_url, broadcast_time = @broadcast_time, is_live = @is_live, broadcast_title = @broadcast_title
        WHERE broadcast_id = @broadcastId
      ''', substitutionValues: {
        'broadcast_url': broadcast.broadcastUrl,
        'broadcast_time': broadcast.broadcastTime.toIso8601String(),
        'is_live': broadcast.isLive,
        'broadcast_title': broadcast.broadcastTitle,
        'broadcastId': broadcastId,
      });

      return Response.json(body: broadcast.toJson());
    } else if (context.request.method == HttpMethod.delete) {
      await db.connect(); // Ensure the connection is open
      await db.connection.query(
        'DELETE FROM broadcasts WHERE broadcast_id = @broadcastId',
        substitutionValues: {'broadcastId': broadcastId},
      );

      return Response(statusCode: 204);
    } else {
      return Response(statusCode: 405);
    }
  } catch (e) {
    print('Error: $e');
    return Response(statusCode: 500, body: 'Internal Server Error');
  }
}
