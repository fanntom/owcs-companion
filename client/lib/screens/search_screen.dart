import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'team_detail_screen.dart';
import 'player_detail_screen.dart';
import '../models/team.dart';
import '../models/player.dart';

class SearchScreen extends StatefulWidget {
  final String userId;

  SearchScreen({required this.userId});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  Map<int, Team> _teamsById = {};

  Future<void> _performSearch() async {
    final query = _searchController.text;
    final teamResults = await _searchTeams(query);
    final playerResults = await _searchPlayers(query);

    // Fetch all teams to ensure the team map is comprehensive
    final allTeams = await _fetchAllTeams();
    final teamMap = <int, Team>{for (var team in allTeams) team.teamUid: team};

    setState(() {
      _searchResults = [...teamResults, ...playerResults];
      _teamsById = teamMap;
    });
  }

  Future<List<Team>> _fetchAllTeams() async {
    final response = await http.get(Uri.parse('http://172.30.1.22:8080/teams'));
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).map((json) => Team.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load all teams');
    }
  }

  Future<List<Team>> _searchTeams(String query) async {
    final response = await http.get(Uri.parse('http://172.30.1.22:8080/teams?search=$query'));
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).map((json) => Team.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load teams');
    }
  }

  Future<List<Player>> _searchPlayers(String query) async {
    final response = await http.get(Uri.parse('http://172.30.1.22:8080/players?search=$query'));
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).map((json) => Player.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load players');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Teams and Players',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _performSearch,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  if (result is Team) {
                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: result.teamLogo,
                        width: 50,
                        height: 50,
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Image.asset('assets/default_team.png'),
                      ),
                      title: Text(result.teamName),
                      subtitle: Text(result.region),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TeamDetailScreen(team: result, userId: widget.userId),
                        ));
                      },
                    );
                  } else if (result is Player) {
                    final team = _teamsById[result.currentTeamId];
                    print(result.currentTeamId);
                    print(team?.teamName);
                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: result.playerLogo,
                        width: 50,
                        height: 50,
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Image.asset('assets/default_player.png'),
                      ),
                      title: Text('${result.playertag} (${result.realname})'),
                      subtitle: Text('${result.region} - ${team?.teamName ?? 'No Team'}'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PlayerDetailScreen(player: result, team: team, userId: widget.userId),
                        ));
                      },
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
