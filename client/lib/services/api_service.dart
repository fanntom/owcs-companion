import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/player.dart';
import '../models/team.dart';
import '../models/game.dart';
import '../models/match.dart';
import '../models/standings_entry.dart';
import '../models/broadcast.dart';

class ApiService {
  static const String baseUrl = 'http://172.30.1.22:8080';

  Future<List<Player>> searchPlayers(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/players?search=$query'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Player.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load players');
    }
  }

  Future<List<Team>> searchTeams(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/teams?search=$query'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Team.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load teams');
    }
  }

  Future<List<Player>> getPlayersByTeam(int teamId) async {
    final response = await http.get(Uri.parse('$baseUrl/players?teamId=$teamId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Player.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load players for team');
    }
  }

  Future<void> bookmarkTeam(int teamId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookmarks/teams'),
      headers: {
        'Content-Type': 'application/json',
        'User-ID': userId,
      },
      body: jsonEncode({'teamId': teamId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to bookmark team');
    }
  }

  Future<void> removeBookmarkTeam(int teamId, String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/bookmarks/teams/$teamId'),
      headers: {'User-ID': userId},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to remove bookmark for team');
    }
  }

  Future<void> bookmarkPlayer(int playerId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookmarks/players'),
      headers: {
        'Content-Type': 'application/json',
        'User-ID': userId,
      },
      body: jsonEncode({'playerId': playerId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to bookmark player');
    }
  }

  Future<void> removeBookmarkPlayer(int playerId, String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/bookmarks/players/$playerId'),
      headers: {'User-ID': userId},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to remove bookmark for player');
    }
  }

  Future<bool> isTeamBookmarked(int teamId, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookmarks/teams/$teamId'),
      headers: {'User-ID': userId},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      print('Failed to check if team is bookmarked. Status code: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to check if team is bookmarked');
    }
  }

  Future<bool> isPlayerBookmarked(int playerId, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookmarks/players/$playerId'),
      headers: {'User-ID': userId},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      print('Failed to check if player is bookmarked. Status code: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to check if player is bookmarked');
    }
  }
  Future<List<Team>> getBookmarkedTeams(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookmarks/teams'),
      headers: {'User-ID': userId},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Team.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookmarked teams');
    }
  }

  Future<List<Player>> getBookmarkedPlayers(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookmarks/players'),
      headers: {'User-ID': userId},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Player.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookmarked players');
    }
  }
  Future<List<Game>> getGames({required String status}) async {
    final response = await http.get(Uri.parse('$baseUrl/games?status=$status'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Game.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load games');
    }
  }
  Future<Map<int, Team>> getTeams() async {
    final response = await http.get(Uri.parse('$baseUrl/teams'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return {for (var team in data.map((json) => Team.fromJson(json))) team.teamUid: team};
    } else {
      throw Exception('Failed to load teams');
    }
  }
  Future<List<Match>> getMatchesByGame(int gameId) async {
    final response = await http.get(Uri.parse('$baseUrl/matches?gameId=$gameId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Match.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load matches for game');
    }
  }
  Future<List<Game>> getGamesByTeam(int teamId) async {
    final response = await http.get(Uri.parse('$baseUrl/games?teamId=$teamId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Game.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load games for team');
    }
  }
  Future<Map<String, List<StandingsEntry>>> getStandings() async {
    final response = await http.get(Uri.parse('$baseUrl/standings'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data.map((region, standings) => MapEntry(
        region,
        (standings as List).map((json) => StandingsEntry.fromJson(json)).toList(),
      ));
    } else {
      throw Exception('Failed to load standings');
    }
  }
  Future<List<Team>> getTeamsList() async {
    final response = await http.get(Uri.parse('$baseUrl/teams'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Team.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load teams');
    }
  }
  Future<void> createTeam(Team team) async {
    final response = await http.post(
      Uri.parse('$baseUrl/teams'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(team.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create team');
    }
  }

  Future<void> updateTeam(Team team) async {
    final response = await http.put(
      Uri.parse('$baseUrl/teams/${team.teamUid}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(team.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update team');
    }
  }

  Future<void> deleteTeam(int teamUid) async {
    final response = await http.delete(Uri.parse('$baseUrl/teams/$teamUid'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete team');
    }
  }
  Future<void> deleteGame(int gameId) async {
    final response = await http.delete(Uri.parse('$baseUrl/games/$gameId'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete game');
    }
  }
  Future<void> createGame(Game game) async {
    final response = await http.post(
      Uri.parse('$baseUrl/games'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(game.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create game');
    }
  }
  Future<void> updateGame(Game game) async {
    final response = await http.put(
      Uri.parse('$baseUrl/games/${game.gameId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(game.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update game');
    }
  }
  Future<List<Match>> getMatches() async {
    final response = await http.get(Uri.parse('$baseUrl/matches'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Match.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }
  Future<void> createMatch(Match match) async {
    final response = await http.post(
      Uri.parse('$baseUrl/matches'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(match.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create match');
    }
  }
  Future<void> updateMatch(Match match) async {
    final response = await http.put(
      Uri.parse('$baseUrl/matches/${match.matchId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(match.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update match');
    }
  }

  Future<void> deleteMatch(int matchId) async {
    final response = await http.delete(Uri.parse('$baseUrl/matches/$matchId'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete match');
    }
  }
  Future<List<Player>> getPlayersList() async {
    final response = await http.get(Uri.parse('$baseUrl/players'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Player.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load players');
    }
  }

  Future<void> createPlayer(Player player) async {
    final response = await http.post(
      Uri.parse('$baseUrl/players'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(player.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create player');
    }
  }

  Future<void> updatePlayer(Player player) async {
    final response = await http.put(
      Uri.parse('$baseUrl/players/${player.playerUid}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(player.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update player');
    }
  }
  Future<void> deletePlayer(int playerUid) async {
    final response = await http.delete(Uri.parse('$baseUrl/players/$playerUid'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete player');
    }
  }
  Future<List<Broadcast>> fetchBroadcasts({required bool isLive}) async {
    final response = await http.get(Uri.parse('$baseUrl/broadcasts'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Broadcast.fromJson(json)).where((broadcast) => broadcast.isLive == isLive).toList();
    } else {
      throw Exception('Failed to load broadcasts');
    }
  }
}
