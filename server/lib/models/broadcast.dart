class Broadcast {
  final int broadcastID;
  final String broadcastUrl;
  final DateTime broadcastTime;
  final bool isLive;
  final String broadcastTitle;

  Broadcast({
    required this.broadcastID,
    required this.broadcastUrl,
    required this.broadcastTime,
    required this.isLive,
    required this.broadcastTitle,
  });

  Map<String, dynamic> toJson() => {
    'broadcastID': broadcastID,
    'broadcastUrl': broadcastUrl,
    'broadcastTime': broadcastTime.toIso8601String(),
    'isLive': isLive,
    'broadcastTitle': broadcastTitle,
  };

  static Broadcast fromJson(Map<String, dynamic> json) => Broadcast(
    broadcastID: json['broadcastID'] as int,
    broadcastUrl: json['broadcastUrl'] as String,
    broadcastTime: DateTime.parse(json['broadcastTime'] as String),
    isLive: json['isLive'] as bool,
    broadcastTitle: json['broadcastTitle'] as String,
  );

  @override
  String toString() {
    return 'Broadcast(broadcastID: $broadcastID, broadcastUrl: $broadcastUrl, broadcastTime: $broadcastTime, isLive: $isLive, broadcastTitle: $broadcastTitle)';
  }
}
