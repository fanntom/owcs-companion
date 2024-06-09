import 'package:flutter/material.dart';
import '../models/team.dart';
import '../services/api_service.dart';

class EditTeamScreen extends StatefulWidget {
  final Team team;

  EditTeamScreen({required this.team});

  @override
  _EditTeamScreenState createState() => _EditTeamScreenState();
}

class _EditTeamScreenState extends State<EditTeamScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late String _teamName;
  late String _teamLogo;
  late String _region;

  @override
  void initState() {
    super.initState();
    _teamName = widget.team.teamName;
    _teamLogo = widget.team.teamLogo;
    _region = widget.team.region;
  }

  Future<void> _updateTeam() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedTeam = Team(
        teamUid: widget.team.teamUid,
        teamName: _teamName,
        teamLogo: _teamLogo,
        region: _region,
      );
      await _apiService.updateTeam(updatedTeam);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Team'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _teamName,
                decoration: InputDecoration(labelText: 'Team Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a team name' : null,
                onSaved: (value) => _teamName = value!,
              ),
              TextFormField(
                initialValue: _teamLogo,
                decoration: InputDecoration(labelText: 'Team Logo URL'),
                validator: (value) => value!.isEmpty ? 'Please enter a team logo URL' : null,
                onSaved: (value) => _teamLogo = value!,
              ),
              DropdownButtonFormField<String>(
                value: _region,
                decoration: InputDecoration(labelText: 'Region'),
                items: Region.values.map((region) {
                  return DropdownMenuItem<String>(
                    value: region.toString().split('.').last,
                    child: Text(region.toString().split('.').last),
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
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateTeam,
                child: Text('Update Team'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
