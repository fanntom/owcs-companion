import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Players API', () {
    final String baseUrl = 'http://localhost:8080';
    late int createdPlayerId;

    setUpAll(() async {
      // Create a player to be used in subsequent tests
      final url = Uri.parse('$baseUrl/players');
      final newPlayer = {
        'playertag': 'test_player',
        'realname': 'Test Player',
        'currentTeamId': 1,
        'playerLogo': 'http://example.com/logo.png',
        'position': 'dps',
        'region': 'NA',
        'isActive': true,
      };
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newPlayer),
      );
      if (response.statusCode == 201) {
        final createdPlayer = jsonDecode(response.body) as Map<String, dynamic>;
        createdPlayerId = createdPlayer['playerUid'] as int;
      } else {
        throw Exception('Failed to create a player for tests');
      }
    });

    tearDownAll(() async {
      // Delete the player created for tests
      final url = Uri.parse('$baseUrl/players/$createdPlayerId');
      await http.delete(url);
    });

    test('GET /players returns list of players', () async {
      // Arrange
      final url = Uri.parse('$baseUrl/players');

      // Act
      final response = await http.get(url);

      // Assert
      expect(response.statusCode, equals(200));
      final List<dynamic> players = jsonDecode(response.body) as List<dynamic>;
      expect(players, isA<List>());
    });

    test('GET /players?search=test returns filtered list of players', () async {
      // Arrange
      final url = Uri.parse('$baseUrl/players?search=test');

      // Act
      final response = await http.get(url);

      // Assert
      expect(response.statusCode, equals(200));
      final List<dynamic> players = jsonDecode(response.body) as List<dynamic>;
      expect(players, isA<List>());
    });

    test('GET /players?teamId=1 returns list of players in team', () async {
      // Arrange
      final url = Uri.parse('$baseUrl/players?teamId=1');

      // Act
      final response = await http.get(url);

      // Assert
      expect(response.statusCode, equals(200));
      final List<dynamic> players = jsonDecode(response.body) as List<dynamic>;
      expect(players, isA<List>());
    });

    test('GET /players/:id returns a player by ID', () async {
      // Arrange
      final url = Uri.parse('$baseUrl/players/$createdPlayerId');

      // Act
      final response = await http.get(url);

      // Assert
      expect(response.statusCode, equals(200));
      final player = jsonDecode(response.body) as Map<String, dynamic>;
      expect(player['playerUid'], equals(createdPlayerId));
    });

    test('PUT /players/:id updates a player', () async {
      // Arrange
      final url = Uri.parse('$baseUrl/players/$createdPlayerId');
      final updatedPlayer = {
        'playerUid': createdPlayerId,
        'playertag': 'updated_player',
        'realname': 'Updated Player',
        'currentTeamId': 1,
        'playerLogo': 'http://example.com/logo_updated.png',
        'position': 'support',
        'region': 'NA',
        'isActive': false,
      };

      // Act
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedPlayer),
      );

      // Assert
      expect(response.statusCode, equals(200));
      final player = jsonDecode(response.body) as Map<String, dynamic>;
      expect(player['playertag'], equals(updatedPlayer['playertag']));
    });

    test('DELETE /players/:id deletes a player', () async {
      // Arrange
      final url = Uri.parse('$baseUrl/players/$createdPlayerId');

      // Act
      final response = await http.delete(url);

      // Assert
      expect(response.statusCode, equals(204));
    });
  });
}
