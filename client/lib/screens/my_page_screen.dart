import 'package:flutter/material.dart';
import 'package:openid_client/openid_client.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../services/api_service.dart';
import 'player_detail_screen.dart';
import 'team_detail_screen.dart';

class MyPageScreen extends StatefulWidget {
  final UserInfo userInfo;
  final Future<void> Function() onSignOut;

  MyPageScreen({required this.userInfo, required this.onSignOut});

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Player>> _bookmarkedPlayers;
  late Future<List<Team>> _bookmarkedTeams;

  @override
  void initState() {
    super.initState();
    _bookmarkedPlayers = _apiService.getBookmarkedPlayers(widget.userInfo.email!);
    _bookmarkedTeams = _apiService.getBookmarkedTeams(widget.userInfo.email!);
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 16.0),
          Text('Name: ${widget.userInfo.name}', style: TextStyle(fontSize: 18, color: Colors.white)),
          SizedBox(height: 8.0),
          Text('Email: ${widget.userInfo.email}', style: TextStyle(fontSize: 18, color: Colors.white)),
          SizedBox(height: 8.0),
          Text('Preferred Username: ${widget.userInfo.preferredUsername}', style: TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildBookmarksSection(String title, Future<List<dynamic>> futureList, bool isPlayer) {
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
            child: FutureBuilder<List<dynamic>>(
              future: futureList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No bookmarks found.'));
                } else {
                  final items = snapshot.data!;
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (isPlayer) {
                        final player = item as Player;
                        return ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: player.playerLogo,
                            width: 50,
                            height: 50,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Image.asset('assets/default_player.png'),
                          ),
                          title: Text(player.playertag),
                          subtitle: Text(player.realname),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PlayerDetailScreen(player: player, team: null, userId: widget.userInfo.email!),
                            ));
                          },
                        );
                      } else {
                        final team = item as Team;
                        return ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: team.teamLogo,
                            width: 50,
                            height: 50,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Image.asset('assets/default_team.png'),
                          ),
                          title: Text(team.teamName),
                          subtitle: Text(team.region),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => TeamDetailScreen(team: team, userId: widget.userInfo.email!),
                            ));
                          },
                        );
                      }
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
      appBar: AppBar(title: Text('My Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(),
            SizedBox(height: 16.0),
            _buildBookmarksSection('Bookmarked Players', _bookmarkedPlayers, true),
            SizedBox(height: 16.0),
            _buildBookmarksSection('Bookmarked Teams', _bookmarkedTeams, false),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  print('Sign out button pressed');
                  await widget.onSignOut();
                },
                child: Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
