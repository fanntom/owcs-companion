import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../services/api_service.dart';

class GameDetailScreen extends StatefulWidget {
  final Game game;

  GameDetailScreen({required this.game});

  @override
  _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  late Future<List<Match>> _matchesFuture;
  late Future<Map<int, Team>> _teamsFuture;
  final ApiService _apiService = ApiService();
  int team1Wins = 0;
  int team2Wins = 0;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _apiService.getMatchesByGame(widget.game.gameId);
    _teamsFuture = _apiService.getTeams();
  }

  void _calculateScores(List<Match> matches) {
    team1Wins = matches.where((match) => match.matchScore1 > match.matchScore2).length;
    team2Wins = matches.where((match) => match.matchScore2 > match.matchScore1).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<int, Team>>(
          future: _teamsFuture,
          builder: (context, teamSnapshot) {
            if (teamSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (teamSnapshot.hasError) {
              return Center(child: Text('Error: ${teamSnapshot.error}'));
            } else if (!teamSnapshot.hasData || teamSnapshot.data!.isEmpty) {
              return Center(child: Text('No teams found.'));
            } else {
              final teamMap = teamSnapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${teamMap[widget.game.team1]?.teamName ?? widget.game.team1} vs ${teamMap[widget.game.team2]?.teamName ?? widget.game.team2}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Start Time: ${widget.game.startTime}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'End Time: ${widget.game.endTime ?? "Not Ended"}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'In Progress: ${widget.game.isInProgress ? "Yes" : "No"}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16.0),
                  FutureBuilder<List<Match>>(
                    future: _matchesFuture,
                    builder: (context, matchSnapshot) {
                      if (matchSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (matchSnapshot.hasError) {
                        return Center(child: Text('Error: ${matchSnapshot.error}'));
                      } else if (!matchSnapshot.hasData || matchSnapshot.data!.isEmpty) {
                        return Center(child: Text('No matches found.'));
                      } else {
                        final matches = matchSnapshot.data!;
                        print('Matches Retrieved: ${matches.length}');
                        for (var match in matches) {
                          print('Match: ${match.matchId}, Team 1: ${match.team1}, Team 2: ${match.team2}, Score: ${match.matchScore1}-${match.matchScore2}');
                        }
                        _calculateScores(matches);
                        return Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Score: ${teamMap[widget.game.team1]?.teamName ?? widget.game.team1} $team1Wins - $team2Wins ${teamMap[widget.game.team2]?.teamName ?? widget.game.team2}',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16.0),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: matches.length,
                                  itemBuilder: (context, index) {
                                    final match = matches[index];
                                    return ListTile(
                                      title: Text('Match ${match.matchId}'),
                                      subtitle: Text(
                                        'Map: ${match.mapId.name}\n'
                                        '${teamMap[match.team1]?.teamName ?? match.team1} ${match.matchScore1} - ${match.matchScore2} ${teamMap[match.team2]?.teamName ?? match.team2}\n'
                                        'Time: ${match.matchTime}',
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
