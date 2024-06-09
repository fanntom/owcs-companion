import 'dart:async';
import 'dart:io';
import 'package:openid_client/openid_client.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:openid_client/openid_client_io.dart' as io;

Future<Credential> authenticate(Client client, {List<String> scopes = const []}) async {
  urlLauncher(String url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri) || Platform.isAndroid) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
  var authenticator = io.Authenticator(client, scopes: scopes, port: 4200, urlLancher: urlLauncher);
  var c = await authenticator.authorize();
  if (Platform.isAndroid || Platform.isIOS) {
    closeInAppWebView();
  }

  return c;
}

Future<Credential?> getRedirectResult(Client client, {List<String> scopes = const []}) async {
  return null; 
}

Future<void> signOut(Credential credential) async {
  try {
    final tokenResponse = await credential.getTokenResponse();
    var endSessionEndpoint = credential.client.issuer.metadata.endSessionEndpoint;
    print('End session endpoint: $endSessionEndpoint');
    if (endSessionEndpoint != null) {
      var idToken = tokenResponse.idToken.toCompactSerialization();
      print(idToken);
      var url = Uri.parse(endSessionEndpoint.toString());
      var body = 'id_token_hint=$idToken&post_logout_redirect_uri=http://10.0.2.2:4200/';
      var headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      print('Logout URL: $url');
      print('Body: $body');
      print('Headers: $headers');
      var response = await http.post(url, body: body, headers: headers);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode != 302) {
        print('Failed to log out: ${response.body}');
        throw Exception('Failed to log out');
      }
      print('Logged out successfully');
    }
    await credential.revoke();
    print('Credential revoked');
  } catch (e) {
    print('Error during sign out: $e');
  }
}