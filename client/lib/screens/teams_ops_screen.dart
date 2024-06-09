import 'package:flutter/material.dart';
import '../models/team.dart';
import '../services/api_service.dart';
import 'edit_team_screen.dart';
import 'create_team_screen.dart';

class TeamsOpsScreen extends StatefulWidget {
  @override
  _TeamsOpsScreenState createState() => _TeamsOpsScreenState();
}

class _TeamsOpsScreenState extends State<TeamsOpsScreen> {
  late Future<List<Team>> _teamsFuture;
  final ApiService _apiService = ApiService();
  String _searchQuery = '';
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _teamsFuture = _apiService.getTeamsList();
  }

  void _sort<T>(Comparable<T> Function(Team team) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _teamsFuture = _teamsFuture.then((teams) {
        teams.sort((a, b) {
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
        return teams;
      });
    });
  }

  void _deleteTeam(Team team) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Team'),
        content: Text('Are you sure you want to delete this team?'),
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
      await _apiService.deleteTeam(team.teamUid);
      setState(() {
        _teamsFuture = _apiService.getTeamsList();
      });
    }
  }

  void _editTeam(Team team) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditTeamScreen(team: team),
    ));
    setState(() {
      _teamsFuture = _apiService.getTeamsList();
    });
  }

  void _showOptions(Team team) {
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
                _editTeam(team);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Navigator.of(context).pop();
                _deleteTeam(team);
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
        title: Text('Teams Operations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CreateTeamScreen(),
                )).then((_) {
                  setState(() {
                    _teamsFuture = _apiService.getTeamsList();
                  });
                });
              },
              child: Text('Create Team'),
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
              child: FutureBuilder<List<Team>>(
                future: _teamsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No teams found.'));
                  } else {
                    final teams = snapshot.data!.where((team) {
                      return team.teamName.toLowerCase().contains(_searchQuery.toLowerCase());
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
                              label: Text('Team ID'),
                              onSort: (columnIndex, ascending) => _sort<num>((team) => team.teamUid, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Team Name'),
                              onSort: (columnIndex, ascending) => _sort<String>((team) => team.teamName, columnIndex, ascending),
                            ),
                            DataColumn(
                              label: Text('Region'),
                              onSort: (columnIndex, ascending) => _sort<String>((team) => team.region, columnIndex, ascending),
                            ),
                          ],
                          rows: teams.map((team) {
                            return DataRow(cells: [
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.more_vert),
                                  onPressed: () => _showOptions(team),
                                ),
                              ),
                              DataCell(Text(team.teamUid.toString())),
                              DataCell(Text(team.teamName)),
                              DataCell(Text(team.region)),
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
