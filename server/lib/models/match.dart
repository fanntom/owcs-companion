enum MapType {
  Busan, Ilios, Lijiang_Tower, Nepal, Oasis, Antarctica_Peninsula,
  Circuit_Royal, Dorado, Havana, Junkertown, Rialto, Route_66,
  Shambali_Monastery, Watchpoint_Gibraltar, Blizzard_World,
  Eichenwalde, Hollywood, King_s_Row, Midtown, Numbani,
  Paraiso, Colosseo, Esperanca, New_Queen_Street
}

class Match {
  final int matchId;
  final MapType mapId;
  final int team1;
  final int team2;
  final int matchScore1;
  final int matchScore2;
  final DateTime matchTime;
  final int gameId;

  Match({
    required this.matchId,
    required this.mapId,
    required this.team1,
    required this.team2,
    required this.matchScore1,
    required this.matchScore2,
    required this.matchTime,
    required this.gameId,
  });

  Map<String, dynamic> toJson() => {
    'matchId': matchId,
    'mapId': mapId.name,
    'team1': team1,
    'team2': team2,
    'matchScore1': matchScore1,
    'matchScore2': matchScore2,
    'matchTime': matchTime.toIso8601String(),
    'gameId': gameId,
  };

  static Match fromJson(Map<String, dynamic> json) => Match(
    matchId: json['matchId'] as int,
    mapId: MapType.values.firstWhere((e) => e.name == json['mapId']),
    team1: json['team1'] as int,
    team2: json['team2'] as int,
    matchScore1: json['matchScore1'] as int,
    matchScore2: json['matchScore2'] as int,
    matchTime: DateTime.parse(json['matchTime'] as String),
    gameId: json['gameId'] as int,
  );
}
