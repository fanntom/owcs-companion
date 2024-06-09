import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../models/game.dart';
import '../services/api_service.dart';

class EditMatchScreen extends StatefulWidget {
  final Match match;
  final Map<int, Team> teamsMap;
  final Map<int, Game> gamesMap;

  EditMatchScreen({required this.match, required this.teamsMap, required this.gamesMap});

  @override
  _EditMatchScreenState createState() => _EditMatchScreenState();
}

class _EditMatchScreenState extends State<EditMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  late int _team1;
  late int _team2;
  late int _gameId;
  late String _mapId;
  late int _matchScore1;
  late int _matchScore2;
  late DateTime _matchTime;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _team1 = widget.match.team1;
    _team2 = widget.match.team2;
    _gameId = widget.match.gameId;
    _mapId = widget.match.mapId.name;
    _matchScore1 = widget.match.matchScore1;
    _matchScore2 = widget.match.matchScore2;
    _matchTime = widget.match.matchTime;
  }

  Future<void> _updateMatch() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedMatch = Match(
        matchId: widget.match.matchId,
        mapId: MapType.values.firstWhere((e) => e.name == _mapId),
        team1: _team1,
        team2: _team2,
        matchScore1: _matchScore1,
        matchScore2: _matchScore2,
        matchTime: _matchTime,
        gameId: _gameId,
      );
      await _apiService.updateMatch(updatedMatch);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Match'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _team1,
                decoration: InputDecoration(labelText: 'Team 1'),
                items: widget.teamsMap.values
                    .map((team) => DropdownMenuItem(
                          value: team.teamUid,
                          child: Text(team.teamName),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _team1 = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select a team' : null,
              ),
              DropdownButtonFormField<int>(
                value: _team2,
                decoration: InputDecoration(labelText: 'Team 2'),
                items: widget.teamsMap.values
                    .map((team) => DropdownMenuItem(
                          value: team.teamUid,
                          child: Text(team.teamName),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _team2 = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select a team' : null,
              ),
              DropdownButtonFormField<int>(
                value: _gameId,
                decoration: InputDecoration(labelText: 'Game ID'),
                items: widget.gamesMap.values
                    .map((game) => DropdownMenuItem(
                          value: game.gameId,
                          child: Text('Game ${game.gameId}'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gameId = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select a game' : null,
              ),
              DropdownButtonFormField<String>(
                value: _mapId,
                decoration: InputDecoration(labelText: 'Map'),
                items: MapType.values
                    .map((mapType) => DropdownMenuItem(
                          value: mapType.name,
                          child: Text(mapType.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _mapId = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select a map' : null,
              ),
              TextFormField(
                initialValue: _matchScore1.toString(),
                decoration: InputDecoration(labelText: 'Match Score 1'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _matchScore1 = int.parse(value!);
                },
                validator: (value) => value == null || value.isEmpty ? 'Please enter a score' : null,
              ),
              TextFormField(
                initialValue: _matchScore2.toString(),
                decoration: InputDecoration(labelText: 'Match Score 2'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _matchScore2 = int.parse(value!);
                },
                validator: (value) => value == null || value.isEmpty ? 'Please enter a score' : null,
              ),
              TextFormField(
                initialValue: _matchTime.toIso8601String(),
                decoration: InputDecoration(labelText: 'Match Time'),
                keyboardType: TextInputType.datetime,
                onSaved: (value) {
                  _matchTime = DateTime.parse(value!);
                },
                validator: (value) => value == null || value.isEmpty ? 'Please enter a date' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateMatch,
                child: Text('Update Match'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
