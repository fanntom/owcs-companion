import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/broadcast.dart';
import '../services/api_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class VODsScreen extends StatefulWidget {
  @override
  _VODsScreenState createState() => _VODsScreenState();
}

class _VODsScreenState extends State<VODsScreen> {
  late Future<List<Broadcast>> _liveBroadcasts;
  late Future<List<Broadcast>> _previousBroadcasts;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _liveBroadcasts = _apiService.fetchBroadcasts(isLive: true);
    _previousBroadcasts = _apiService.fetchBroadcasts(isLive: false);

    if (WebViewPlatform.instance == null) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        WebViewPlatform.instance = AndroidWebViewPlatform();
      } 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('VODs')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Live Broadcasts'),
            _buildBroadcastList(_liveBroadcasts),
            _buildSectionTitle('Previous Broadcasts'),
            _buildBroadcastList(_previousBroadcasts),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBroadcastList(Future<List<Broadcast>> broadcastsFuture) {
    return FutureBuilder<List<Broadcast>>(
      future: broadcastsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No broadcasts found.'));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final broadcast = snapshot.data![index];
              return ListTile(
                title: Text(broadcast.broadcastTitle),
                subtitle: Text(broadcast.broadcastTime.toString()),
                trailing: broadcast.isLive ? Icon(Icons.live_tv, color: Colors.red) : Icon(Icons.play_arrow),
                onTap: () => _openWebView(broadcast.broadcastUrl),
              );
            },
          );
        }
      },
    );
  }

  void _openWebView(String url) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => WebViewScreen(url: url),
    ));
  }
}

class WebViewScreen extends StatelessWidget {
  final String url;

  WebViewScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    final WebViewController controller = WebViewController();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(title: Text('WebView')),
      body: WebViewWidget(controller: controller),
    );
  }
}
