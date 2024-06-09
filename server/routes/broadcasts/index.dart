import 'package:dart_frog/dart_frog.dart';
import 'package:demo/database.dart';
import 'package:demo/models/broadcast.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    if (context.request.method == HttpMethod.get) {
      await db.connect();
      final result = await db.connection.query('SELECT * FROM broadcasts');
      final broadcasts = result.map((row) => Broadcast.fromJson({
        'broadcastID': row[0] as int,
        'broadcastUrl': row[1] as String,
        'broadcastTime': (row[2] as DateTime).toIso8601String(),
        'isLive': row[3] as bool,
        'broadcastTitle': row[4] as String,
      })).toList();
      return Response.json(body: broadcasts.map((b) => b.toJson()).toList());
    } else if (context.request.method == HttpMethod.post) {
      final payload = await context.request.json();
      final broadcast = Broadcast.fromJson(payload as Map<String, dynamic>);
      await db.connect();
      await db.connection.query('''
        INSERT INTO broadcasts (broadcast_url, broadcast_time, is_live, broadcast_title)
        VALUES (@broadcast_url, @broadcast_time, @is_live, @broadcast_title)
      ''', substitutionValues: {
        'broadcast_url': broadcast.broadcastUrl,
        'broadcast_time': broadcast.broadcastTime.toIso8601String(),
        'is_live': broadcast.isLive,
        'broadcast_title': broadcast.broadcastTitle,
      });
      return Response.json(body: broadcast.toJson(), statusCode: 201);
    } else {
      return Response(statusCode: 405);
    }
  } catch (e) {
    print('Error: $e');
    return Response(statusCode: 500, body: 'Internal Server Error');
  }
}
