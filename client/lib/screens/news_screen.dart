import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/team.dart';
import '../services/api_service.dart';
import 'game_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Game>> _upcomingGames;
  late Future<List<Game>> _currentGames;
  late Future<List<Game>> _previousGames;
  late Future<Map<int, Team>> _teams;

  @override
  void initState() {
    super.initState();
    _teams = _apiService.getTeams();
    _upcomingGames = _apiService.getGames(status: 'upcoming');
    _currentGames = _apiService.getGames(status: 'current');
    _previousGames = _apiService.getGames(status: 'previous');
  }

  Widget _buildGameList(String title, Future<List<Game>> futureGames, Map<int, Team> teams) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: FutureBuilder<List<Game>>(
              future: futureGames,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No games found.'));
                } else {
                  final games = snapshot.data!;
                  return ListView.builder(
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      final team1 = teams[game.team1]?.teamName ?? 'Unknown';
                      final team2 = teams[game.team2]?.teamName ?? 'Unknown';
                      return ListTile(
                        title: Text('Game ${game.gameId}'),
                        subtitle: Text(
                          '$team1 vs $team2\n${game.startTime} - ${game.isInProgress ? 'In Progress' : 'Not Started'}',
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => GameDetailScreen(game: game),
                          ));
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('News')),
      body: FutureBuilder<Map<int, Team>>(
        future: _teams,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Failed to load teams.'));
          } else {
            final teams = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGameList('Upcoming Games', _upcomingGames, teams),
                  SizedBox(height: 16.0),
                  _buildGameList('Current Games', _currentGames, teams),
                  SizedBox(height: 16.0),
                  _buildGameList('Previous Games', _previousGames, teams),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
