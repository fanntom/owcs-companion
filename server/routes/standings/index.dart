import 'package:dart_frog/dart_frog.dart';
import '../../lib/database.dart';

class StandingsEntry {
  final int teamId;
  final String teamName;
  final String region;
  int gameWins = 0;
  int matchWins = 0;

  StandingsEntry(this.teamId, this.teamName, this.region);

  void addGameWin() {
    gameWins++;
  }

  void addMatchWin() {
    matchWins++;
  }

  Map<String, dynamic> toJson() => {
    'teamId': teamId,
    'teamName': teamName,
    'region': region,
    'gameWins': gameWins,
    'matchWins': matchWins,
  };
}

Future<Response> onRequest(RequestContext context) async {
  try {
    final teamsResult = await db.connection.query('SELECT team_uid, team_name, region FROM teams');
    final gamesResult = await db.connection.query('SELECT game_id, team1, team2 FROM games');
    final matchesResult = await db.connection.query('SELECT team1, team2, match_score1, match_score2, game_id FROM matches');

    final standings = <int, StandingsEntry>{};
    
    for (final row in teamsResult) {
      final teamId = row[0] as int;
      final teamName = row[1] as String;
      final region = row[2] as String;
      standings[teamId] = StandingsEntry(teamId, teamName, region);
    }

    // Calculate game wins
    for (final gameRow in gamesResult) {
      final gameId = gameRow[0] as int;
      final team1 = gameRow[1] as int;
      final team2 = gameRow[2] as int;
      var team1MatchWins = 0;
      var team2MatchWins = 0;

      for (final matchRow in matchesResult.where((match) => match[4] == gameId)) {
        final matchTeam1 = matchRow[0] as int;
        final matchTeam2 = matchRow[1] as int;
        final matchScore1 = matchRow[2] as int;
        final matchScore2 = matchRow[3] as int;

        if (matchScore1 > matchScore2) {
          standings[matchTeam1]?.addMatchWin();
          if (matchTeam1 == team1) team1MatchWins++;
          if (matchTeam1 == team2) team2MatchWins++;
        } else if (matchScore2 > matchScore1) {
          standings[matchTeam2]?.addMatchWin();
          if (matchTeam2 == team1) team1MatchWins++;
          if (matchTeam2 == team2) team2MatchWins++;
        }
      }

      if (team1MatchWins > team2MatchWins) {
        standings[team1]?.addGameWin();
      } else if (team2MatchWins > team1MatchWins) {
        standings[team2]?.addGameWin();
      }
    }

    // Group by region and sort
    final regionStandings = <String, List<StandingsEntry>>{};
    standings.values.forEach((entry) {
      regionStandings.putIfAbsent(entry.region, () => []).add(entry);
    });

    for (var entries in regionStandings.values) {
      entries.sort((a, b) {
        if (a.gameWins != b.gameWins) {
          return b.gameWins.compareTo(a.gameWins);
        } else {
          return b.matchWins.compareTo(a.matchWins);
        }
      });
    }

    return Response.json(body: regionStandings);
  } catch (e) {
    print('Error: $e');
    return Response(statusCode: 500, body: 'Internal Server Error');
  }
}
