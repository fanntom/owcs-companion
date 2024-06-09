import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlayerDetailScreen extends StatefulWidget {
  final Player player;
  final Team? team;
  final String userId;

  PlayerDetailScreen({required this.player, this.team, required this.userId});

  @override
  _PlayerDetailScreenState createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    try {
      final isBookmarked = await ApiService().isPlayerBookmarked(widget.player.playerUid, widget.userId);
      setState(() {
        _isBookmarked = isBookmarked;
      });
    } catch (e) {
      print('Error checking bookmark status: $e');
    }
  }

  Future<void> _toggleBookmark(BuildContext context) async {
    try {
      if (_isBookmarked) {
        await ApiService().removeBookmarkPlayer(widget.player.playerUid, widget.userId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bookmark removed')),
        );
      } else {
        await ApiService().bookmarkPlayer(widget.player.playerUid, widget.userId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Player bookmarked')),
        );
      }
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle bookmark')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.player.playertag),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: widget.player.playerLogo,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Image.asset('assets/default_player.png'),
            ),
            SizedBox(height: 16.0),
            Text(
              '${widget.player.playertag} (${widget.player.realname})',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Position: ${widget.player.position}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8.0),
            Text(
              'Region: ${widget.player.region}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8.0),
            widget.team != null
                ? Text(
                    'Current Team: ${widget.team!.teamName}',
                    style: TextStyle(fontSize: 18),
                  )
                : Text(
                    'No Team',
                    style: TextStyle(fontSize: 18),
                  ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () => _toggleBookmark(context),
                child: Text(_isBookmarked ? 'Remove Bookmark' : 'Bookmark Player'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
