import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../services/api_service.dart';
import 'edit_player_screen.dart';
import 'create_player_screen.dart';

class PlayersOpsScreen extends StatefulWidget {
  final Map<int, Team> teamsMap;

  PlayersOpsScreen({required this.teamsMap});

  @override
  _PlayersOpsScreenState createState() => _PlayersOpsScreenState();
}

class _PlayersOpsScreenState extends State<PlayersOpsScreen> {
  late Future<List<Player>> _playersFuture;
  final ApiService _apiService = ApiService();
  String _searchQuery = '';
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _playersFuture = _apiService.getPlayersList();
  }

  void _sort<T>(Comparable<T> Function(Player player) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _playersFuture = _playersFuture.then((players) {
        players.sort((a, b) {
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
        return players;
      });
    });
  }

  void _sortBoolean(bool Function(Player player) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _playersFuture = _playersFuture.then((players) {
        players.sort((a, b) {
          final aValue = getField(a);
          final bValue = getField(b);
          if (aValue == bValue) {
            return 0;
          } else if (!aValue && bValue) {
            return ascending ? -1 : 1;
          } else {
            return ascending ? 1 : -1;
          }
        });
        return players;
      });
    });
  }

  void _deletePlayer(Player player) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Player'),
        content: Text('Are you sure you want to delete this player?'),
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
      await _apiService.deletePlayer(player.playerUid);
      setState(() {
        _playersFuture = _apiService.getPlayersList();
      });
    }
  }

  void _editPlayer(Player player) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditPlayerScreen(player: player, teamsMap: widget.teamsMap),
    ));
    setState(() {
      _playersFuture = _apiService.getPlayersList();
    });
  }

  void _showOptions(Player player) {
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
                _editPlayer(player);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Navigator.of(context).pop();
                _deletePlayer(player);
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
        title: Text('Players Operations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CreatePlayerScreen(teamsMap: widget.teamsMap),
                )).then((_) {
                  setState(() {
                    _playersFuture = _apiService.getPlayersList();
                  });
                });
              },
              child: Text('Create Player'),
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
              child: FutureBuilder<List<Player>>(
                future: _playersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No players found.'));
                  } else {
                    final players = snapshot.data!.where((player) {
                      return player.playertag.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                             player.realname.toLowerCase().contains(_searchQuery.toLowerCase());
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
                              label: Text('Player ID'),
                              onSort: (columnIndex, ascending) => _sort<num>((player) => player.playerUid, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Player Tag'),
                              onSort: (columnIndex, ascending) => _sort<String>((player) => player.playertag, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Real Name'),
                              onSort: (columnIndex, ascending) => _sort<String>((player) => player.realname, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Current Team'),
                              onSort: (columnIndex, ascending) => _sort<String>((player) => widget.teamsMap[player.currentTeamId]!.teamName, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Position'),
                              onSort: (columnIndex, ascending) => _sort<String>((player) => player.position, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Region'),
                              onSort: (columnIndex, ascending) => _sort<String>((player) => player.region, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Active'),
                              onSort: (columnIndex, ascending) => _sortBoolean((player) => player.isActive, columnIndex, ascending),
                            ),
                          ],
                          rows: players.map((player) {
                            return DataRow(cells: [
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.more_vert),
                                  onPressed: () => _showOptions(player),
                                ),
                              ),
                              DataCell(Text(player.playerUid.toString())),
                              DataCell(Text(player.playertag)),
                              DataCell(Text(player.realname)),
                              DataCell(Text(widget.teamsMap[player.currentTeamId]!.teamName)),
                              DataCell(Text(player.position)),
                              DataCell(Text(player.region)),
                              DataCell(Text(player.isActive ? 'Yes' : 'No')),
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
