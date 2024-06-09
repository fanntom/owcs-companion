import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/game.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class CreateGameScreen extends StatefulWidget {
  final Map<int, Team> teamsMap;

  CreateGameScreen({required this.teamsMap});

  @override
  _CreateGameScreenState createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late int _team1;
  late int _team2;
  late DateTime _startTime;
  late DateTime? _endTime;
  bool _isInProgress = false;

  @override
  void initState() {
    super.initState();
    _team1 = widget.teamsMap.keys.first;
    _team2 = widget.teamsMap.keys.first;
    _startTime = DateTime.now();
    _endTime = null;
  }

  Future<void> _createGame() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newGame = Game(
        gameId: 0,
        team1: _team1,
        team2: _team2,
        startTime: _startTime,
        endTime: _endTime,
        isInProgress: _isInProgress,
        matches: [],
      );
      await _apiService.createGame(newGame);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _team1,
                onChanged: (value) {
                  setState(() {
                    _team1 = value!;
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
                value: _team2,
                onChanged: (value) {
                  setState(() {
                    _team2 = value!;
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
              ListTile(
                title: Text('Start Time'),
                subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(_startTime)),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _startTime,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_startTime),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        _startTime = DateTime(
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
              ListTile(
                title: Text('End Time'),
                subtitle: Text(_endTime != null
                    ? DateFormat('yyyy-MM-dd HH:mm').format(_endTime!)
                    : 'N/A'),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _endTime ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_endTime ?? DateTime.now()),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        _endTime = DateTime(
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
              SwitchListTile(
                title: Text('In Progress'),
                value: _isInProgress,
                onChanged: (value) {
                  setState(() {
                    _isInProgress = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _createGame,
                child: Text('Create Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
