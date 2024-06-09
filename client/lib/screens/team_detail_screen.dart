import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../services/api_service.dart';
import 'player_detail_screen.dart';
import 'game_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeamDetailScreen extends StatefulWidget {
  final Team team;
  final String userId;

  TeamDetailScreen({required this.team, required this.userId});

  @override
  _TeamDetailScreenState createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _rosterKey = GlobalKey();
  late Future<List<Player>> _playersFuture;
  late Future<List<Game>> _gamesFuture;
  late Future<Map<int, Team>> _teamsFuture;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _playersFuture = _apiService.getPlayersByTeam(widget.team.teamUid);
    _gamesFuture = _apiService.getGamesByTeam(widget.team.teamUid);
    _teamsFuture = _apiService.getTeams();
    _checkBookmarkStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToRoster());
  }

  Future<void> _scrollToRoster() async {
    final context = _rosterKey.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(context, duration: Duration(milliseconds: 500));
    }
  }

  Future<void> _checkBookmarkStatus() async {
    try {
      final bookmarked = await _apiService.isTeamBookmarked(widget.team.teamUid, widget.userId);
      setState(() {
        _isBookmarked = bookmarked;
      });
    } catch (e) {
      print('Error checking bookmark status: $e');
    }
  }

  Future<void> _toggleBookmark(BuildContext context) async {
    try {
      if (_isBookmarked) {
        await _apiService.removeBookmarkTeam(widget.team.teamUid, widget.userId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bookmark removed')),
        );
      } else {
        await _apiService.bookmarkTeam(widget.team.teamUid, widget.userId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Team bookmarked')),
        );
      }
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle bookmark')),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team.teamName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: widget.team.teamLogo,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Image.asset('assets/default_team.png'),
            ),
            SizedBox(height: 16.0),
            Text(
              widget.team.teamName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Region: ${widget.team.region}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () => _toggleBookmark(context),
                child: Text(_isBookmarked ? 'Remove Bookmark' : 'Bookmark Team'),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Roster:',
              key: _rosterKey,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            FutureBuilder<List<Player>>(
              future: _playersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No players found.'));
                } else {
                  final players = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: player.playerLogo,
                          width: 50,
                          height: 50,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Image.asset('assets/default_player.png'),
                        ),
                        title: Text('${player.position.toUpperCase()}: ${player.playertag}'),
                        subtitle: Text(player.realname),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PlayerDetailScreen(
                              player: player,
                              team: widget.team,
                              userId: widget.userId,
                            ),
                          ));
                        },
                      );
                    },
                  );
                }
              },
            ),
            SizedBox(height: 16.0),
            Text(
              'Games:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            FutureBuilder<List<Game>>(
              future: _gamesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No games found.'));
                } else {
                  final games = snapshot.data!;
                  return FutureBuilder<Map<int, Team>>(
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
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            final game = games[index];
                            final opponentTeam = game.team1 == widget.team.teamUid
                                ? teamMap[game.team2]?.teamName ?? 'Unknown'
                                : teamMap[game.team1]?.teamName ?? 'Unknown';
                            final teamScore = game.matches?.where((match) =>
                                  (match.team1 == widget.team.teamUid && match.matchScore1 > match.matchScore2) ||
                                  (match.team2 == widget.team.teamUid && match.matchScore2 > match.matchScore1)).length ?? 0;
                            final opponentScore = (game.matches?.length ?? 0) - teamScore;
                            return ListTile(
                              title: Text('vs $opponentTeam'),
                              subtitle: Text('${_formatDateTime(game.startTime)} - ${game.endTime != null ? _formatDateTime(game.endTime!) : 'Not Ended'}\nScore: $teamScore - $opponentScore'),
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
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
