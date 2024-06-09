import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../models/game.dart';
import '../services/api_service.dart';

class CreateMatchScreen extends StatefulWidget {
  final Map<int, Team> teamsMap;
  final Map<int, Game> gamesMap;

  CreateMatchScreen({required this.teamsMap, required this.gamesMap});

  @override
  _CreateMatchScreenState createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late int _selectedGame;
  late int _selectedTeam1;
  late int _selectedTeam2;
  late MapType _selectedMap;
  late DateTime _selectedDateTime;
  late int _matchScore1;
  late int _matchScore2;

  @override
  void initState() {
    super.initState();
    _selectedGame = widget.gamesMap.keys.first;
    _selectedTeam1 = widget.teamsMap.keys.first;
    _selectedTeam2 = widget.teamsMap.keys.first;
    _selectedMap = MapType.values.first;
    _selectedDateTime = DateTime.now();
    _matchScore1 = 0;
    _matchScore2 = 0;
  }

  Future<void> _createMatch() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newMatch = Match(
        matchId: 0,
        gameId: _selectedGame,
        team1: _selectedTeam1,
        team2: _selectedTeam2,
        matchScore1: _matchScore1,
        matchScore2: _matchScore2,
        matchTime: _selectedDateTime,
        mapId: _selectedMap,
      );
      await _apiService.createMatch(newMatch);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Match'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedGame,
                onChanged: (value) {
                  setState(() {
                    _selectedGame = value!;
                  });
                },
                items: widget.gamesMap.values.map((game) {
                  return DropdownMenuItem<int>(
                    value: game.gameId,
                    child: Text('Game ${game.gameId}'),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Game'),
                validator: (value) => value == null ? 'Please select a game' : null,
              ),
              DropdownButtonFormField<int>(
                value: _selectedTeam1,
                onChanged: (value) {
                  setState(() {
                    _selectedTeam1 = value!;
                  });
                },
                items: widget.teamsMap.values.map((team) {
                  return DropdownMenuItem<int>(
                    value: team.teamUid,
                    child: Text(team.teamName),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Team 1'),
                validator: (value) => value == null ? 'Please select a team' : null,
              ),
              DropdownButtonFormField<int>(
                value: _selectedTeam2,
                onChanged: (value) {
                  setState(() {
                    _selectedTeam2 = value!;
                  });
                },
                items: widget.teamsMap.values.map((team) {
                  return DropdownMenuItem<int>(
                    value: team.teamUid,
                    child: Text(team.teamName),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Team 2'),
                validator: (value) => value == null ? 'Please select a team' : null,
              ),
              DropdownButtonFormField<MapType>(
                value: _selectedMap,
                onChanged: (value) {
                  setState(() {
                    _selectedMap = value!;
                  });
                },
                items: MapType.values.map((mapType) {
                  return DropdownMenuItem<MapType>(
                    value: mapType,
                    child: Text(mapType.name),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Map'),
                validator: (value) => value == null ? 'Please select a map' : null,
              ),
              ListTile(
                title: Text('Match Time'),
                subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime)),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              TextFormField(
                initialValue: '0',
                decoration: InputDecoration(labelText: 'Team 1 Score'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _matchScore1 = int.parse(value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a score';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: '0',
                decoration: InputDecoration(labelText: 'Team 2 Score'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _matchScore2 = int.parse(value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a score';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _createMatch,
                child: Text('Create Match'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
