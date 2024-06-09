import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../services/api_service.dart';

class CreatePlayerScreen extends StatefulWidget {
  final Map<int, Team> teamsMap;

  CreatePlayerScreen({required this.teamsMap});

  @override
  _CreatePlayerScreenState createState() => _CreatePlayerScreenState();
}

class _CreatePlayerScreenState extends State<CreatePlayerScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late String _playertag;
  late String _realname;
  late int _currentTeamId;
  late String _playerLogo;
  late Position _position;
  late String _region;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _playertag = '';
    _realname = '';
    _currentTeamId = widget.teamsMap.keys.first;
    _playerLogo = '';
    _position = Position.tank;
    _region = 'NA';
  }

  Future<void> _createPlayer() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newPlayer = Player(
        playerUid: 0,
        playertag: _playertag,
        realname: _realname,
        currentTeamId: _currentTeamId,
        playerLogo: _playerLogo,
        position: _position.name,
        region: _region,
        isActive: _isActive,
      );
      await _apiService.createPlayer(newPlayer);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Player Tag'),
                validator: (value) => value!.isEmpty ? 'Please enter a player tag' : null,
                onSaved: (value) => _playertag = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Real Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a real name' : null,
                onSaved: (value) => _realname = value!,
              ),
              DropdownButtonFormField<int>(
                value: _currentTeamId,
                onChanged: (value) {
                  setState(() {
                    _currentTeamId = value!;
                  });
                },
                items: widget.teamsMap.values.map((team) {
                  return DropdownMenuItem<int>(
                    value: team.teamUid,
                    child: Text(team.teamName),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Current Team'),
                validator: (value) => value == null ? 'Please select a team' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Player Logo URL'),
                validator: (value) => value!.isEmpty ? 'Please enter a player logo URL' : null,
                onSaved: (value) => _playerLogo = value!,
              ),
              DropdownButtonFormField<Position>(
                value: _position,
                onChanged: (value) {
                  setState(() {
                    _position = value!;
                  });
                },
                items: Position.values.map((position) {
                  return DropdownMenuItem<Position>(
                    value: position,
                    child: Text(position.name),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Position'),
                validator: (value) => value == null ? 'Please select a position' : null,
              ),
              DropdownButtonFormField<String>(
                value: _region,
                decoration: InputDecoration(labelText: 'Region'),
                items: ['KR', 'JP', 'Pacific', 'NA', 'EMEA'].map((region) {
                  return DropdownMenuItem<String>(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _region = value!;
                  });
                },
                validator: (value) => value == null ? 'Please select a region' : null,
                onSaved: (value) => _region = value!,
              ),
              SwitchListTile(
                title: Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _createPlayer,
                child: Text('Create Player'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
