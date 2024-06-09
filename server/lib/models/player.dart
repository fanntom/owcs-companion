enum Position { tank, dps, support }
enum Region { KR, JP, Pacific, NA, EMEA }

class Player {
  final int playerUid;
  final String playertag;
  final String realname;
  final int currentTeamId;
  final String playerLogo;
  final Position position;
  final Region region;
  final bool isActive;

  Player({
    required this.playerUid,
    required this.playertag,
    required this.realname,
    required this.currentTeamId,
    required this.playerLogo,
    required this.position,
    required this.region,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
    'playerUid': playerUid,
    'playertag': playertag,
    'realname': realname,
    'currentTeamId': currentTeamId,
    'playerLogo': playerLogo,
    'position': position.name,
    'region': region.name,
    'isActive': isActive,
  };

  static Player fromJson(Map<String, dynamic> json) => Player(
    playerUid: json['playerUid'] as int,
    playertag: json['playertag'] as String,
    realname: json['realname'] as String,
    currentTeamId: json['currentTeamId'] as int,
    playerLogo: json['playerLogo'] as String,
    position: Position.values.firstWhere((e) => e.name == json['position']),
    region: Region.values.firstWhere((e) => e.name == json['region']),
    isActive: json['isActive'] as bool,
  );
}
