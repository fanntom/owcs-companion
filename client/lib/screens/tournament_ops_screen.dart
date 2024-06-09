import 'package:flutter/material.dart';
import 'games_ops_screen.dart';
import 'matches_ops_screen.dart';
import 'teams_ops_screen.dart';
import 'players_ops_screen.dart';
import '../models/team.dart';
import '../models/game.dart';
import '../services/api_service.dart';

class TournamentOpsScreen extends StatefulWidget {
  @override
  _TournamentOpsScreenState createState() => _TournamentOpsScreenState();
}

class _TournamentOpsScreenState extends State<TournamentOpsScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<int, Team>> _teamsFuture;
  late Future<Map<int, Game>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    _teamsFuture = _apiService.getTeams();
    _gamesFuture = _apiService.getGames(status: 'all').then(
      (gamesList) => {for (var game in gamesList) game.gameId: game},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tournament Operations'),
      ),
      body: FutureBuilder<Map<int, Team>>(
        future: _teamsFuture,
        builder: (context, teamSnapshot) {
          if (teamSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (teamSnapshot.hasError) {
            return Center(child: Text('Error: ${teamSnapshot.error}'));
          } else if (!teamSnapshot.hasData || teamSnapshot.data!.isEmpty) {
            return Center(child: Text('No teams found.'));
          } else {
            final teamsMap = teamSnapshot.data!;
            return FutureBuilder<Map<int, Game>>(
              future: _gamesFuture,
              builder: (context, gameSnapshot) {
                if (gameSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (gameSnapshot.hasError) {
                  return Center(child: Text('Error: ${gameSnapshot.error}'));
                } else if (!gameSnapshot.hasData || gameSnapshot.data!.isEmpty) {
                  return Center(child: Text('No games found.'));
                } else {
                  final gamesMap = gameSnapshot.data!;
                  return ListView(
                    children: [
                      ListTile(
                        title: Text('Games'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => GamesOpsScreen(teamsMap: teamsMap),
                          ));
                        },
                      ),
                      ListTile(
                        title: Text('Matches'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MatchesOpsScreen(teamsMap: teamsMap, gamesMap: gamesMap),
                          ));
                        },
                      ),
                      ListTile(
                        title: Text('Teams'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TeamsOpsScreen(),
                          ));
                        },
                      ),
                      ListTile(
                        title: Text('Players'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PlayersOpsScreen(teamsMap: teamsMap),
                          ));
                        },
                      ),
                    ],
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
