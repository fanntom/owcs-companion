import 'package:flutter/material.dart';
import '../models/team.dart';
import '../services/api_service.dart';

class CreateTeamScreen extends StatefulWidget {
  @override
  _CreateTeamScreenState createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late String _teamName;
  late String _teamLogo;
  late String _region;

  @override
  void initState() {
    super.initState();
    _teamName = '';
    _teamLogo = '';
    _region = 'KR';
  }

  Future<void> _createTeam() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newTeam = Team(
        teamUid: 0, // This will be set by the backend
        teamName: _teamName,
        teamLogo: _teamLogo,
        region: _region,
      );
      await _apiService.createTeam(newTeam);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Team'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Team Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a team name' : null,
                onSaved: (value) => _teamName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Team Logo URL'),
                validator: (value) => value!.isEmpty ? 'Please enter a team logo URL' : null,
                onSaved: (value) => _teamLogo = value!,
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
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _createTeam,
                child: Text('Create Team'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
