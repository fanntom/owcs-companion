import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Broadcasts API', () {
    test('GET /broadcasts returns list of broadcasts', () async {
      // Arrange
      final url = Uri.parse('http://localhost:8080/broadcasts');

      // Act
      final response = await http.get(url);

      // Assert
      expect(response.statusCode, equals(200));
      final List<dynamic> broadcasts = jsonDecode(response.body) as List<dynamic>;
      expect(broadcasts, isA<List<dynamic>>());
      expect(broadcasts.isNotEmpty, true);
    });

    test('POST /broadcasts creates a new broadcast', () async {
      // Arrange
      final url = Uri.parse('http://localhost:8080/broadcasts');
      final newBroadcast = {
        'broadcastUrl': 'https://www.youtube.com/watch?v=test',
        'broadcastTime': DateTime.now().toIso8601String(),
        'isLive': false,
        'broadcastTitle': 'Test Broadcast'
      };

      // Act
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newBroadcast),
      );

      // Assert
      expect(response.statusCode, equals(201));
      final createdBroadcast = jsonDecode(response.body) as Map<String, dynamic>;
      expect(createdBroadcast['broadcastUrl'], equals(newBroadcast['broadcastUrl']));
    });
  });
}
