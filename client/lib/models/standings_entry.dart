import 'team.dart';

class StandingsEntry {
  final int teamId;
  final String teamName;
  final String teamLogo;
  final String region;
  final int gameWins;
  final int matchWins;

  StandingsEntry({
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.region,
    required this.gameWins,
    required this.matchWins,
  });

  factory StandingsEntry.fromJson(Map<String, dynamic> json) {
    return StandingsEntry(
      teamId: json['teamId'] ?? 0,
      teamName: json['teamName'] ?? 'Unknown',
      teamLogo: json['teamLogo'] ?? '',
      region: json['region'] ?? 'Unknown',
      gameWins: json['gameWins'] ?? 0,
      matchWins: json['matchWins'] ?? 0,
    );
  }

  Team toTeam() {
    return Team(
      teamUid: teamId,
      teamName: teamName,
      teamLogo: teamLogo,
      region: region,
    );
  }

  Map<String, dynamic> toJson() => {
    'teamId': teamId,
    'teamName': teamName,
    'teamLogo': teamLogo,
    'region': region,
    'gameWins': gameWins,
    'matchWins': matchWins,
  };
}
