import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../models/game.dart';
import '../services/api_service.dart';
import 'edit_match_screen.dart';
import 'create_match_screen.dart';

class MatchesOpsScreen extends StatefulWidget {
  final Map<int, Team> teamsMap;
  final Map<int, Game> gamesMap;

  MatchesOpsScreen({required this.teamsMap, required this.gamesMap});

  @override
  _MatchesOpsScreenState createState() => _MatchesOpsScreenState();
}

class _MatchesOpsScreenState extends State<MatchesOpsScreen> {
  late Future<List<Match>> _matchesFuture;
  final ApiService _apiService = ApiService();
  String _searchQuery = '';
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _apiService.getMatches();
  }

  void _sort<T>(Comparable<T> Function(Match match) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _matchesFuture = _matchesFuture.then((matches) {
        matches.sort((a, b) {
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
        return matches;
      });
    });
  }

  void _deleteMatch(Match match) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Match'),
        content: Text('Are you sure you want to delete this match?'),
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
      await _apiService.deleteMatch(match.matchId);
      setState(() {
        _matchesFuture = _apiService.getMatches();
      });
    }
  }

  void _editMatch(Match match) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditMatchScreen(match: match, teamsMap: widget.teamsMap, gamesMap: widget.gamesMap),
    ));
    setState(() {
      _matchesFuture = _apiService.getMatches();
    });
  }

  void _showOptions(Match match) {
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
                _editMatch(match);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Navigator.of(context).pop();
                _deleteMatch(match);
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
        title: Text('Matches Operations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CreateMatchScreen(teamsMap: widget.teamsMap, gamesMap: widget.gamesMap),
                )).then((_) {
                  setState(() {
                    _matchesFuture = _apiService.getMatches();
                  });
                });
              },
              child: Text('Create Match'),
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
              child: FutureBuilder<List<Match>>(
                future: _matchesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No matches found.'));
                  } else {
                    final matches = snapshot.data!.where((match) {
                      final team1Name = widget.teamsMap[match.team1]!.teamName.toLowerCase();
                      final team2Name = widget.teamsMap[match.team2]!.teamName.toLowerCase();
                      return team1Name.contains(_searchQuery.toLowerCase()) ||
                          team2Name.contains(_searchQuery.toLowerCase());
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
                              label: Text('Match ID'),
                              onSort: (columnIndex, ascending) => _sort<num>((match) => match.matchId, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Team 1'),
                              onSort: (columnIndex, ascending) => _sort<String>((match) => widget.teamsMap[match.team1]!.teamName, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Team 2'),
                              onSort: (columnIndex, ascending) => _sort<String>((match) => widget.teamsMap[match.team2]!.teamName, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Score 1'),
                              onSort: (columnIndex, ascending) => _sort<num>((match) => match.matchScore1, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Score 2'),
                              onSort: (columnIndex, ascending) => _sort<num>((match) => match.matchScore2, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Match Time'),
                              onSort: (columnIndex, ascending) => _sort<DateTime>((match) => match.matchTime, columnIndex, ascending),
                            ),
                          ],
                          rows: matches.map((match) {
                            return DataRow(cells: [
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.more_vert),
                                  onPressed: () => _showOptions(match),
                                ),
                              ),
                              DataCell(Text(match.matchId.toString())),
                              DataCell(Text(widget.teamsMap[match.team1]!.teamName)),
                              DataCell(Text(widget.teamsMap[match.team2]!.teamName)),
                              DataCell(Text(match.matchScore1.toString())),
                              DataCell(Text(match.matchScore2.toString())),
                              DataCell(Text(match.matchTime.toString())),
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
