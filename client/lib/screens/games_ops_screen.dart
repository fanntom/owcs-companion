import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/team.dart';
import '../services/api_service.dart';
import 'edit_game_screen.dart';
import 'create_game_screen.dart';

class GamesOpsScreen extends StatefulWidget {
  final Map<int, Team> teamsMap;

  GamesOpsScreen({required this.teamsMap});

  @override
  _GamesOpsScreenState createState() => _GamesOpsScreenState();
}

class _GamesOpsScreenState extends State<GamesOpsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Game>> _gamesFuture;
  String _searchQuery = '';
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _gamesFuture = _apiService.getGames(status: 'all');
  }

  void _sort<T>(Comparable<T> Function(Game game) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _gamesFuture = _gamesFuture.then((games) {
        games.sort((a, b) {
          final aValue = getField(a);
          final bValue = getField(b);
          if (aValue == null && bValue == null) {
            return 0;
          } else if (aValue == null) {
            return ascending ? -1 : 1;
          } else if (bValue == null) {
            return ascending ? 1 : -1;
          } else {
            return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
          }
        });
        return games;
      });
    });
  }

  void _deleteGame(Game game) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Game'),
        content: Text('Are you sure you want to delete this game and its matches?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _apiService.deleteGame(game.gameId);
      setState(() {
        _gamesFuture = _apiService.getGames(status: 'all');
      });
    }
  }

  void _editGame(Game game) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditGameScreen(game: game, teamsMap: widget.teamsMap),
    ));
    setState(() {
      _gamesFuture = _apiService.getGames(status: 'all');
    });
  }

  void _showOptions(Game game) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              onTap: () {
                Navigator.of(context).pop();
                _editGame(game);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Navigator.of(context).pop();
                _deleteGame(game);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Games Operations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CreateGameScreen(teamsMap: widget.teamsMap),
                )).then((_) {
                  setState(() {
                    _gamesFuture = _apiService.getGames(status: 'all');
                  });
                });
              },
              child: Text('Create Game'),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<Game>>(
                future: _gamesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No games found.'));
                  } else {
                    final games = snapshot.data!.where((game) {
                      final team1Name = widget.teamsMap[game.team1]?.teamName.toLowerCase() ?? '';
                      final team2Name = widget.teamsMap[game.team2]?.teamName.toLowerCase() ?? '';
                      return team1Name.contains(_searchQuery.toLowerCase()) || team2Name.contains(_searchQuery.toLowerCase());
                    }).toList();

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          sortColumnIndex: _sortColumnIndex,
                          sortAscending: _sortAscending,
                          columns: [
                            DataColumn(
                              label: Text('Actions'),
                            ),
                            DataColumn(
                              label: Text('Game ID'),
                              onSort: (columnIndex, ascending) => _sort<num>((game) => game.gameId, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Team 1'),
                              onSort: (columnIndex, ascending) => _sort<String>((game) => widget.teamsMap[game.team1]?.teamName ?? '', columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Team 2'),
                              onSort: (columnIndex, ascending) => _sort<String>((game) => widget.teamsMap[game.team2]?.teamName ?? '', columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Start Time'),
                              onSort: (columnIndex, ascending) => _sort<DateTime>((game) => game.startTime, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('End Time'),
                              onSort: (columnIndex, ascending) => _sort<DateTime?>((game) => game.endTime ?? DateTime(0), columnIndex, ascending),
                            ),
                          ],
                          rows: games.map((game) {
                            return DataRow(cells: [
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.more_vert),
                                  onPressed: () => _showOptions(game),
                                ),
                              ),
                              DataCell(Text(game.gameId.toString())),
                              DataCell(Text(widget.teamsMap[game.team1]?.teamName ?? game.team1.toString())),
                              DataCell(Text(widget.teamsMap[game.team2]?.teamName ?? game.team2.toString())),
                              DataCell(Text(game.startTime.toString())),
                              DataCell(Text(game.endTime?.toString() ?? 'N/A')),
                            ]);
                          }).toList(),
                        ),
                      ),
                    );
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
