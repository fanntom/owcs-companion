import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'lib/database.dart';
import 'lib/services/sync_service.dart';
import 'lib/services/youtube_service.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  try {
    await db.connect(); 
    print('Connected to the database');

    syncService.startSync();
    youTubeSyncService.startSync();

  } catch (e) {
    print('Failed to connect to the database: $e');
    exit(1);
  }
  return serve(handler, ip, port);
}
