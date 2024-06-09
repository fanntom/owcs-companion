import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/game.dart';
import '../models/team.dart';
import '../services/api_service.dart';

class EditGameScreen extends StatefulWidget {
  final Game game;
  final Map<int, Team> teamsMap;

  EditGameScreen({required this.game, required this.teamsMap});

  @override
  _EditGameScreenState createState() => _EditGameScreenState();
}

class _EditGameScreenState extends State<EditGameScreen> {
  final ApiService _apiService = ApiService();
  late Game _game;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  @override
  void initState() {
    super.initState();
    _game = widget.game;
    _startTimeController = TextEditingController(text: DateFormat('yyyy-MM-ddTHH:mm').format(_game.startTime));
    _endTimeController = TextEditingController(text: _game.endTime != null ? DateFormat('yyyy-MM-ddTHH:mm').format(_game.endTime!) : '');
  }

  Future<void> _updateGame() async {
    setState(() {
      _game.startTime = DateTime.parse(_startTimeController.text);
      _game.endTime = _endTimeController.text.isNotEmpty ? DateTime.parse(_endTimeController.text) : null;
    });

    try {
      await _apiService.updateGame(_game);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Game updated successfully')),
      );
      Navigator.of(context).pop(_game);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update game: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _game.team1,
              onChanged: (value) {
                setState(() {
                  _game.team1 = value!;
                });
              },
              items: widget.teamsMap.entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value.teamName),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Team 1'),
            ),
            DropdownButtonFormField<int>(
              value: _game.team2,
              onChanged: (value) {
                setState(() {
                  _game.team2 = value!;
                });
              },
              items: widget.teamsMap.entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value.teamName),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Team 2'),
            ),
            TextFormField(
              controller: _startTimeController,
              decoration: InputDecoration(labelText: 'Start Time'),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                final date = await showDatePicker(
                  context: context,
                  initialDate: _game.startTime,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_game.startTime),
                  );
                  if (time != null) {
                    setState(() {
                      _game.startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      _startTimeController.text = DateFormat('yyyy-MM-ddTHH:mm').format(_game.startTime);
                    });
                  }
                }
              },
            ),
            TextFormField(
              controller: _endTimeController,
              decoration: InputDecoration(labelText: 'End Time'),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                final date = await showDatePicker(
                  context: context,
                  initialDate: _game.endTime ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_game.endTime ?? DateTime.now()),
                  );
                  if (time != null) {
                    setState(() {
                      _game.endTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      _endTimeController.text = DateFormat('yyyy-MM-ddTHH:mm').format(_game.endTime!);
                    });
                  }
                }
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateGame,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
