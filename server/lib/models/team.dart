enum Region { KR, JP, Pacific, NA, EMEA }

class Team {
  final int teamUid;
  final String teamName;
  final String teamLogo;
  final Region region;

  Team({
    required this.teamUid,
    required this.teamName,
    required this.teamLogo,
    required this.region,
  });

  Map<String, dynamic> toJson() => {
    'teamUid': teamUid,
    'teamName': teamName,
    'teamLogo': teamLogo,
    'region': region.name,
  };

  static Team fromJson(Map<String, dynamic> json) => Team(
    teamUid: json['teamUid'] as int,
    teamName: json['teamName'] as String,
    teamLogo: json['teamLogo'] as String,
    region: Region.values.firstWhere((e) => e.name == json['region']),
  );
}
