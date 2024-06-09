import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openid_client/openid_client.dart';
import '../openid_io.dart' if (dart.library.html) '../openid_browser.dart';
import 'main_screen.dart';

const keycloakUri = 'http://172.30.1.22:8081/realms/owcs-app';
const clientId = 'owcs-app';
const scopes = ['openid', 'profile', 'email'];

Credential? credential;

late Client client;

Future<Client> getClient() async {
  var uri = Uri.parse(keycloakUri);
  if (!kIsWeb && Platform.isAndroid) uri = uri.replace(host: '10.0.2.2');

  var issuer = await Issuer.discover(uri);
  return Client(issuer, clientId);
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  UserInfo? userInfo;
  bool isOrganizer = false;
  bool isClientInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeClient();
  }

  Future<void> _initializeClient() async {
    client = await getClient();
    setState(() {
      isClientInitialized = true;
    });
    credential = await getRedirectResult(client, scopes: scopes);
    if (credential != null) {
      userInfo = await credential!.getUserInfo();
      print('ID Token Claims: ${credential!.idToken.claims}');
      isOrganizer = _hasOrganizerRole(credential!.idToken.claims);
      _navigateToMainScreen();
    } else {
      _authenticate();
    }
  }

  bool _hasOrganizerRole(dynamic claims) {
    final roles = claims['roles'] ?? [];
    print('Roles: $roles');
    return roles.contains('organizer');
  }

  void _navigateToMainScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainScreen(isOrganizer: isOrganizer, userInfo: userInfo!),
      ),
    );
  }

  Future<void> _authenticate() async {
    if (!isClientInitialized) {
      return;
    }

    try {
      var authCredential = await authenticate(client, scopes: scopes);
      setState(() {
        credential = authCredential;
      });
      var userInfo = await authCredential.getUserInfo();
      print('ID Token Claims: ${authCredential.idToken.claims}');
      setState(() {
        this.userInfo = userInfo;
        this.isOrganizer = _hasOrganizerRole(authCredential.idToken.claims);
      });
      _navigateToMainScreen();
    } catch (e) {
      print('Sign in error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Center(
        child: isClientInitialized
            ? userInfo == null
                ? CircularProgressIndicator()
                : CircularProgressIndicator()
            : CircularProgressIndicator(),
      ),
    );
  }
}
