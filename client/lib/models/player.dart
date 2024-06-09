enum Region { KR, JP, Pacific, NA, EMEA }
enum Position { tank, dps, support } 
class Player {
  final int playerUid;
  final String playertag;
  final String realname;
  final int currentTeamId;
  final String playerLogo;
  final String position;
  final String region;
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

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      playerUid: json['playerUid'],
      playertag: json['playertag'],
      realname: json['realname'],
      currentTeamId: json['currentTeamId'],
      playerLogo: json['playerLogo'],
      position: json['position'],
      region: json['region'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerUid': playerUid,
      'playertag': playertag,
      'realname': realname,
      'currentTeamId': currentTeamId,
      'playerLogo': playerLogo,
      'position': position,
      'region': region,
      'isActive': isActive,
    };
  }
}
