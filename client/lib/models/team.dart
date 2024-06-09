enum Region { KR, JP, Pacific, NA, EMEA }
class Team {
  final int teamUid;
  String teamName;
  String teamLogo;
  String region;

  Team({
    required this.teamUid,
    required this.teamName,
    required this.teamLogo,
    required this.region,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      teamUid: json['teamUid'],
      teamName: json['teamName'],
      teamLogo: json['teamLogo'],
      region: json['region'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamUid': teamUid,
      'teamName': teamName,
      'teamLogo': teamLogo,
      'region': region,
    };
  }
}
