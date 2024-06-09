import 'package:flutter/material.dart';
import '../models/standings_entry.dart';
import '../services/api_service.dart';
import 'team_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StandingsScreen extends StatelessWidget {
  final ApiService _apiService = ApiService();

  Future<Map<String, List<StandingsEntry>>> _fetchStandings() async {
    return await _apiService.getStandings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Standings')),
      body: FutureBuilder<Map<String, List<StandingsEntry>>>(
        future: _fetchStandings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No standings available.'));
          } else {
            final standings = snapshot.data!;
            return ListView(
              children: standings.entries.map((entry) {
                final region = entry.key;
                final regionStandings = entry.value;
                return ExpansionTile(
                  title: Text(region, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  children: regionStandings.map((team) {
                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: team.teamLogo.isNotEmpty ? team.teamLogo : 'assets/default_team.png',
                        width: 50,
                        height: 50,
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Image.asset('assets/default_team.png'),
                      ),
                      title: Text(team.teamName),
                      subtitle: Text('Game Wins: ${team.gameWins}, Match Wins: ${team.matchWins}'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TeamDetailScreen(team: team.toTeam(), userId: 'userId'),
                        ));
                      },
                    );
                  }).toList(),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
