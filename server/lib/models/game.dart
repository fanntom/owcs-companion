import 'match.dart';

class Game {
  final int gameId;
  final int team1;
  final int team2;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isInProgress;
  final List<Match>? matches;

  Game({
    required this.gameId,
    required this.team1,
    required this.team2,
    required this.startTime,
    this.endTime,
    required this.isInProgress,
    this.matches,
  });

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'team1': team1,
    'team2': team2,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'isInProgress': isInProgress,
    'matches': matches?.map((m) => m.toJson()).toList(),
  };

  static Game fromJson(Map<String, dynamic> json) => Game(
    gameId: json['gameId'] as int,
    team1: json['team1'] as int,
    team2: json['team2'] as int,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
    isInProgress: json['isInProgress'] as bool,
    matches: (json['matches'] as List<dynamic>?)
        ?.map((m) => Match.fromJson(m as Map<String, dynamic>))
        .toList(),
  );
}
