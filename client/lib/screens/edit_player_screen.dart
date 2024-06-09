import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../services/api_service.dart';

class EditPlayerScreen extends StatefulWidget {
  final Player player;
  final Map<int, Team> teamsMap;

  EditPlayerScreen({required this.player, required this.teamsMap});

  @override
  _EditPlayerScreenState createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late String _playertag;
  late String _realname;
  late int _currentTeamId;
  late String _playerLogo;
  late Position _position;
  late String _region;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _playertag = widget.player.playertag;
    _realname = widget.player.realname;
    _currentTeamId = widget.player.currentTeamId;
    _playerLogo = widget.player.playerLogo;
    _position = Position.values.firstWhere((e) => e.name == widget.player.position);
    _region = widget.player.region;
    _isActive = widget.player.isActive;
  }

  Future<void> _updatePlayer() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedPlayer = Player(
        playerUid: widget.player.playerUid,
        playertag: _playertag,
        realname: _realname,
        currentTeamId: _currentTeamId,
        playerLogo: _playerLogo,
        position: _position.name,
        region: _region,
        isActive: _isActive,
      );
      await _apiService.updatePlayer(updatedPlayer);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _playertag,
                decoration: InputDecoration(labelText: 'Player Tag'),
                validator: (value) => value!.isEmpty ? 'Please enter a player tag' : null,
                onSaved: (value) => _playertag = value!,
              ),
              TextFormField(
                initialValue: _realname,
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
                initialValue: _playerLogo,
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
                onPressed: _updatePlayer,
                child: Text('Update Player'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
